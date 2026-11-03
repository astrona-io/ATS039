#!/usr/bin/env bash
# Check: beacon runs and is stable. The Deployment must be fixed, not replaced.
set -uo pipefail

mode="$(kubectl -n starfleet get deployment beacon -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="MODE")].value}' 2>/dev/null || true)"
if [ "$mode" != "serve" ]; then
  echo "FAIL: MODE of beacon is '${mode}', the process only keeps running with 'serve'. Read the log with kubectl logs --previous"
  exit 1
fi
ready="$(kubectl -n starfleet get deployment beacon -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)"
if [ "${ready:-0}" != "1" ]; then
  echo "FAIL: beacon has '${ready:-0}' ready replicas, expected 1"
  exit 1
fi

echo "PASS: beacon runs with MODE=serve"
