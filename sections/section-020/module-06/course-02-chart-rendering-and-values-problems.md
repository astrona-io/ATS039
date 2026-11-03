---
draft: true
exam_objectives:
  - Debugging
---
# Chart Rendering And Values Problems

Many failures come from what the chart renders, not from the cluster. Rendering a chart locally shows the objects before they are sent. This is the safest first step for a template or values problem.

<!-- astrona:playground:renew -->

## Render and lint

```sh
helm lint ./chart
helm template RELEASE ./chart -n NAMESPACE -f values.yaml
helm template RELEASE ./chart --debug
```

`lint` checks the chart for errors and warnings. `template` renders the objects to standard output without contacting the cluster. `--debug` prints the rendered text even when it is not valid YAML, so you can see where it breaks. A common message is `error converting YAML to JSON` with a line number in the rendered output, not in the template file. Search the rendered output for that line.

Check the rendered image, ports, labels and selectors, since a mismatch between the Service selector and the pod labels is a delivery mistake as well as a runtime one.

## Dry run against the cluster

```sh
helm upgrade --install RELEASE ./chart -n NAMESPACE --dry-run --debug
helm template RELEASE ./chart | kubectl apply --dry-run=server -f -
```

A server-side dry run sends the objects to the API server for validation without saving them. It finds rejected fields, missing CRDs and webhook denials that a local render cannot see.

## Values problems

- A key in `values.yaml` that is misspelled is ignored silently. The chart uses the default and nothing fails. Compare `helm get values RELEASE --all` with what you expected.
- A value of the wrong type, such as the string `"true"` where a boolean is needed, can render different output.
- Several `-f` files and `--set` flags merge, and the last one wins. A `--set` flag in a pipeline can override your file.
- A list in a later file replaces the whole list, it does not add to it.
- Values for a subchart go under the subchart name.

Print the final merged values for a render:

```sh
helm template RELEASE ./chart -f base.yaml -f prod.yaml --show-only templates/deployment.yaml
```

`--show-only` renders one file of the chart, which makes the comparison short.

## Kustomize output

```sh
kubectl kustomize ./overlays/prod
kubectl apply -k ./overlays/prod --dry-run=server
```

`kubectl kustomize` shows the final objects. A patch that does not match a target fails with a message about no matches, and a changed name prefix can break a reference from another object.

## Common pitfalls

> [!WARNING]
> A render that works locally can still fail in the cluster, because the server checks the API versions and the schema of its own version. Run the server-side dry run as well. Keep `--set` flags out of pipelines when you can, since they are not in the repository and hide why a release differs from the files. Do not paste a Secret value into `values.yaml` in the repository.
