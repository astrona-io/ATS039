#!/usr/bin/env bash
# Check: ledger reads ledger-config-v2 and runs two updated replicas.
set -uo pipefail

name="$(kubectl -n outpost get deployment ledger -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="PODINFO_LEVEL")].valueFrom.configMapKeyRef.name}' 2>/dev/null || true)"
if [ "$name" != "ledger-config-v2" ]; then
  echo "FAIL: PODINFO_LEVEL reads from '${name}'"
  exit 1
fi
updated="$(kubectl -n outpost get deployment ledger -o jsonpath='{.status.updatedReplicas}/{.status.availableReplicas}' 2>/dev/null || true)"
if [ "$updated" != "2/2" ]; then
  echo "FAIL: updated/available replicas are '${updated}', expected 2/2"
  exit 1
fi
echo "PASS: ledger reads ledger-config-v2 with 2 updated replicas"
