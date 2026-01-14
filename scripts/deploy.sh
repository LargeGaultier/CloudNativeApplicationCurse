#!/usr/bin/env bash
set -euo pipefail

echo "==> Deploy: start"

# 1) Normaliser le owner GHCR en lowercase (obligatoire)
OWNER_LC="$(echo "${GITHUB_REPOSITORY_OWNER:-}" | tr '[:upper:]' '[:lower:]')"
IMAGE_TAG="${GITHUB_SHA:?GITHUB_SHA is required}"

echo "==> GHCR owner: $OWNER_LC"
echo "==> Image tag:  $IMAGE_TAG"

# 2) Stop stack (sans détruire volumes) - idempotent
echo "==> Stopping stack (keep volumes)"
docker compose down || true

# 3) Pull images (depuis registre distant)
echo "==> Pulling images"
docker pull "ghcr.io/${OWNER_LC}/cloudnative-backend:${IMAGE_TAG}"
docker pull "ghcr.io/${OWNER_LC}/cloudnative-frontend:${IMAGE_TAG}"

# 4) Re-créer backend/.env (car docker-compose le demande)
# (idempotent : le fichier est réécrit à chaque fois)
echo "==> Writing backend/.env"
cat > backend/.env <<EOF
POSTGRES_USER=${POSTGRES_USER}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
POSTGRES_DB=${POSTGRES_DB}
DATABASE_URL=${DATABASE_URL}
EOF

# 5) Redémarrer avec le bon tag (si ton compose utilise ${IMAGE_TAG})
echo "==> Starting stack"
IMAGE_TAG="${IMAGE_TAG}" docker compose up -d

echo "==> Deploy: done ✅"