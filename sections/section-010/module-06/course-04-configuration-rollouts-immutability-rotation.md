---
draft: true
exam_objectives:
  - Application Delivery
---
# Configuration Rollouts, Immutability And Rotation

A configuration change is a release. If it reaches pods unevenly, an incident is hard to explain. This part shows how to make configuration changes roll out in a controlled and reversible way.

## Tie configuration to the pod template

A Deployment starts a rollout only when its pod template changes. A change to a ConfigMap that the template refers to by name does not change the template. Two patterns solve this:

| Pattern | How it works |
| --- | --- |
| Name suffix | The name contains a hash of the content; a new content makes a new name. Kustomize generators do this |
| Checksum annotation | The template carries an annotation with the hash of the content. Helm charts use `sha256sum` on the rendered ConfigMap |
| Manual restart | `kubectl rollout restart deployment/NAME` replaces the pods and re-reads the values |

<!-- astrona:playground:renew -->

Try the manual restart and read the result in the history:

```sh
kubectl -n outpost create deployment cfgdemo --image=ghcr.io/stefanprodan/podinfo:6.15.0 --replicas=2
kubectl -n outpost set env deployment/cfgdemo --from=configmap/settings
kubectl -n outpost rollout status deployment/cfgdemo --timeout=120s
kubectl -n outpost patch configmap settings --type merge -p '{"data":{"LEVEL":"warn"}}'
kubectl -n outpost rollout restart deployment/cfgdemo
kubectl -n outpost rollout history deployment/cfgdemo
```

The restart adds a revision, because it writes a `restartedAt` annotation into the template. The rollout is rolling, so the readiness probe protects it as for any other change.

## Immutable ConfigMaps and Secrets

Setting `immutable: true` on a ConfigMap or Secret makes the data read-only. The API server rejects changes. The kubelet stops watching the object, which lowers load in large clusters. To change the data, create a new object with a new name and point the Deployment at it, which is a rollout. The old object stays in place, so a rollback restores the old configuration with the old template.

## Per-environment configuration

Keep the same image in every environment and let configuration carry the difference. Hold environment values in overlays or values files, one per environment, and review them like code. Do not place environment names in the image tag. Validate configuration before a rollout: render it, run `kubectl apply --dry-run=server`, and check that every referenced key exists.

## Rotation

Rotating a credential means a new value in the store, a new Secret in the cluster, pods that read it, and the end of the old value. Plan for a period in which both values work. Rotating a database password before pods use the new one causes an outage, so the sequence is: add the new credential, roll the pods, then remove the old credential.

## Common pitfalls

> [!WARNING]
> `rollout undo` restores the pod template, and with a fixed ConfigMap name the old template meets the new configuration, which is not a rollback of the configuration. Use versioned names or hashes to make configuration part of the revision. An immutable object cannot be fixed in place, so a typo needs a new name and a new rollout. Never rotate a credential by removing the old one first.
