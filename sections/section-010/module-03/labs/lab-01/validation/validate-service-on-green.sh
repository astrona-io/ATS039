#!/usr/bin/env bash
# Check: the Service scout selects green, and green answers.
set -uo pipefail

version="$(kubectl -n starfleet get service scout -o jsonpath='{.spec.selector.version}' 2>/dev/null || true)"
if [ "$version" != "green" ]; then
  echo "FAIL: the Service scout selects version '${version}', expected 'green'"
  exit 1
fi
answer="$(kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 http://scout.starfleet.svc.cluster.local/ 2>/dev/null || true)"
if [[ "$answer" != *scout-green* ]]; then
  echo "FAIL: the scout Service does not answer with the green message"
  exit 1
fi

echo "PASS: the Service sends traffic to green"
