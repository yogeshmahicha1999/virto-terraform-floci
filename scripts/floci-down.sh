#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")/.."
# shellcheck disable=SC1091
source floci/env.sh

RESET="${FULL_RESET:-0}"

echo "1/3 terraform destroy..."
if ( cd terraform/envs/floci && terraform destroy -input=false -auto-approve ); then
  echo "destroy OK"
else
  echo "WARN: destroy failed (known Floci VPC delete issue). Doing full Floci reset."
  RESET=1
fi

echo "2/3 Stopping Floci..."
if [ "$RESET" = "1" ]; then
  docker compose -f floci/docker-compose.yml down -v
  rm -f terraform/envs/floci/terraform.tfstate terraform/envs/floci/terraform.tfstate.backup
else
  docker compose -f floci/docker-compose.yml down
fi

echo "3/3 Removing leftover Floci-created containers..."
docker ps -aq --filter "name=floci-aws-" | xargs docker rm -f 2>/dev/null || true

echo "Cleanup done."
