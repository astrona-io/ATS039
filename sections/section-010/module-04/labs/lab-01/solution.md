# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Command output is not shown here, because this lab has not been run yet.

# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Command output is not shown here, because this lab has not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/module-04/labs/lab-01
```

## Step 1: Upgrade to revision 2

```sh
helm list --namespace outpost
helm upgrade beacon /tmp/ats039-lab/beacon --namespace outpost --set replicaCount=3 --set ui.message=second --wait
helm history beacon --namespace outpost
```

## Step 2: Upgrade to revision 3 and keep the other values

`--reuse-values` starts from the values of the last revision:

```sh
helm upgrade beacon /tmp/ats039-lab/beacon --namespace outpost --reuse-values --set ui.message=third --wait
```

## Step 3: Roll back to revision 2

```sh
helm rollback beacon 2 --namespace outpost --wait
helm history beacon --namespace outpost
astrona submit
```

The rollback creates revision 4 with the content of revision 2: three replicas and the message `second`.
