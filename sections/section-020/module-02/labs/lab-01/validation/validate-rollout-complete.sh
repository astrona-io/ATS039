#!/usr/bin/env bash
# Check: the rollout of lookout is complete and progressing normally.
set -uo pipefail

g() { kubectl -n starfleet get deployment lookout -o jsonpath="$1" 2>/dev/null || true; }
desired="$(g '{.spec.replicas}')"
updated="$(g '{.status.updatedReplicas}')"
ready="$(g '{.status.readyReplicas}')"
available="$(g '{.status.availableReplicas}')"
if [ "${desired:-0}" != "2" ] || [ "${updated:-0}" != "$desired" ] || [ "${ready:-0}" != "$desired" ] || [ "${available:-0}" != "$desired" ]; then
  echo "FAIL: lookout has desired=${desired}, updated=${updated:-0}, ready=${ready:-0}, available=${available:-0}"
  exit 1
fi
reason="$(g '{.status.conditions[?(@.type=="Progressing")].reason}')"
if [ "$reason" != "NewReplicaSetAvailable" ]; then
  echo "FAIL: the Progressing condition of lookout has reason '${reason}', expected NewReplicaSetAvailable"
  exit 1
fi

echo "PASS: lookout rollout is complete (${ready}/${desired} ready)"
