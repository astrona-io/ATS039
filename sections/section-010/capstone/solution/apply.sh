#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

cp "$DIR/kustomization.yaml" "$WORK/"
kubectl -n delivery-repo get configmap delivery-repo -o jsonpath='{.data.base-deployment\.yaml}' > "$WORK/base-deployment.yaml"
kubectl -n delivery-repo get configmap delivery-repo -o jsonpath='{.data.base-service\.yaml}' > "$WORK/base-service.yaml"

kubectl apply -k "$WORK"
kubectl -n outpost rollout status deployment/scout --timeout=180s

kubectl apply -f "$DIR/canary.yaml"
kubectl -n outpost rollout status deployment/scout-canary --timeout=180s

kubectl apply -f "$DIR/release-check.yaml"
kubectl -n outpost wait --for=condition=complete job/release-check --timeout=180s

kubectl -n outpost annotate deployment scout kubernetes.io/change-cause="production overlay with canary scout-canary at 3:1, release-check passed" --overwrite
echo "[solution] Applied."
