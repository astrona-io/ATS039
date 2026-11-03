#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Blue-green: confirm green is ready, then switch the Service selector.
kubectl -n starfleet rollout status deployment/scout-green --timeout=120s
kubectl -n starfleet patch service scout --patch-file "$DIR/solution.yaml"

# probe: abandon the bad revision.
kubectl -n starfleet rollout undo deployment/probe
kubectl -n starfleet rollout status deployment/probe --timeout=180s
echo "[solution] Applied."
