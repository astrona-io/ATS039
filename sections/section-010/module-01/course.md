---
draft: true
exam_objectives:
  - Application Delivery
---
# Build And Release Pipelines

A delivery pipeline is a fixed series of automated steps that turns a source change into software running in an environment. Each step either produces evidence, such as a test result or an image, or it stops the change. This module shows what each step checks, what it proves and what it leaves unproven. It also shows how the same tested artifact moves from one environment to the next.

The module has two parts. The first part follows a source change through the build, the automated checks and the publication of an image, and shows how to read an image's identity in a cluster. The second part explains the difference between continuous delivery and continuous deployment, and promotes one image from a staging namespace to a production namespace while only the configuration changes.

## Learning goals

After this module you can:

- Trace a source change through build, checks and artifact publication.
- Explain what continuous integration (CI) checks and what a passing check does not prove.
- Distinguish continuous delivery from continuous deployment.
- Relate a release identity to an immutable artifact, such as an image digest.
- Promote one image reference to a second environment and change only the configuration.

## Before you start

You need Kubernetes basics: namespaces, pods, Deployments, Services, ConfigMaps, and the commands `kubectl get`, `kubectl apply`, `kubectl describe` and `kubectl annotate`. A Kubernetes cluster is not a pipeline tool. The playground uses Kubernetes Jobs to stand in for pipeline steps, because a Job runs a process to the end and records whether it exited with success or failure. That is the same signal a real pipeline stage uses.

Your playground is a single-node `kind` cluster running Kubernetes 1.35:

| Namespace | What is in it |
| --- | --- |
| `starfleet` | The `scout` Deployment (two replicas of the `podinfo` image), its Service, `probe` (`go-httpbin`) and `shuttle` (a `curl` client). This namespace plays the staging environment |
| `outpost` | The `drifter` client. This namespace plays the production environment |

`kubectl` already points at the playground cluster, as the cluster administrator. Launch your playground now and keep it running next to you while you read:

<!-- astrona:playground -->
