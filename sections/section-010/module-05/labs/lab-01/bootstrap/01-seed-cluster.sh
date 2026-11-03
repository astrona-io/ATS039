#!/usr/bin/env bash
# Starting state for the lab: a Kustomize base on disk and no overlay
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
mkdir -p /tmp/ats039-lab/kustomize/base /tmp/ats039-lab/kustomize/overlays/production
cat > /tmp/ats039-lab/kustomize/base/deployment.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: relay
spec:
  replicas: 1
  selector:
    matchLabels:
      app: relay
  template:
    metadata:
      labels:
        app: relay
    spec:
      containers:
        - name: relay
          image: ghcr.io/stefanprodan/podinfo:6.15.0
          env:
            - name: PODINFO_UI_MESSAGE
              valueFrom:
                configMapKeyRef:
                  name: relay-config
                  key: MESSAGE
          ports:
            - name: http
              containerPort: 9898
EOF
cat > /tmp/ats039-lab/kustomize/base/kustomization.yaml <<'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
configMapGenerator:
  - name: relay-config
    literals:
      - MESSAGE=base
EOF
echo "[lab] Ready."
