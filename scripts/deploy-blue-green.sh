#!/usr/bin/env bash
set -euo pipefail

# Required env:
# - IMAGE_TAG (ex: GITHUB_SHA)
# - GHCR_OWNER (lowercase)
# - POSTGRES_USER / POSTGRES_PASSWORD / POSTGRES_DB / DATABASE_URL (for backend/.env)

echo "==> Blue/Green deploy: starting"
echo "==> IMAGE_TAG=${IMAGE_TAG}"
echo "==> GHCR_OWNER=${GHCR_OWNER}"

# 1) Ensure backend/.env exists for postgres + backend containers
mkdir -p backend
cat > backend/.env <<EOF
POSTGRES_USER=${POSTGRES_USER}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
POSTGRES_DB=${POSTGRES_DB}
DATABASE_URL=${DATABASE_URL}
EOF

# 2) Ensure shared network exists (idempotent)
docker network inspect app-net >/dev/null 2>&1 || docker network create app-net

# 3) Ensure base stack is up (postgres + reverse-proxy)
docker compose -f docker-compose.base.yml up -d

# 4) Detect active color from active.conf
ACTIVE_FILE="nginx/conf.d/active.conf"
if grep -q "app-back-blue" "$ACTIVE_FILE"; then
  ACTIVE="blue"
  INACTIVE="green"
elif grep -q "app-back-green" "$ACTIVE_FILE"; then
  ACTIVE="green"
  INACTIVE="blue"
else
  echo "ERROR: Cannot detect active color from $ACTIVE_FILE"
  exit 1
fi

echo "==> Active color:   $ACTIVE"
echo "==> Inactive color: $INACTIVE"

# 5) Pull new backend image from GHCR (tagged by IMAGE_TAG / sha)
docker pull "ghcr.io/${GHCR_OWNER}/cloudnative-backend:${IMAGE_TAG}"

# 6) Deploy new version on inactive color (only that color)
echo "==> Deploying ${INACTIVE} with IMAGE_TAG=${IMAGE_TAG}"
GHCR_OWNER="${GHCR_OWNER}" IMAGE_TAG="${IMAGE_TAG}" \
  docker compose -f docker-compose.base.yml -f "docker-compose.${INACTIVE}.yml" up -d

# 7) Healthcheck inactive backend (direct network, before switching traffic)
echo "==> Healthcheck ${INACTIVE}..."
for i in {1..30}; do
  if docker exec reverse-proxy sh -lc "wget -qO- http://app-back-${INACTIVE}:3000/health" >/dev/null 2>&1; then
    echo "==> ${INACTIVE} is healthy ✅"
    break
  fi
  sleep 2
  if [ "$i" -eq 30 ]; then
    echo "ERROR: ${INACTIVE} failed healthcheck"
    exit 1
  fi
done

# 8) Switch proxy to inactive
echo "==> Switching traffic to ${INACTIVE}"
echo "set \$upstream app-back-${INACTIVE}:3000;" > "$ACTIVE_FILE"
docker exec reverse-proxy nginx -s reload

# 9) Post-switch check via public entrypoint (rollback if needed)
echo "==> Post-switch check..."
if curl -fsS http://localhost:8080/health >/dev/null 2>&1; then
  echo "==> Switch successful ✅"
else
  echo "ERROR: Post-switch failed. Rolling back to ${ACTIVE}..."
  echo "set \$upstream app-back-${ACTIVE}:3000;" > "$ACTIVE_FILE"
  docker exec reverse-proxy nginx -s reload
  exit 1
fi

echo "==> Blue/Green deploy completed ✅"