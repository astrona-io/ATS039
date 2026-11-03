#!/usr/bin/env bash
# Starting state for the GitOps lab: a stand-in repository (ConfigMap), a
# scout Deployment that was changed by hand, and an object the repository
# does not list.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"

kubectl -n gitops-repo create configmap desired-state \
  --from-file=scout.yaml="$DIR/manifests/repo-scout.yaml" \
  --from-file=base-deployment.yaml="$DIR/manifests/repo-base-deployment.yaml" \
  --dry-run=client -o yaml | kubectl apply -f -

# The live scout starts equal to the repository, then people change it by hand.
kubectl apply -f "$DIR/manifests/repo-scout.yaml"
kubectl -n starfleet rollout status deployment/scout --timeout=180s
kubectl -n starfleet scale deployment scout --replicas=1
kubectl -n starfleet set env deployment/scout PODINFO_UI_MESSAGE=scout-hotfix
kubectl -n starfleet rollout status deployment/scout --timeout=180s

# Fingerprint of the repository content, so the lab can detect an edit.
fingerprint="$(kubectl -n gitops-repo get configmap desired-state -o jsonpath='{.data}' | shasum -a 256 | cut -d' ' -f1)"
kubectl -n lab-meta create configmap repo-fingerprint --from-literal=sha256="$fingerprint" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n starfleet rollout status deployment/debug-tools --timeout=180s
kubectl -n starfleet rollout status deployment/shuttle --timeout=180s
echo "[lab] Ready."
