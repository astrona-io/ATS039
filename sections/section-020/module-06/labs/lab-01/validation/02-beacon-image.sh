#!/usr/bin/env bash
# Check: beacon runs the good image tag.
set -uo pipefail

img="$(kubectl -n outpost get deployment beacon -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || true)"
if [ "$img" != "ghcr.io/stefanprodan/podinfo:6.15.0" ]; then
  echo "FAIL: image is '${img}'"
  exit 1
fi
echo "PASS: image is ghcr.io/stefanprodan/podinfo:6.15.0"
