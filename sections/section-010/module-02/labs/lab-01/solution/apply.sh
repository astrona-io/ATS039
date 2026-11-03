#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# 1. Reconcile starfleet from the repository.
kubectl -n gitops-repo get configmap desired-state -o jsonpath='{.data.scout\.yaml}' > "$WORK/scout.yaml"
kubectl apply -f "$WORK/scout.yaml"
kubectl -n starfleet rollout status deployment/scout --timeout=180s

# 2. Remove the object that the repository does not list.
kubectl -n starfleet delete deployment debug-tools

# 3. Build and apply the production overlay from the base in the repository.
mkdir -p "$WORK/base" "$WORK/overlays/production"
kubectl -n gitops-repo get configmap desired-state -o jsonpath='{.data.base-deployment\.yaml}' > "$WORK/base/deployment.yaml"
printf 'apiVersion: kustomize.config.k8s.io/v1beta1\nkind: Kustomization\nresources:\n  - deployment.yaml\n' > "$WORK/base/kustomization.yaml"
cp "$DIR/solution.yaml" "$WORK/overlays/production/kustomization.yaml"
kubectl apply -k "$WORK/overlays/production"
kubectl -n outpost rollout status deployment/scout --timeout=180s
echo "[solution] Applied."
