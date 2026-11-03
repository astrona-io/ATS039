#!/usr/bin/env bash
# Starting state for the delivery capstone: a stand-in repository (ConfigMap
# delivery-repo) with a Kustomize base, and nothing deployed in outpost.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"

kubectl -n delivery-repo create configmap delivery-repo \
  --from-file=base-deployment.yaml="$DIR/manifests/repo-base-deployment.yaml" \
  --from-file=base-service.yaml="$DIR/manifests/repo-base-service.yaml" \
  --dry-run=client -o yaml | kubectl apply -f -

fingerprint="$(kubectl -n delivery-repo get configmap delivery-repo -o jsonpath='{.data}' | shasum -a 256 | cut -d' ' -f1)"
kubectl -n lab-meta create configmap repo-fingerprint --from-literal=sha256="$fingerprint" \
  --dry-run=client -o yaml | kubectl apply -f -

for name in scout probe shuttle; do
  kubectl -n starfleet rollout status "deployment/$name" --timeout=180s
done
kubectl -n outpost rollout status deployment/drifter --timeout=180s
echo "[lab] Ready."
