#!/bin/sh
set -e

if [ -z "${DOCKER_USERNAME}" ] || [ -z "${GITHUB_SHA}" ]; then
  echo "Missing DOCKER_USERNAME or GITHUB_SHA"
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
