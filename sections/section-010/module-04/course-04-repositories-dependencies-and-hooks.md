---
draft: true
exam_objectives:
  - Application Delivery
---
# Repositories, Dependencies And Hooks

Charts are shared, not only written locally. This part covers where charts are stored, how a chart depends on other charts, how hooks run tasks around a release, and when Helm is the wrong tool.

## Repositories and OCI registries

A chart repository is a web server with an `index.yaml` file that lists chart versions and packaged archives with the ending `.tgz`. You add it by name, search it and install from it:

```sh
helm repo add examples https://example.invalid/charts
helm repo update
helm search repo examples/beacon --versions
helm install beacon examples/beacon --version 0.1.0 --namespace outpost
```

The address above is a placeholder, so these commands show the shape and are not meant to be run as written. A second way is an OCI registry. OCI is the Open Container Initiative, the standard that container registries follow, and registries can store charts as well as images. There is no `repo add` step; the address is used directly:

```sh
helm package beacon
helm push beacon-0.1.0.tgz oci://registry.example.invalid/charts
helm install beacon oci://registry.example.invalid/charts/beacon --version 0.1.0
```

`helm package` creates the archive. The version in `Chart.yaml` becomes the tag in the registry. Pin the version on install, so that a later chart release does not change a deployment unnoticed. A chart version, like an image tag, can be republished in some registries, so pinning a digest is stronger when the registry supports it.

## Dependencies

A chart can include other charts. List them in `Chart.yaml`:

```yaml
dependencies:
  - name: redis
    version: "19.x.x"
    repository: oci://registry.example.invalid/charts
    condition: redis.enabled
```

`helm dependency update beacon` downloads the charts into `charts/` and writes `Chart.lock`, which records exact versions. `helm dependency build` restores them from the lock file. The values of a dependency are set under a key with its name, here `redis`. The `condition` lets a user switch the dependency off.

## Hooks

A hook is a manifest with the annotation `helm.sh/hook`. Helm runs it at a point of the release instead of treating it as a normal object. The common points are `pre-install`, `post-install`, `pre-upgrade`, `post-upgrade`, `pre-delete` and `test`. A database migration Job with `helm.sh/hook: pre-upgrade` runs before the new pods start. The annotation `helm.sh/hook-weight` orders hooks, and `helm.sh/hook-delete-policy` says when Helm removes the finished Job.

A hook is not part of the release revision. Helm does not track or delete it with `helm uninstall` unless a delete policy says so. A failed `pre-upgrade` hook stops the upgrade.

## Helm or plain manifests

| Situation | Better fit |
| --- | --- |
| Third-party software with many options | Helm chart from the vendor |
| One application, a few environments | Plain manifests with overlays |
| Release history and rollback as one command | Helm |
| Review of exact changes in Git | Rendered manifests or an overlay tool |

GitOps tools can install Helm charts, but then the tool, not the `helm` command, owns the release. Do not mix `helm upgrade` by hand with a GitOps controller that manages the same release.

## Common pitfalls

> [!WARNING]
> A chart from a repository you do not control can create any object, including cluster roles. Read the rendered output of `helm template` before you install a chart, pin the version, and prefer charts you can verify. Dependencies need `helm dependency build` after a fresh clone, because the `charts/` directory is usually not committed.
