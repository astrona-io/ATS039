---
draft: true
exam_objectives:
  - Application Delivery
---
# Summary

A Helm chart is a directory of templates, default values and a description. Helm renders the templates with the merged values and applies the result. An installation is a release; every change creates a numbered revision that Helm stores as a Secret in the namespace of the release.

`helm install` creates a release, `helm upgrade` adds a revision, `helm rollback` adds a revision with the content of an earlier one, and `helm uninstall` removes the objects. Values come from the chart defaults, then files in the order given, then `--set`. Maps merge by key and lists are replaced. Without `--reuse-values` or the same values files, an upgrade returns unset values to their defaults.

Charts are stored in repositories or in OCI registries and are pinned by version. Dependencies are listed in `Chart.yaml` and locked in `Chart.lock`. Hooks run Jobs at points of the release. Check a chart with `helm lint`, `helm template` and a dry run before an install.

- The chart version and the application version are different fields.
- Helm state lives in Secrets, not in a server.
- A rollback restores objects, not data.
- Do not manage one release with both Helm and a GitOps controller.

<!-- astrona:playground:destroy -->
