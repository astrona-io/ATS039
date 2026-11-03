#!/usr/bin/env bash
# Check: the repository (ConfigMap) was not edited to match the cluster.
set -uo pipefail

expected="$(kubectl -n lab-meta get configmap repo-fingerprint -o jsonpath='{.data.sha256}' 2>/dev/null || true)"
actual="$(kubectl -n gitops-repo get configmap desired-state -o jsonpath='{.data}' 2>/dev/null | shasum -a 256 | cut -d' ' -f1)"
if [ -z "$expected" ] || [ "$expected" != "$actual" ]; then
  echo "FAIL: the ConfigMap desired-state in gitops-repo was changed. The repository is the source of truth: change the cluster instead"
  exit 1
fi

echo "PASS: the repository is unchanged"
