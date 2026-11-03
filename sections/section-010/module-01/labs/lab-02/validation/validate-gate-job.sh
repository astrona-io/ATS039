#!/usr/bin/env bash
# Check: The Job gate-checks completed with two ordered init containers.
set -uo pipefail

succeeded="$(kubectl -n starfleet get job gate-checks -o jsonpath='{.status.succeeded}' 2>/dev/null || true)"
if [ "${succeeded:-0}" != "1" ]; then
  echo "FAIL: Job gate-checks has '${succeeded:-0}' successful completions, expected 1"
  exit 1
fi
names="$(kubectl -n starfleet get job gate-checks -o jsonpath='{.spec.template.spec.initContainers[*].name}' 2>/dev/null || true)"
if [ "$names" != "build-check smoke-check" ]; then
  echo "FAIL: init containers are '${names}', expected 'build-check smoke-check'"
  exit 1
fi
echo "PASS: gate-checks completed with init containers '${names}'"
