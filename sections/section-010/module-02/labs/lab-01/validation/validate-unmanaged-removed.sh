#!/usr/bin/env bash
# Check: the Deployment that the repository does not list is gone.
set -uo pipefail

if kubectl -n starfleet get deployment debug-tools >/dev/null 2>&1; then
  echo "FAIL: Deployment debug-tools still exists in starfleet"
  exit 1
fi

echo "PASS: debug-tools is removed"
