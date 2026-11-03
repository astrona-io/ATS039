#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

cat > /tmp/ats039-lab/kustomize/overlays/production/limits.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: relay
spec:
  template:
    spec:
      containers:
        - name: relay
          resources:
            limits:
              memory: 128Mi
EOF
cat > /tmp/ats039-lab/kustomize/overlays/production/kustomization.yaml <<'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base
namespace: outpost
namePrefix: prod-
replicas:
  - name: relay
    count: 3
configMapGenerator:
  - name: relay-config
    behavior: merge
    literals:
      - MESSAGE=production
patches:
  - path: limits.yaml
EOF
kubectl apply -k /tmp/ats039-lab/kustomize/overlays/production
kubectl -n outpost rollout status deployment/prod-relay --timeout=180s
echo "[solution] Applied."
