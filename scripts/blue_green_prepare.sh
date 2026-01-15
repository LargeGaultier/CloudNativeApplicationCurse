#!/bin/sh
set -eu

COLOR="${1:-blue}"
IMAGE_BACKEND="${IMAGE_BACKEND:-ghcr.io/mathisba/cloudnative-backend:latest}"
IMAGE_FRONTEND="${IMAGE_FRONTEND:-ghcr.io/mathisba/cloudnative-frontend:latest}"

ensure_network() {
  if docker network inspect app_net >/dev/null 2>&1; then
    label=$(docker network inspect app_net --format '{{ index .Labels "com.docker.compose.network" }}')
    if [ "$label" != "app_net" ]; then
      ids=$(docker network inspect app_net --format '{{range $id, $c := .Containers}}{{$id}} {{end}}')
      if [ -n "$ids" ]; then
        for id in $ids; do
          docker network disconnect -f app_net "$id" >/dev/null
        done
      fi
      docker network rm app_net >/dev/null
    fi
  fi
}

ensure_network

cleanup_stale() {
  docker rm -f \
    cloudnativeapplicationcurse-backend-blue-1 \
    cloudnativeapplicationcurse-frontend-blue-1 \
    cloudnativeapplicationcurse-backend-green-1 \
    cloudnativeapplicationcurse-frontend-green-1 \
    >/dev/null 2>&1 || true
}

cleanup_stale

echo "Preparing base services..."
docker compose -f docker-compose.base.yml up -d

if [ "$COLOR" = "blue" ]; then
  echo "Starting blue services..."
  IMAGE_BACKEND_BLUE="$IMAGE_BACKEND" IMAGE_FRONTEND_BLUE="$IMAGE_FRONTEND" \
    docker compose -f docker-compose.base.yml -f docker-compose.blue.yml up -d
else
  echo "Starting green services..."
  IMAGE_BACKEND_GREEN="$IMAGE_BACKEND" IMAGE_FRONTEND_GREEN="$IMAGE_FRONTEND" \
    docker compose -f docker-compose.base.yml -f docker-compose.green.yml up -d
fi

echo "Preparation done. Active color: $COLOR"
