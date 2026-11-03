#!/usr/bin/env bash
# Check: the Service scout in outpost has four endpoints, three stable and one canary.
set -uo pipefail

stable="$(kubectl -n outpost get pods -l app=scout,track=stable --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l | tr -d ' ')"
canary="$(kubectl -n outpost get pods -l app=scout,track=canary --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l | tr -d ' ')"
endpoints="$(kubectl -n outpost get endpoints scout -o jsonpath='{.subsets[*].addresses[*].ip}' 2>/dev/null | wc -w | tr -d ' ')"
if [ "$stable" != "3" ] || [ "$canary" != "1" ]; then
  echo "FAIL: found ${stable} stable and ${canary} canary running pods, expected 3 and 1"
  exit 1
fi
if [ "$endpoints" != "4" ]; then
  echo "FAIL: the Service scout has ${endpoints} endpoints, expected 4 (a 3:1 split)"
  exit 1
fi

echo "PASS: the Service scout spreads traffic over 3 stable and 1 canary endpoint"
