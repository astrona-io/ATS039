#!/usr/bin/env bash
# Check: The pod sleeper has an ephemeral container named inspector.
set -uo pipefail

names="$(kubectl -n outpost get pod sleeper -o jsonpath='{.spec.ephemeralContainers[*].name}' 2>/dev/null || true)"
case " $names " in
  *" inspector "*) echo "PASS: ephemeral container inspector is attached" ;;
  *) echo "FAIL: ephemeral containers are '${names}'"; exit 1 ;;
esac
