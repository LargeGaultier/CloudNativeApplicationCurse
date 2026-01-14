#!/bin/sh
set -e

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

export IMAGE_BACKEND IMAGE_FRONTEND

docker compose down
docker pull "${IMAGE_BACKEND}"
docker pull "${IMAGE_FRONTEND}"
docker compose up -d --no-build

echo "Checking backend health..."
for i in 1 2 3 4 5; do
  if curl -fsS http://localhost:3000/health >/dev/null; then
    echo "Backend is up."
    break
  fi
  if [ "$i" -eq 5 ]; then
    echo "Backend healthcheck failed."
    exit 1
  fi
  sleep 2
done

echo "Checking frontend..."
for i in 1 2 3 4 5; do
  if curl -fsS http://localhost:8080 >/dev/null; then
    echo "Frontend is up."
    break
  fi
  if [ "$i" -eq 5 ]; then
    echo "Frontend check failed."
    exit 1
  fi
  sleep 2
done
