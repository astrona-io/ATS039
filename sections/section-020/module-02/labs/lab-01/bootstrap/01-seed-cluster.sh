#!/usr/bin/env bash
# Starting state for the failed release lab: lookout version one is healthy, then
# version two is released with a readiness path that does not exist.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
for name in scout probe shuttle lookout; do
  kubectl -n starfleet rollout status "deployment/$name" --timeout=180s
done

# Revision 2: new message, wrong readiness path. New pods never become ready.
kubectl -n starfleet patch deployment lookout --type json -p '[
  {"op":"replace","path":"/spec/template/spec/containers/0/env/0/value","value":"lookout-v2"},
  {"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/missing"}
]'
# Wait until the second ReplicaSet exists.
for attempt in $(seq 1 30); do
  count="$(kubectl -n starfleet get replicaset -l app=lookout --no-headers 2>/dev/null | wc -l | tr -d ' ')"
  [ "$count" -ge 2 ] && break
  sleep 1
done
echo "[lab] Ready."
