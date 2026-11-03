# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Command output is not shown here, because this lab has not been run yet.

# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Command output is not shown here, because this lab has not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/module-06/labs/lab-01
```

## Step 1: Create the immutable ConfigMap

```sh
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: ledger-config-v2
  namespace: outpost
immutable: true
data:
  LEVEL: debug
EOF
astrona submit --keep
```

## Step 2: Create the Secret

```sh
kubectl -n outpost create secret generic ledger-token --from-literal=token=orbit-7
```

## Step 3: Change the Deployment

Edit the Deployment so that the environment variable reads `ledger-config-v2`, and add the volume and the mount:

```sh
kubectl -n outpost edit deployment ledger
```

The container needs `volumeMounts` with `name: token`, `mountPath: /etc/ledger-token` and `readOnly: true`, and the pod needs `volumes` with `name: token` and `secret.secretName: ledger-token`.

```sh
kubectl -n outpost rollout status deployment/ledger --timeout=180s
astrona submit
```
