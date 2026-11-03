---
draft: true
exam_objectives:
  - Application Delivery
---
# Repository Layout, Secrets And Environments

A GitOps repository holds everything the cluster runs, so its layout decides how safely a team can change production. Two questions come up on day one: how to separate environments, and how to keep secrets out of a repository that many people can read. This part answers both and explains how a change moves from one environment to the next through a pull request.

## One repository or two

A team can keep application source code and deployment configuration together or apart. In a single repository, one commit changes code and manifests, but every image build changes the same history that holds the manifests. In separate repositories, the application repository builds the image, and a configuration repository holds only desired state. Most teams that use GitOps choose a separate configuration repository. The pipeline of the application repository ends by opening a commit or a pull request in the configuration repository that sets the new image.

## Environments: folders or branches

Two layouts are common. In the folder layout, one branch holds a directory for each environment, and the directories are Kustomize overlays or Helm values files:

```text
apps/scout/base/
apps/scout/overlays/staging/
apps/scout/overlays/production/
```

In the branch layout, each environment has a long-lived branch, and promotion means merging one branch into the next. Folders are easier to compare, because a single `diff` shows the difference between environments, and they avoid merges that carry unrelated changes. For these reasons the folder layout is the usual advice.

## Promotion by pull request

In a pull-request model, promotion is a change to the production folder. A person or a bot changes the image reference in the production overlay, opens a pull request, reviewers approve and the merge triggers the controller. The approval gate of continuous delivery becomes a normal code review, and the history of the production folder is the list of everything released.

## Why secrets cannot be stored as they are

A Kubernetes Secret stores data in base64, which is an encoding and not encryption. Anyone with the repository can decode it. Committing a Secret manifest therefore publishes the secret. Three approaches keep the repository safe.

- Sealed Secrets. A controller in the cluster owns a private key. A developer encrypts a Secret with the public key using the `kubeseal` tool, and commits the resulting `SealedSecret`. Only the controller in that cluster can decrypt it and create the real Secret.
- SOPS (Secrets OPerationS). The `sops` tool encrypts the values inside a YAML file with a key from a cloud key management service or a tool such as age. Flux can decrypt SOPS files when it applies them.
- External Secrets Operator. The repository holds an `ExternalSecret` that names a secret in an outside store, such as HashiCorp Vault or a cloud secrets manager. The operator reads the value and creates the Secret in the cluster. The repository never holds the value.

## Show that base64 is not secrecy

Create a Secret and decode it:

<!-- astrona:playground:renew -->

```sh
kubectl -n outpost create secret generic relay-token --from-literal=token=s3cret-value
kubectl -n outpost get secret relay-token -o jsonpath='{.data.token}{"\n"}'
kubectl -n outpost get secret relay-token -o jsonpath='{.data.token}' | base64 -d
```

The second command prints the encoded text. The third prints `s3cret-value`. Here `kubectl` only decodes what the API server returns, and any person with the right to read Secrets can do the same. Access to Secrets must be limited with role-based access control (RBAC). Encryption at rest, which the API server can apply to Secrets in etcd, protects the stored data, and it does not hide a Secret from users who may read it through the API.

## What the controller needs

The controller needs read access to the repository and permission to create the kinds it applies. Use a deploy key or a token that can only read. Limit what each environment's controller may touch, for example with one namespace or one cluster per environment, so a mistake in staging cannot change production.

You now have the pieces of a GitOps workflow: a configuration repository, environment folders, review as the gate and secrets that stay encrypted. The remaining question is how to roll the release out to users in small steps, and that is a matter of deployment strategy.

## Common pitfalls

> [!WARNING]
> A deleted Secret stays in Git history. If a plain secret was ever committed, rotate it. Branch-per-environment layouts drift apart when merges are skipped. A controller bound to cluster-admin can change anything the repository says, so protect the branch with required reviews.
