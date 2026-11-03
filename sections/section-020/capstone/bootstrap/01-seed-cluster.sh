#!/usr/bin/env bash
# Starting state for the debugging capstone: dispatch (stuck release), beacon
# (crash loop from a ConfigMap value) and relay (Service without endpoints).
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
for name in scout probe shuttle dispatch relay; do
  kubectl -n starfleet rollout status "deployment/$name" --timeout=180s
done

# Release version two of dispatch with a readiness path that does not exist.
kubectl -n starfleet patch deployment dispatch --type json -p '[
  {"op":"replace","path":"/spec/template/spec/containers/0/env/0/value","value":"dispatch-v2"},
  {"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/missing"}
]'
for attempt in $(seq 1 30); do
  count="$(kubectl -n starfleet get replicaset -l app=dispatch --no-headers 2>/dev/null | wc -l | tr -d ' ')"
  [ "$count" -ge 2 ] && break
  sleep 1
done

# Record the Deployment UIDs, so the lab can detect a delete and recreate.
args=()
for name in dispatch beacon relay; do
  uid="$(kubectl -n starfleet get deployment "$name" -o jsonpath='{.metadata.uid}')"
  args+=("--from-literal=${name}=${uid}")
done
kubectl -n lab-meta create configmap deployment-uids "${args[@]}" --dry-run=client -o yaml | kubectl apply -f -
echo "[lab] Ready."
