#!/usr/bin/env bash
# Check: The PodDisruptionBudget dock-pdb requires 3 available pods for app dock.
set -uo pipefail

min="$(kubectl -n outpost get pdb dock-pdb -o jsonpath='{.spec.minAvailable}' 2>/dev/null || true)"
sel="$(kubectl -n outpost get pdb dock-pdb -o jsonpath='{.spec.selector.matchLabels.app}' 2>/dev/null || true)"
if [ "$min" != "3" ] || [ "$sel" != "dock" ]; then
  echo "FAIL: minAvailable '${min}' and selector app '${sel}'"
  exit 1
fi
echo "PASS: dock-pdb has minAvailable 3 for app dock"
