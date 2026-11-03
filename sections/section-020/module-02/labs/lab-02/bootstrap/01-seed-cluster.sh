#!/usr/bin/env bash
# Starting state for the lab: relay with a healthy revision and a revision whose image tag does not exist
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
mkdir -p /tmp/ats039-lab2
cat > /tmp/ats039-lab2/v1.yaml <<'EOF'
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
          ports:
            - name: http
              containerPort: 9898
          readinessProbe:
            httpGet:
              path: /readyz
              port: http
---
apiVersion: v1
kind: Service
metadata:
  name: relay
  namespace: outpost
spec:
  selector:
    app: relay
  ports:
    - name: http
      port: 80
      targetPort: http
EOF
cat > /tmp/ats039-lab2/v2.yaml <<'EOF'
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
          image: ghcr.io/stefanprodan/podinfo:6.15.999
          ports:
            - name: http
              containerPort: 9898
          readinessProbe:
            httpGet:
              path: /readyz
              port: http
---
apiVersion: v1
kind: Service
metadata:
  name: relay
  namespace: outpost
spec:
  selector:
    app: relay
  ports:
    - name: http
      port: 80
      targetPort: http
EOF
kubectl apply -f /tmp/ats039-lab2/v1.yaml
kubectl -n outpost rollout status deployment/relay --timeout=180s
kubectl apply -f /tmp/ats039-lab2/v2.yaml
sleep 5
echo "[lab] Ready."
