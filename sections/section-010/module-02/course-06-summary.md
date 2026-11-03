---
draft: true
exam_objectives:
  - Application Delivery
---
# Summary

GitOps keeps the desired state of a system as declarative manifests in a version-controlled repository. An agent inside the cluster pulls the repository, compares it with the live state and applies the difference. Every change then has an author, a review and a history, and a rollback is another commit.

Drift is any live difference that did not come from the repository. The reconciliation loop finds it with a comparison, such as `kubectl diff`, and corrects it by applying the desired state again. It also deletes objects that the repository no longer lists, when it can identify the objects it owns. The controller cannot know the intent of a manual change, cannot restore data, cannot read Secrets that were kept out of the repository and cannot tell whether the application is healthy for users.

Helm and Kustomize produce the manifests that the repository holds. Helm fills templates with values and records each release revision. Kustomize applies patches from an overlay to a valid base. Templates give flexibility and logic, and overlays give plain, reviewable YAML.

- Desired state is declarative, versioned and pulled.
- Reconciliation compares live state with desired state continuously.
- Prune removes what the repository does not list.
- Helm is templating plus values; Kustomize is a base plus overlays.

<!-- astrona:playground:destroy -->
