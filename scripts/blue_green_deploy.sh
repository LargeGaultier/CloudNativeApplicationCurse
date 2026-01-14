#!/bin/sh
set -e

ACTIVE_FILE="active_color.env"
ACTIVE_UPSTREAM="reverse-proxy/conf.d/active_upstream.conf"

if [ -z "${DOCKER_USERNAME}" ] || [ -z "${GITHUB_SHA}" ]; then
  echo "Missing DOCKER_USERNAME or GITHUB_SHA"
  exit 1
fi

if [ -z "${POSTGRES_USER}" ] || [ -z "${POSTGRES_PASSWORD}" ] || [ -z "${POSTGRES_DB}" ]; then
  echo "Missing POSTGRES_USER/POSTGRES_PASSWORD/POSTGRES_DB"
  exit 1
fi

USERNAME_LOWER=$(echo "${DOCKER_USERNAME}" | tr '[:upper:]' '[:lower:]')
IMAGE_BACKEND="ghcr.io/${USERNAME_LOWER}/cloudnative-backend:${GITHUB_SHA}"
IMAGE_FRONTEND="ghcr.io/${USERNAME_LOWER}/cloudnative-frontend:${GITHUB_SHA}"

CURRENT_COLOR="none"
if [ -f "${ACTIVE_FILE}" ]; then
  CURRENT_COLOR=$(awk -F= '/ACTIVE_COLOR/ {print $2}' "${ACTIVE_FILE}")
fi

if [ "${CURRENT_COLOR}" = "blue" ]; then
  TARGET_COLOR="green"
else
  TARGET_COLOR="blue"
fi

echo "Current color: ${CURRENT_COLOR}"
echo "Target color: ${TARGET_COLOR}"

if [ "${TARGET_COLOR}" = "blue" ]; then
  export IMAGE_BACKEND_BLUE="${IMAGE_BACKEND}"
  export IMAGE_FRONTEND_BLUE="${IMAGE_FRONTEND}"
  docker compose -f docker-compose.base.yml -f docker-compose.blue.yml up -d --no-build
else
  export IMAGE_BACKEND_GREEN="${IMAGE_BACKEND}"
  export IMAGE_FRONTEND_GREEN="${IMAGE_FRONTEND}"
  docker compose -f docker-compose.base.yml -f docker-compose.green.yml up -d --no-build
fi

cat > "${ACTIVE_UPSTREAM}" <<EOF
resolver 127.0.0.11 valid=10s;

upstream backend_active {
    zone backend_active 64k;
    server backend-${TARGET_COLOR}:3000 resolve;
}

upstream frontend_active {
    zone frontend_active 64k;
    server frontend-${TARGET_COLOR}:80 resolve;
}
EOF

docker compose -f docker-compose.base.yml exec -T reverse-proxy nginx -s reload

echo "Checking backend health..."
for i in 1 2 3 4 5; do
  if curl -fsS http://localhost/api/health >/dev/null; then
    echo "Backend is up."
    break
  fi
  if [ "$i" -eq 5 ]; then
    echo "Backend healthcheck failed, rolling back."
    if [ "${CURRENT_COLOR}" != "none" ]; then
      cat > "${ACTIVE_UPSTREAM}" <<EOF
resolver 127.0.0.11 valid=10s;

upstream backend_active {
    zone backend_active 64k;
    server backend-${CURRENT_COLOR}:3000 resolve;
}

upstream frontend_active {
    zone frontend_active 64k;
    server frontend-${CURRENT_COLOR}:80 resolve;
}
EOF
      docker compose -f docker-compose.base.yml exec -T reverse-proxy nginx -s reload
    fi
    exit 1
  fi
  sleep 2
done

echo "Checking frontend..."
for i in 1 2 3 4 5; do
  if curl -fsS http://localhost/ >/dev/null; then
    echo "Frontend is up."
    break
  fi
  if [ "$i" -eq 5 ]; then
    echo "Frontend check failed, rolling back."
    if [ "${CURRENT_COLOR}" != "none" ]; then
      cat > "${ACTIVE_UPSTREAM}" <<EOF
resolver 127.0.0.11 valid=10s;

upstream backend_active {
    zone backend_active 64k;
    server backend-${CURRENT_COLOR}:3000 resolve;
}

upstream frontend_active {
    zone frontend_active 64k;
    server frontend-${CURRENT_COLOR}:80 resolve;
}
EOF
      docker compose -f docker-compose.base.yml exec -T reverse-proxy nginx -s reload
    fi
    exit 1
  fi
  sleep 2
done

echo "ACTIVE_COLOR=${TARGET_COLOR}" > "${ACTIVE_FILE}"
