#!/usr/bin/env bash
# Floci emulator start karta hai aur Terraform se resources provision karta hai.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "1/3 Starting Floci..."
docker compose -f floci/docker-compose.yml up -d

echo "2/3 Waiting for Floci to be healthy..."
for i in $(seq 1 30); do
  s=$(docker inspect -f '{{.State.Health.Status}}' floci-floci-1 2>/dev/null || true)
  [ "$s" = "healthy" ] && break
  sleep 2
done
[ "${s:-}" = "healthy" ] || { echo "Floci not healthy"; exit 1; }

echo "3/3 Terraform apply (Floci env)..."
# shellcheck disable=SC1091
source floci/env.sh
cd terraform/envs/floci
terraform init -input=false
terraform apply -input=false -auto-approve

echo "DONE. Ab ./scripts/validate.sh chalao."
