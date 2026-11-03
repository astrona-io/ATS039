#!/usr/bin/env bash
# Check: The message is second after the rollback.
set -uo pipefail

msg="$(kubectl -n outpost get deployment beacon -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="PODINFO_UI_MESSAGE")].value}' 2>/dev/null || true)"
if [ "$msg" != "second" ]; then
  echo "FAIL: message is '${msg}', expected second"
  exit 1
fi
echo "PASS: message is second"
