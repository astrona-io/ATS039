#!/usr/bin/env bash
# Check: dock has a 20 second grace period and a 5 second preStop sleep.
set -uo pipefail

grace="$(kubectl -n outpost get deployment dock -o jsonpath='{.spec.template.spec.terminationGracePeriodSeconds}' 2>/dev/null || true)"
sleep_s="$(kubectl -n outpost get deployment dock -o jsonpath='{.spec.template.spec.containers[0].lifecycle.preStop.sleep.seconds}' 2>/dev/null || true)"
if [ "$grace" != "20" ] || [ "$sleep_s" != "5" ]; then
  echo "FAIL: grace period '${grace}' and preStop sleep '${sleep_s}'"
  exit 1
fi
available="$(kubectl -n outpost get deployment dock -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
if [ "${available:-0}" != "4" ]; then
  echo "FAIL: ${available:-0} replicas are available, expected 4"
  exit 1
fi
echo "PASS: grace period 20, preStop sleep 5, 4 replicas available"
