# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Command output is not shown here, because this lab has not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/module-02/labs/lab-02
```

## Step 1: Compare the live state with the repository

Write the repository content to a file and compare:

```sh
kubectl -n gitops-repo get configmap desired-state -o jsonpath='{.data.relay\.yaml}' > relay.yaml
kubectl diff -f relay.yaml
```

`kubectl diff` exits with code 1 when there is a difference, and it shows that `replicas` differs.

## Step 2: Apply the repository state

```sh
kubectl apply -f relay.yaml
kubectl -n outpost rollout status deployment/relay --timeout=180s
astrona submit --keep
```

## Step 3: Prune the object the repository does not list

List what carries the label, then delete the stray one:

```sh
kubectl -n outpost get deployments -l app.kubernetes.io/part-of=relay
kubectl -n outpost delete deployment stray
astrona submit --keep
```

## Step 4: Record the revision

Read the revision from the repository and write it as an annotation:

```sh
revision="$(kubectl -n gitops-repo get configmap desired-state -o jsonpath='{.data.revision}')"
kubectl -n outpost annotate deployment relay gitops.astrona.io/synced-revision="$revision" --overwrite
astrona submit
```
