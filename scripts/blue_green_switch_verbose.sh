#!/bin/sh
set -eu

ACTIVE_FILE="active_color.env"
ACTIVE_UPSTREAM="reverse-proxy/conf.d/active_upstream.conf"
IMAGE_BACKEND="${IMAGE_BACKEND:-ghcr.io/mathisba/cloudnative-backend:latest}"
IMAGE_FRONTEND="${IMAGE_FRONTEND:-ghcr.io/mathisba/cloudnative-frontend:latest}"

current="blue"
if [ -f "$ACTIVE_FILE" ]; then
  current=$(awk -F= '/ACTIVE_COLOR/ {print $2}' "$ACTIVE_FILE")
fi

if [ "$current" = "blue" ]; then
  target="green"
else
  target="blue"
fi

echo "Current active color: $current"
echo "Target color to activate: $target"

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

echo "Ensuring base services are up..."
docker compose -f docker-compose.base.yml up -d

if [ "$target" = "blue" ]; then
  echo "Starting blue services..."
  IMAGE_BACKEND_BLUE="$IMAGE_BACKEND" IMAGE_FRONTEND_BLUE="$IMAGE_FRONTEND" \
    docker compose -f docker-compose.base.yml -f docker-compose.blue.yml up -d
else
  echo "Starting green services..."
  IMAGE_BACKEND_GREEN="$IMAGE_BACKEND" IMAGE_FRONTEND_GREEN="$IMAGE_FRONTEND" \
    docker compose -f docker-compose.base.yml -f docker-compose.green.yml up -d
fi

echo "Waiting 5 seconds with both colors running..."
sleep 5

echo "Writing reverse proxy upstreams for $target..."
cat > "$ACTIVE_UPSTREAM" <<EOF
resolver 127.0.0.11 valid=10s;

upstream backend_active {
    zone backend_active 64k;
    server backend-${target}:3000 resolve;
}

upstream frontend_active {
    zone frontend_active 64k;
    server frontend-${target}:80 resolve;
}
EOF

echo "Reloading reverse proxy..."
docker compose -f docker-compose.base.yml exec -T reverse-proxy nginx -s reload

echo "Waiting 5 seconds for traffic to stabilize..."
sleep 5

if [ "$current" = "blue" ]; then
  echo "Stopping blue services..."
  IMAGE_BACKEND_BLUE="$IMAGE_BACKEND" IMAGE_FRONTEND_BLUE="$IMAGE_FRONTEND" \
    docker compose -f docker-compose.base.yml -f docker-compose.blue.yml stop backend-blue frontend-blue
else
  echo "Stopping green services..."
  IMAGE_BACKEND_GREEN="$IMAGE_BACKEND" IMAGE_FRONTEND_GREEN="$IMAGE_FRONTEND" \
    docker compose -f docker-compose.base.yml -f docker-compose.green.yml stop backend-green frontend-green
fi

echo "Recording active color: $target"
echo "ACTIVE_COLOR=$target" > "$ACTIVE_FILE"

echo "Switch complete."
