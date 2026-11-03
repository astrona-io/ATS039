# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Command output is not shown here, because this lab has not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/module-03/labs/lab-02
```

## Step 1: Read the history

```sh
kubectl -n outpost rollout history deployment/relay
kubectl -n outpost rollout history deployment/relay --revision=1
```

Revision 1 shows `MODE` with the value `v1`.

## Step 2: Change the strategy and the history limit

The `rollingUpdate` settings must be removed when the type becomes `Recreate`:

```sh
kubectl -n outpost patch deployment relay --type merge -p '{"spec":{"strategy":{"type":"Recreate","rollingUpdate":null},"revisionHistoryLimit":5}}'
astrona submit --keep
```

## Step 3: Roll back

```sh
kubectl -n outpost rollout undo deployment/relay --to-revision=1
kubectl -n outpost rollout status deployment/relay --timeout=180s
astrona submit --keep
```

## Step 4: Record the reason

```sh
kubectl -n outpost annotate deployment relay kubernetes.io/change-cause="rolled back to v1" --overwrite
astrona submit
```
