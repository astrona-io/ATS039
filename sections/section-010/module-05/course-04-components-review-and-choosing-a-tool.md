---
draft: true
exam_objectives:
  - Application Delivery
---
# Components, Review And Choosing A Tool

Large setups reuse parts of configuration across overlays. This part covers components, ways to review a change, and when Kustomize or Helm is the better tool.

## Components

A component is a reusable piece with its own `kustomization.yaml` of the kind `Component`. An overlay includes it under `components`. A component can add resources and patches, for example a monitoring sidecar, which several overlays want and the base should not have:

```yaml
apiVersion: kustomize.config.k8s.io/v1alpha1
kind: Component
patches:
  - path: add-sidecar.yaml
```

The overlay uses it with a relative path:

```yaml
components:
  - ../../components/sidecar
```

Components are applied after the resources, so they can patch what the base created. The group version `v1alpha1` is still in use for the kind; read the version of Kustomize that your `kubectl` carries with `kubectl version`.

## Remote bases

A `resources` entry can name a Git repository address with a path and a reference. This pulls a base from a repository at build time. Pin it to a tag or commit, never to a branch, because a branch changes under you.

## Review before applying

<!-- astrona:playground:renew -->

```sh
kubectl kustomize relay/overlays/production > /tmp/relay-production.yaml
kubectl diff -k relay/overlays/production
kubectl apply -k relay/overlays/production --dry-run=server
```

The first command writes the final YAML to a file that can be reviewed or committed. `kubectl diff -k` compares the result with the live objects and prints what would change. The server-side dry run asks the API server to validate the result without storing it. Reviewing the rendered output is the main way to catch a patch that did not do what you expected.

## Kustomize with GitOps

GitOps controllers such as Argo CD and Flux render Kustomize directories themselves. The directory in Git is the desired state, and an overlay per environment is a natural layout. The rendered output is what the controller applies, so reviewers should read it, not only the patch. Keep the version of Kustomize in the controller in mind: it can differ from the one in your `kubectl`.

## Kustomize or Helm

| Question | Kustomize | Helm |
| --- | --- | --- |
| Input is plain YAML you own | Yes | Needs templating |
| Many options for outside users | Weak | Strong, through values |
| Release history and rollback | None; the cluster controller does it | Built in |
| Logic, loops and conditionals | None | Go templates |

The two combine: Helm can render a third-party chart with `helm template`, and Kustomize can patch the output. Use that when you must change something the chart does not expose.

## Common pitfalls

> [!WARNING]
> A kustomization that mixes `resources`, `components` and many patches becomes hard to predict. Keep the order simple, and always read the rendered output. A remote base without a pinned reference can change your production deployment on the next render. `kubectl apply -k` does not delete objects that you removed from the kustomization, unless you use `--prune` with a label selector, so removed resources may stay in the cluster.
