#!/usr/bin/env bash
# Check: The token Secret is mounted read-only at /etc/ledger-token.
set -uo pipefail

sec="$(kubectl -n outpost get deployment ledger -o jsonpath='{.spec.template.spec.volumes[?(@.secret.secretName=="ledger-token")].name}' 2>/dev/null || true)"
if [ -z "$sec" ]; then
  echo "FAIL: no volume uses the Secret ledger-token"
  exit 1
fi
ro="$(kubectl -n outpost get deployment ledger -o jsonpath='{.spec.template.spec.containers[0].volumeMounts[?(@.mountPath=="/etc/ledger-token")].readOnly}' 2>/dev/null || true)"
if [ "$ro" != "true" ]; then
  echo "FAIL: /etc/ledger-token is not mounted read-only"
  exit 1
fi
val="$(kubectl -n outpost get secret ledger-token -o jsonpath='{.data.token}' 2>/dev/null | base64 -d 2>/dev/null || true)"
if [ "$val" != "orbit-7" ]; then
  echo "FAIL: the token is '${val}', expected orbit-7"
  exit 1
fi
echo "PASS: ledger-token is mounted read-only at /etc/ledger-token"
