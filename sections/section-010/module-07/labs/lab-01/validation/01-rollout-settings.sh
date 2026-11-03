#!/usr/bin/env bash
# Check: dock uses maxSurge 1, maxUnavailable 0 and minReadySeconds 5.
set -uo pipefail

surge="$(kubectl -n outpost get deployment dock -o jsonpath='{.spec.strategy.rollingUpdate.maxSurge}' 2>/dev/null || true)"
unavail="$(kubectl -n outpost get deployment dock -o jsonpath='{.spec.strategy.rollingUpdate.maxUnavailable}' 2>/dev/null || true)"
ready="$(kubectl -n outpost get deployment dock -o jsonpath='{.spec.minReadySeconds}' 2>/dev/null || true)"
if [ "$surge" != "1" ] || [ "$unavail" != "0" ] || [ "$ready" != "5" ]; then
  echo "FAIL: maxSurge '${surge}', maxUnavailable '${unavail}', minReadySeconds '${ready}'"
  exit 1
fi
echo "PASS: maxSurge 1, maxUnavailable 0, minReadySeconds 5"
