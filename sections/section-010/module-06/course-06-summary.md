---
draft: true
exam_objectives:
  - Application Delivery
---
# Summary

A pod reads a ConfigMap or Secret as environment variables or as mounted files. Environment variables are fixed at container start. A mounted volume is refreshed after a delay, except with `subPath`. A missing reference stops the container with `CreateContainerConfigError`.

A Secret is Base64 encoded, not encrypted. Protection comes from access rules, encryption at rest in etcd, and limiting who can create pods in the namespace. Files with a restrictive mode are safer than environment variables.

To keep secrets out of Git, encrypt them with Sealed Secrets or SOPS, or reference an external store with External Secrets Operator or the Secrets Store CSI driver. A configuration change must change the pod template to start a rollout, through a hash in the name, a checksum annotation or a restart. Immutable objects with new names make a rollback restore both template and configuration. Rotate a credential by adding the new one first and removing the old one last.

- Base64 is not encryption.
- A committed secret is leaked and must be rotated.
- Environment variables do not follow ConfigMap updates.
- Versioned names make configuration part of the revision.

<!-- astrona:playground:destroy -->
