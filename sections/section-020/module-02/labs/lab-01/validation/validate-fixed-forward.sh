#!/usr/bin/env bash
# Check: version two is kept (message lookout-v2), the probe path is fixed, and the fix is a new revision.
set -uo pipefail

g() { kubectl -n starfleet get deployment lookout -o jsonpath="$1" 2>/dev/null || true; }
path="$(g '{.spec.template.spec.containers[0].readinessProbe.httpGet.path}')"
if [ "$path" != "/readyz" ]; then
  echo "FAIL: the readiness path of lookout is '${path}', expected '/readyz'"
  exit 1
fi
message="$(g '{.spec.template.spec.containers[0].env[?(@.name=="PODINFO_UI_MESSAGE")].value}')"
if [ "$message" != "lookout-v2" ]; then
  echo "FAIL: PODINFO_UI_MESSAGE is '${message}'. Version two must stay released; fix forward instead of returning to version one"
  exit 1
fi
revision="$(g '{.metadata.annotations.deployment\.kubernetes\.io/revision}')"
if [ "${revision:-0}" -lt 3 ]; then
  echo "FAIL: the revision of lookout is '${revision:-0}', expected 3 or higher after the fix"
  exit 1
fi

echo "PASS: lookout runs version two with the readiness path /readyz (revision ${revision})"
