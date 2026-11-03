---
draft: true
exam_objectives:
  - Application Delivery
---
# Values, Precedence And Checks

A chart is useful because the same templates serve many environments. The values differ. This part explains where values come from, which one wins and how to check a chart before it reaches the cluster.

## Sources and precedence

Helm builds one set of values from several sources. A later source overrides an earlier one:

1. The `values.yaml` file in the chart.
2. The values of a parent chart, when the chart is a dependency.
3. Files passed with `-f` or `--values`, in the order given. A later file wins.
4. Single keys passed with `--set`, `--set-string` or `--set-file`.

Maps are merged key by key. Lists are replaced as a whole, so a list in an override file replaces the complete list from the default values.

<!-- astrona:playground:renew -->

Save this as `production.yaml`:

```yaml
replicaCount: 3
ui:
  message: production
```

Save this as `canary.yaml`:

```yaml
ui:
  message: canary
```

Render with both files and one `--set`:

```sh
helm template demo beacon -f production.yaml -f canary.yaml --set replicaCount=5
```

The result has five replicas, because `--set` comes last. The message is `canary`, because `canary.yaml` was passed after `production.yaml`. The image stays at the chart default, because no source changes it.

## Typed values

`--set` converts text to a type. `--set ui.message=true` becomes a boolean, not the text `true`. Use `--set-string` when the value must stay text. Dots in a key create nesting, and a literal dot must be escaped with a backslash. For anything larger than a few keys, a values file is clearer and can be reviewed and stored in version control.

## Check before installing

| Check | What it finds |
| --- | --- |
| `helm lint` | Chart structure and template syntax errors |
| `helm template` | The exact manifests, for review |
| `helm install --dry-run=server` | Errors the API server reports, such as unknown fields |
| `values.schema.json` | Wrong types and missing required values |

A `values.schema.json` file in the chart is a JSON Schema document. Helm checks the merged values against it on `lint`, `template`, `install` and `upgrade`. A schema that requires `replicaCount` to be an integer of at least 1 turns a typing mistake into an immediate error.

You can also make a template demand a value with the `required` function, for example `{{ required "image.tag is required" .Values.image.tag }}`, which stops rendering with the given message when the value is empty.

```sh
helm install demo beacon --namespace outpost --dry-run=server -f production.yaml
```

A dry run contacts the API server and renders the result without storing a release. Use `--dry-run=client` when no cluster is reachable. Check `helm install --help` of your Helm version, because older Helm 3 releases accept a bare `--dry-run` instead.

## Records of what was used

`helm get values RELEASE` prints only the values you supplied, and `--all` adds the chart defaults. Together with the chart version from `helm list` they describe a release completely. Store the values files in version control with the chart version, so that a release can be rebuilt.

## Common pitfalls

> [!WARNING]
> A list in an override file replaces the default list instead of adding to it, so an override of `ports` or `env` can delete entries you did not mention. Passing secrets with `--set` leaves them in shell history and in the release Secret, which anyone with read access to Secrets in the namespace can decode. Keep secret material out of values files in version control.
