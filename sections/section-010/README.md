---
draft: true
exam_objectives:
  - Application Delivery
---
# Application Delivery

This section teaches build and release pipelines; gitops and deployment configuration; safe application releases. These ideas help you explain system behavior and choose a suitable approach in a KCNA scenario.

You will work through Build And Release Pipelines, GitOps And Deployment Configuration, Safe Application Releases. Each module introduces its goals, teaches the concepts through examples and a playground, adds a graded lab after the last part, and closes with a summary. The section ends with a capstone lab and a knowledge check with answer explanations.

## Learning Outcomes

- Compare CI/CD tools and explain pipeline definitions as code.
- Explain image signing, SBOMs and supply chain controls.
- State the four OpenGitOps principles and compare push with pull delivery.
- Describe Argo CD and Flux resources.
- Compare recreate, A/B, shadow and feature flag strategies and explain progressive delivery tools.
- Explain what a rollback restores and what it cannot.

- Trace source changes through build, checks and artifact publication.
- Explain what continuous integration checks.
- Distinguish continuous delivery from continuous deployment.
- Relate release identity to an immutable artifact.
- Explain declarative, versioned desired state.
- Describe pull-based reconciliation and drift correction.
- Compare Helm templating with Kustomize overlays.
- Identify what a GitOps controller cannot infer from repository state.
- Explain rolling update behavior and readiness gates.
- Compare rolling, blue-green and canary strategies.
- Identify evidence needed to promote or reverse a release.
- Explain compatibility limits of rollback.
- Describe the files of a Helm chart and how templates use values.
- Install, upgrade, inspect and roll back a Helm release.
- Predict which value wins when several sources set the same key.
- Explain what chart repositories, dependencies and hooks add.
- Describe the roles of a base, an overlay and a kustomization file.
- Change an environment with transformers, strategic merge patches and JSON patches.
- Explain how generators and name suffix hashes trigger rollouts.
- Review a Kustomize result before applying it.
- Compare environment variables and mounted files as ways to read configuration.
- Explain what a Secret protects and what protects it further.
- Choose a method to deliver secrets with a GitOps workflow.
- Make a configuration change roll out in a controlled way.
- Tune maxSurge, maxUnavailable, minReadySeconds and the deadline of a rollout.
- Explain what a PodDisruptionBudget protects and what it does not.
- Describe how a pod shuts down and configure it for graceful shutdown.
- Explain how spreading and capacity limits affect a rollout.
