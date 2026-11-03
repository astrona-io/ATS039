#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

helm upgrade beacon /tmp/ats039-lab/beacon --namespace outpost --set replicaCount=3 --set ui.message=second --wait --timeout 3m
helm upgrade beacon /tmp/ats039-lab/beacon --namespace outpost --reuse-values --set ui.message=third --wait --timeout 3m
helm rollback beacon 2 --namespace outpost --wait --timeout 3m
echo "[solution] Applied."
