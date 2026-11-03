#!/usr/bin/env bash
# Check: ledger matches the replica count it declares.
set -uo pipefail

want="$(kubectl -n outpost get deployment ledger -o jsonpath='{.metadata.annotations.gitops/desired-replicas}' 2>/dev/null || true)"
have="$(kubectl -n outpost get deployment ledger -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
if [ -z "$want" ] || [ "$want" != "$have" ]; then
  echo "FAIL: replicas are '${have}', declared '${want}'"
  exit 1
fi
echo "PASS: ledger has ${have} replicas as declared"
