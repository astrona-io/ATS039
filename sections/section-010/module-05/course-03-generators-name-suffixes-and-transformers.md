---
draft: true
exam_objectives:
  - Application Delivery
---
# Generators, Name Suffixes And Transformers

Some objects are made from files or literal values, such as ConfigMaps. Kustomize generates them, and the generated name changes whenever the content changes. That behavior links configuration changes to rollouts.

## Generators

Add a ConfigMap generator to `relay/base/kustomization.yaml`:

<!-- astrona:playground:renew -->

```yaml
configMapGenerator:
  - name: relay-config
    literals:
      - MESSAGE=base
```

Reference the ConfigMap in the container of `relay/base/deployment.yaml`, under `containers`, next to `image`:

```yaml
          env:
            - name: PODINFO_UI_MESSAGE
              valueFrom:
                configMapKeyRef:
                  name: relay-config
                  key: MESSAGE
```

Render the base. The ConfigMap is named `relay-config-` followed by a hash of its content, and the reference in the Deployment uses the same name. Kustomize rewrites name references for ConfigMaps and Secrets in the known places in a pod template.

## Why the suffix matters

A Deployment does not restart when a ConfigMap it reads changes. With the suffix, a content change produces a new ConfigMap name, which changes the pod template, which starts a rolling update. The old ConfigMap stays until the next prune. The effect is a rollout that is caused by the configuration change, with the old revision still pointing at the old data, so a rollback restores the old configuration too.

The suffix can be turned off with `generatorOptions` and `disableNameSuffixHash: true`. Then a change updates the ConfigMap in place and the pods do not restart.

## Merging in an overlay

An overlay changes generated data with the same generator name and a `behavior`:

| Behavior | Result |
| --- | --- |
| `create` | Creates a new ConfigMap; the default |
| `merge` | Keeps the base keys and sets the keys given |
| `replace` | Replaces the whole ConfigMap |

```yaml
configMapGenerator:
  - name: relay-config
    behavior: merge
    literals:
      - MESSAGE=production
```

The name matches the name in the base, before any prefix. Render the production overlay, and the ConfigMap is called `prod-relay-config-` plus a new hash, with the message `production`. The Deployment refers to it.

## Secrets

`secretGenerator` works like `configMapGenerator` and creates a Secret from literals, files or an env file, with the same name suffix. The values are stored encoded, not encrypted, and the source files hold them in plain text. Do not commit a secret generator that contains real credentials. A later module covers safer ways to deliver secrets.

## Other transformers

Kustomize also has `replacements`, which copy a field value from one resource into fields of others, for example an image tag from one place into several environment variables. It replaces the older `vars`. Use it for a value that must agree in several places, and keep the number of replacements small because they are hard to read.

## Common pitfalls

> [!WARNING]
> The hash suffix is computed from the generated data only. If a container reads the ConfigMap through a mounted file or an environment variable that Kustomize does not recognise as a reference, the name in the pod template is not rewritten and the pod points at a name that does not exist. Check the rendered Deployment for the final ConfigMap name. Old generated ConfigMaps remain in the cluster after a change, so prune or clean up on a schedule.
