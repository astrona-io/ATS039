---
draft: true
exam_objectives:
  - Application Delivery
---
# Delivering Secrets Without Putting Them In Git

GitOps keeps desired state in Git, but a plain Secret manifest in Git leaks the value. Three common approaches deliver secrets without publishing them. Each puts the secret in a different place.

## Encrypt in Git: sealed manifests

Sealed Secrets uses a controller in the cluster that owns a private key. A command-line tool, `kubeseal`, encrypts a Secret with the public key and produces a `SealedSecret` object. Only the controller can decrypt it. The encrypted file is safe to commit, and the controller creates a normal Secret from it. A SealedSecret is bound to a namespace and name by default, so it cannot be copied to a different place.

SOPS, short for Secrets OPerationS, encrypts the values inside a YAML file and leaves the keys readable. The key comes from a key management service or from an `age` key. Flux can decrypt SOPS files on its own, and Argo CD uses a plugin.

## Reference an external store

External Secrets Operator reads secrets from an external store, such as a cloud secret manager or HashiCorp Vault, and creates Kubernetes Secrets. Git holds only an `ExternalSecret` object, which names the secret in the store and the refresh interval. The secret value never enters Git. Rotation happens in the store, and the operator copies the new value on the next refresh.

## Skip the Secret object

The Secrets Store CSI driver mounts secrets from an external store as files in a pod through a volume. The data does not have to become a Kubernetes Secret. Workload identity lets the pod prove who it is to the store without a stored credential.

## Compare

| Approach | Secret in Git | Needs an outside system | Rotation |
| --- | --- | --- | --- |
| Plain Secret manifest | Readable | No | Edit and commit |
| Sealed Secrets | Encrypted | No | Reseal and commit |
| SOPS | Values encrypted | A key service or key file | Edit and commit |
| External Secrets Operator | No | A secret store | In the store |
| Secrets Store CSI driver | No | A secret store | In the store |

<!-- astrona:playground:renew -->

You can inspect how an application receives a secret without any of these tools. Create a Secret from a file kept outside of Git and check where the data lives:

```sh
printf 'orbit-9' > /tmp/token.txt
kubectl -n outpost create secret generic ledger-token-file --from-file=token=/tmp/token.txt
kubectl -n outpost get secret ledger-token-file -o jsonpath='{.metadata.name}{"\n"}'
```

The source file is the thing to protect: the Secret object in the cluster is only as safe as access to the namespace.

## What the controller needs

A GitOps controller applies what it finds in Git and needs the right to create Secrets. If it also decrypts, it holds the key, which makes the controller one of the most sensitive workloads in the cluster. Limit its access, keep its key in a separate store and audit changes to it.

## Common pitfalls

> [!WARNING]
> Deleting a plaintext Secret from Git does not remove it from the history. Treat any secret that was committed as leaked and rotate it. A SealedSecret whose controller key is lost cannot be decrypted, so back up the controller key. Rotation in an external store reaches pods only if the application re-reads the value or the pods restart.
