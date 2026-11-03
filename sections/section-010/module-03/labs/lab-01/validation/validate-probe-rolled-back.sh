#!/usr/bin/env bash
# Check: probe runs the previous revision's template again and is fully rolled out.
set -uo pipefail

path="$(kubectl -n starfleet get deployment probe -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}' 2>/dev/null || true)"
if [ "$path" != "/status/200" ]; then
  echo "FAIL: the readiness path of probe is '${path}', expected '/status/200' (the previous revision)"
  exit 1
fi
revision="$(kubectl -n starfleet get deployment probe -o jsonpath='{.metadata.annotations.deployment\.kubernetes\.io/revision}' 2>/dev/null || true)"
if [ "${revision:-0}" -lt 3 ]; then
  echo "FAIL: the revision of probe is '${revision:-0}'. A rollback creates revision 3 or higher; do not recreate the Deployment"
  exit 1
fi
desired="$(kubectl -n starfleet get deployment probe -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
updated="$(kubectl -n starfleet get deployment probe -o jsonpath='{.status.updatedReplicas}' 2>/dev/null || true)"
ready="$(kubectl -n starfleet get deployment probe -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)"
unavailable="$(kubectl -n starfleet get deployment probe -o jsonpath='{.status.unavailableReplicas}' 2>/dev/null || true)"
if [ "${updated:-0}" != "$desired" ] || [ "${ready:-0}" != "$desired" ] || [ "${unavailable:-0}" != "0" ]; then
  echo "FAIL: probe has desired=${desired}, updated=${updated:-0}, ready=${ready:-0}, unavailable=${unavailable:-0}"
  exit 1
fi

echo "PASS: probe is rolled back and all ${desired} replicas are ready"
