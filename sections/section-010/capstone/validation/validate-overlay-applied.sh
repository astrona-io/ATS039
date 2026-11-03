#!/usr/bin/env bash
# Check: scout in outpost comes from the Kustomize overlay.
set -uo pipefail

g() { kubectl -n outpost get deployment scout -o jsonpath="$1" 2>/dev/null || true; }
replicas="$(g '{.spec.replicas}')"
if [ "$replicas" != "3" ]; then
  echo "FAIL: scout in outpost has spec.replicas '${replicas}', expected 3"
  exit 1
fi
image="$(g '{.spec.template.spec.containers[0].image}')"
if [ "$image" != "ghcr.io/stefanprodan/podinfo:6.15.0" ]; then
  echo "FAIL: image is '${image}', expected 'ghcr.io/stefanprodan/podinfo:6.15.0'"
  exit 1
fi
object_label="$(g '{.metadata.labels.env}')"
pod_label="$(g '{.spec.template.metadata.labels.env}')"
if [ "$object_label" != "production" ] || [ "$pod_label" != "production" ]; then
  echo "FAIL: label env=production is '${object_label}' on the Deployment and '${pod_label}' on the pod template"
  exit 1
fi
applied="$(g '{.metadata.annotations.kubectl\.kubernetes\.io/last-applied-configuration}')"
if [ -z "$applied" ]; then
  echo "FAIL: scout was not created with kubectl apply -k"
  exit 1
fi
available="$(g '{.status.availableReplicas}')"
if [ "${available:-0}" != "3" ]; then
  echo "FAIL: scout in outpost has '${available:-0}' available replicas, expected 3"
  exit 1
fi
if ! kubectl -n outpost get service scout >/dev/null 2>&1; then
  echo "FAIL: the Service scout does not exist in outpost. Build the overlay from both files of the base"
  exit 1
fi

echo "PASS: scout in outpost comes from the overlay with 3 available replicas"
