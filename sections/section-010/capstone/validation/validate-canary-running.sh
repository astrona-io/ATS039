#!/usr/bin/env bash
# Check: scout-canary runs one replica and its pods are selected by the Service scout.
set -uo pipefail

g() { kubectl -n outpost get deployment scout-canary -o jsonpath="$1" 2>/dev/null || true; }
replicas="$(g '{.spec.replicas}')"
if [ "$replicas" != "1" ]; then
  echo "FAIL: scout-canary has spec.replicas '${replicas}', expected 1"
  exit 1
fi
app="$(g '{.spec.template.metadata.labels.app}')"
track="$(g '{.spec.template.metadata.labels.track}')"
if [ "$app" != "scout" ] || [ "$track" != "canary" ]; then
  echo "FAIL: the pod labels of scout-canary are app='${app}' track='${track}', expected app=scout and track=canary"
  exit 1
fi
message="$(g '{.spec.template.spec.containers[0].env[?(@.name=="PODINFO_UI_MESSAGE")].value}')"
if [ "$message" != "scout-canary" ]; then
  echo "FAIL: PODINFO_UI_MESSAGE of scout-canary is '${message}', expected 'scout-canary'"
  exit 1
fi
available="$(g '{.status.availableReplicas}')"
if [ "${available:-0}" != "1" ]; then
  echo "FAIL: scout-canary has '${available:-0}' available replicas, expected 1"
  exit 1
fi

echo "PASS: scout-canary runs one replica labelled app=scout, track=canary"
