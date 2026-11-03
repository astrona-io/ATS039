#!/usr/bin/env bash
# Starting state for the lab: a relay Deployment with a healthy revision and a stuck revision
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
mkdir -p /tmp/ats039-lab
cat > /tmp/ats039-lab/v1.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: relay
  namespace: outpost
  labels:
    app: relay
spec:
  replicas: 2
  progressDeadlineSeconds: 60
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
            - name: MODE
              value: v1
          ports:
            - name: http
              containerPort: 9898
          readinessProbe:
            httpGet:
              path: /readyz
              port: http
EOF
cat > /tmp/ats039-lab/v2.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: relay
  namespace: outpost
  labels:
    app: relay
spec:
  replicas: 2
  progressDeadlineSeconds: 60
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
            - name: MODE
              value: v2
          ports:
            - name: http
              containerPort: 9898
          readinessProbe:
            httpGet:
              path: /does-not-exist
              port: http
EOF
kubectl apply -f /tmp/ats039-lab/v1.yaml
kubectl -n outpost rollout status deployment/relay --timeout=180s
kubectl apply -f /tmp/ats039-lab/v2.yaml
sleep 5
echo "[lab] Ready."
