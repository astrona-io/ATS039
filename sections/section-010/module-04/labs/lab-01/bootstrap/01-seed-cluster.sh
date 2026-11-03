#!/usr/bin/env bash
# Starting state for the lab: a Helm chart on disk and release beacon at revision 1
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
mkdir -p /tmp/ats039-lab/beacon/templates
cat > /tmp/ats039-lab/beacon/Chart.yaml <<'EOF'
apiVersion: v2
name: beacon
description: A small example service
type: application
version: 0.1.0
appVersion: "6.15.0"
EOF
cat > /tmp/ats039-lab/beacon/values.yaml <<'EOF'
replicaCount: 1
image:
  repository: ghcr.io/stefanprodan/podinfo
  tag: "6.15.0"
ui:
  message: first
EOF
cat > /tmp/ats039-lab/beacon/templates/deployment.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}
  labels:
    app: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          env:
            - name: PODINFO_UI_MESSAGE
              value: {{ .Values.ui.message | quote }}
          ports:
            - name: http
              containerPort: 9898
          readinessProbe:
            httpGet:
              path: /readyz
              port: http
EOF
cat > /tmp/ats039-lab/beacon/templates/service.yaml <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}
spec:
  selector:
    app: {{ .Release.Name }}
  ports:
    - name: http
      port: 80
      targetPort: http
EOF
helm install beacon /tmp/ats039-lab/beacon --namespace outpost --wait --timeout 3m
echo "[lab] Ready."
