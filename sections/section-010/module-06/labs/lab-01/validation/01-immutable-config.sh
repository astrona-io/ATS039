#!/usr/bin/env bash
# Check: The ConfigMap ledger-config-v2 is immutable and has LEVEL debug.
set -uo pipefail

imm="$(kubectl -n outpost get configmap ledger-config-v2 -o jsonpath='{.immutable}' 2>/dev/null || true)"
level="$(kubectl -n outpost get configmap ledger-config-v2 -o jsonpath='{.data.LEVEL}' 2>/dev/null || true)"
if [ "$imm" != "true" ] || [ "$level" != "debug" ]; then
  echo "FAIL: immutable is '${imm}' and LEVEL is '${level}'"
  exit 1
fi
echo "PASS: ledger-config-v2 is immutable with LEVEL debug"
