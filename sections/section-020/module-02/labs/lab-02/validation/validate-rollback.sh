#!/usr/bin/env bash
# Check: relay runs the good image with two available replicas.
set -uo pipefail

image="$(kubectl -n outpost get deployment relay -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || true)"
if [ "$image" != "ghcr.io/stefanprodan/podinfo:6.15.0" ]; then
  echo "FAIL: relay image is '${image}'"
  exit 1
fi
available="$(kubectl -n outpost get deployment relay -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
if [ "${available:-0}" != "2" ]; then
  echo "FAIL: ${available:-0} replicas are available, expected 2"
  exit 1
fi
echo "PASS: relay runs ${image} with 2 available replicas"
