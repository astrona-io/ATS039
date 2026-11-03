#!/usr/bin/env bash
# Starting state for the safe release lab: a blue-green pair behind the Service
# scout (selecting blue), and a probe Deployment whose revision 2 is stuck.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
for name in scout-blue scout-green probe shuttle; do
  kubectl -n starfleet rollout status "deployment/$name" --timeout=180s
done

# Revision 2 of probe: the readiness path does not exist, so no new pod becomes ready.
kubectl -n starfleet patch deployment probe --type json \
  -p '[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/missing"}]'
# Wait until the second ReplicaSet exists, so the revision history has two entries.
for attempt in $(seq 1 30); do
  count="$(kubectl -n starfleet get replicaset -l app=probe --no-headers 2>/dev/null | wc -l | tr -d ' ')"
  [ "$count" -ge 2 ] && break
  sleep 1
done
echo "[lab] Ready."
