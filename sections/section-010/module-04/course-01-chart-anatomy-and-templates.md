---
draft: true
exam_objectives:
  - Application Delivery
---
# Chart Anatomy And Templates

A Helm chart is a directory that holds Kubernetes manifests written as templates, a file of default values and a description of the chart. Helm combines the templates with the values and produces ordinary manifests. This part builds a small chart for a service called `beacon` and renders it without touching the cluster.

## The files of a chart

| Path | Purpose |
| --- | --- |
| `Chart.yaml` | Name, chart version and application version |
| `values.yaml` | Default values for the templates |
| `templates/` | Manifests with placeholders |
| `templates/_helpers.tpl` | Named snippets shared by templates |
| `charts/` | Charts this chart depends on |

The `version` in `Chart.yaml` is the version of the chart itself. The `appVersion` is the version of the software the chart deploys. They change independently: a template fix raises `version` and leaves `appVersion` alone.

<!-- astrona:playground:renew -->

Create the directory and save this as `beacon/Chart.yaml`:

```yaml
apiVersion: v2
name: beacon
description: A small example service
type: application
version: 0.1.0
appVersion: "6.15.0"
```

Save this as `beacon/values.yaml`:

```yaml
replicaCount: 1
image:
  repository: ghcr.io/stefanprodan/podinfo
  tag: "6.15.0"
ui:
  message: first
```

Save this as `beacon/templates/deployment.yaml`:

```yaml
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
```

Save this as `beacon/templates/service.yaml`:

```yaml
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
```

## Render the chart

Templates use the Go template language. The text between double braces is replaced. `.Values` is the merged values, `.Release` describes the installation, and `.Chart` holds the content of `Chart.yaml`. The pipe passes a value to a function, and `quote` wraps it in double quotes.

```sh
helm lint beacon
helm template demo beacon
```

`helm lint` checks the chart for errors. `helm template` prints the manifests Helm would send. It does not contact the cluster. The name `demo` becomes `.Release.Name`, so the Deployment is called `demo`. Try changing a value on the command line:

```sh
helm template demo beacon --set replicaCount=3 --set ui.message=hello
```

The output now shows `replicas: 3` and the message `hello`. The `--set` flag overrides one key of `values.yaml`.

## Flow control and helpers

Templates can branch and repeat. `if` includes a block only when a value is set, `range` repeats a block for each item of a list, and `with` changes the scope. Whitespace matters in YAML, so `toYaml` with `nindent` is the usual way to insert a block of values at the right depth. A snippet used by several templates goes into `_helpers.tpl` as a `define` block and is called with `include`.

## Common pitfalls

> [!WARNING]
> Template errors appear only when the chart is rendered, so run `helm lint` and `helm template` before every install. A missing key in `values.yaml` renders as an empty string, not as an error, which can produce a manifest that Kubernetes rejects or accepts with the wrong meaning. Quote string values with `quote`, because YAML turns an unquoted `true` or `1.10` into a boolean or a number.
