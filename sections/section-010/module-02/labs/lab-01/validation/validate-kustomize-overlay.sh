#!/usr/bin/env bash
# Check: scout in outpost was applied from a Kustomize overlay (replicas 2,
# label env=production on the Deployment and on its pods).
set -uo pipefail

replicas="$(kubectl -n outpost get deployment scout -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
if [ "$replicas" != "2" ]; then
  echo "FAIL: scout in outpost has spec.replicas '${replicas}', expected 2"
  exit 1
fi
object_label="$(kubectl -n outpost get deployment scout -o jsonpath='{.metadata.labels.env}' 2>/dev/null || true)"
pod_label="$(kubectl -n outpost get deployment scout -o jsonpath='{.spec.template.metadata.labels.env}' 2>/dev/null || true)"
if [ "$object_label" != "production" ] || [ "$pod_label" != "production" ]; then
  echo "FAIL: label env=production is '${object_label}' on the Deployment and '${pod_label}' on the pod template"
  exit 1
fi
image="$(kubectl -n outpost get deployment scout -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || true)"
if [ "$image" != "ghcr.io/stefanprodan/podinfo:6.15.0" ]; then
  echo "FAIL: image is '${image}', expected 'ghcr.io/stefanprodan/podinfo:6.15.0'"
  exit 1
fi
applied="$(kubectl -n outpost get deployment scout -o jsonpath='{.metadata.annotations.kubectl\.kubernetes\.io/last-applied-configuration}' 2>/dev/null || true)"
if [ -z "$applied" ]; then
  echo "FAIL: scout was not created with kubectl apply -k"
  exit 1
fi
available="$(kubectl -n outpost get deployment scout -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
if [ "${available:-0}" != "2" ]; then
  echo "FAIL: scout in outpost has '${available:-0}' available replicas, expected 2"
  exit 1
fi

echo "PASS: scout in outpost comes from the overlay and is available"
