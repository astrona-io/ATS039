---
draft: true
exam_objectives:
  - Application Delivery
---
# Summary

Kustomize customizes plain manifests. A base holds manifests that work alone. An overlay lists the base as a resource and changes it with transformers such as `namespace`, `namePrefix`, `labels`, `images` and `replicas`, and with strategic merge patches and JSON 6902 patches. The base is never edited for one environment.

Generators create ConfigMaps and Secrets from literals and files. By default the generated name contains a hash of the content, so a change creates a new name, changes the pod template and starts a rollout. An overlay changes generated data with the same generator name and the behavior `merge` or `replace`.

Components share optional pieces between overlays. Review a result with `kubectl kustomize`, `kubectl diff -k` and a server-side dry run before `kubectl apply -k`. Kustomize has no release history. Helm has one but needs templates.

- The input and the output are plain Kubernetes YAML.
- A patch uses the name from the base, not the prefixed name.
- The name suffix hash ties configuration changes to rollouts.
- Read the rendered output before every apply.

<!-- astrona:playground:destroy -->
