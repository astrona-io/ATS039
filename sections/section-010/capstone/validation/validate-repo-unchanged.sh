#!/usr/bin/env bash
# Check: the repository (ConfigMap) was not edited.
set -uo pipefail

expected="$(kubectl -n lab-meta get configmap repo-fingerprint -o jsonpath='{.data.sha256}' 2>/dev/null || true)"
actual="$(kubectl -n delivery-repo get configmap delivery-repo -o jsonpath='{.data}' 2>/dev/null | shasum -a 256 | cut -d' ' -f1)"
if [ -z "$expected" ] || [ "$expected" != "$actual" ]; then
  echo "FAIL: the ConfigMap delivery-repo was changed. The repository is the source of truth: put changes in the overlay"
  exit 1
fi

echo "PASS: the repository is unchanged"
