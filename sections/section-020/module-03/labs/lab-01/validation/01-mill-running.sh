#!/usr/bin/env bash
# Check: mill has an emptyDir volume at /data and one available replica.
set -uo pipefail

vol="$(kubectl -n outpost get deployment mill -o jsonpath='{.spec.template.spec.containers[0].volumeMounts[?(@.mountPath=="/data")].name}' 2>/dev/null || true)"
if [ -z "$vol" ]; then
  echo "FAIL: no volume is mounted at /data"
  exit 1
fi
kind="$(kubectl -n outpost get deployment mill -o jsonpath="{.spec.template.spec.volumes[?(@.name==\"${vol}\")].emptyDir}" 2>/dev/null || true)"
if [ -z "$kind" ]; then
  echo "FAIL: the volume ${vol} is not an emptyDir"
  exit 1
fi
available="$(kubectl -n outpost get deployment mill -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
if [ "${available:-0}" != "1" ]; then
  echo "FAIL: ${available:-0} replicas are available, expected 1"
  exit 1
fi
echo "PASS: mill writes to an emptyDir at /data and is available"
