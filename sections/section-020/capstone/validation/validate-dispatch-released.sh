#!/usr/bin/env bash
# Check: dispatch version two is fully rolled out by fixing forward.
set -uo pipefail

g() { kubectl -n starfleet get deployment dispatch -o jsonpath="$1" 2>/dev/null || true; }
path="$(g '{.spec.template.spec.containers[0].readinessProbe.httpGet.path}')"
message="$(g '{.spec.template.spec.containers[0].env[?(@.name=="PODINFO_UI_MESSAGE")].value}')"
if [ "$path" != "/readyz" ] || [ "$message" != "dispatch-v2" ]; then
  echo "FAIL: dispatch has readiness path '${path}' and message '${message}', expected '/readyz' and 'dispatch-v2' (fix forward, do not roll back)"
  exit 1
fi
desired="$(g '{.spec.replicas}')"
updated="$(g '{.status.updatedReplicas}')"
ready="$(g '{.status.readyReplicas}')"
available="$(g '{.status.availableReplicas}')"
if [ "${desired:-0}" != "2" ] || [ "${updated:-0}" != "$desired" ] || [ "${ready:-0}" != "$desired" ] || [ "${available:-0}" != "$desired" ]; then
  echo "FAIL: dispatch has desired=${desired}, updated=${updated:-0}, ready=${ready:-0}, available=${available:-0}"
  exit 1
fi
reason="$(g '{.status.conditions[?(@.type=="Progressing")].reason}')"
if [ "$reason" != "NewReplicaSetAvailable" ]; then
  echo "FAIL: the Progressing condition of dispatch has reason '${reason}', expected NewReplicaSetAvailable"
  exit 1
fi

echo "PASS: dispatch version two is rolled out (${ready}/${desired} ready)"
