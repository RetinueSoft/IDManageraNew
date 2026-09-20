#!/usr/bin/env bash
# Builds the api/ui images locally, tags each with both :latest and the
# current git short-SHA, and pushes both tags to GHCR -- see ../DEPLOY.md
# for the full runbook (one-time GHCR auth, server pull/rollback). Requires
# `docker login ghcr.io` to already have been run once with a
# write:packages-scoped PAT.
set -euo pipefail
cd "$(dirname "$0")/.."   # repo root

API_IMAGE=ghcr.io/retinuesoft/idcardmanager-api
UI_IMAGE=ghcr.io/retinuesoft/idcardmanager-ui
SHA=$(git rev-parse --short HEAD)

# POSTGRES_PASSWORD / JWT_KEY are only needed to run the stack, not to build or push; the compose
# file insists on them being set, so give it throwaway values just for these commands.
export POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-build-only}"
export JWT_KEY="${JWT_KEY:-build-only-build-only-build-only-build-only}"

docker compose -f docker-compose.yml -f docker-compose.build.yml build api ui

docker tag "$API_IMAGE:latest" "$API_IMAGE:$SHA"
docker tag "$UI_IMAGE:latest" "$UI_IMAGE:$SHA"

docker compose -f docker-compose.yml -f docker-compose.build.yml push api ui
docker push "$API_IMAGE:$SHA"
docker push "$UI_IMAGE:$SHA"

echo "Pushed $API_IMAGE:latest, $API_IMAGE:$SHA, $UI_IMAGE:latest, $UI_IMAGE:$SHA"
