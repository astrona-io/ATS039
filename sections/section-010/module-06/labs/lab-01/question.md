# Question

Solve this question on: `terminal`

The `ledger` Deployment in `outpost` has two replicas. It reads the setting `PODINFO_LEVEL` from the ConfigMap `ledger-config` through an environment variable.

1. Create a new ConfigMap `ledger-config-v2` in `outpost` with the key `LEVEL` set to `debug`. Make it immutable.

2. Change `ledger` so that `PODINFO_LEVEL` reads the key `LEVEL` from `ledger-config-v2`. Wait until both replicas are updated and available.

3. Create a Secret `ledger-token` of the type `Opaque` with the key `token` set to `orbit-7`.

4. Mount the Secret into the `ledger` container as a volume at `/etc/ledger-token`, read-only.

`kubectl` already points at the cluster as the cluster administrator.
