---
draft: true
exam_objectives:
  - Debugging
---
# Logs And Events At Scale

Real applications have many pods, many containers and long histories. Reading one log with `kubectl logs` is not enough when the failing pod has already been replaced. This part covers the flags that select the right log, the events that Kubernetes keeps about objects, and the output formats that turn long objects into one readable line.

## Select the right log

A container writes to standard output and standard error, and the container runtime stores that text on the node. `kubectl logs` asks the kubelet for it. The flags choose which text you get.

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet logs deployment/scout --tail=5
kubectl -n starfleet logs -l app=scout --tail=2 --prefix
kubectl -n starfleet logs deployment/scout --since=10m
kubectl -n starfleet logs deployment/scout --all-containers=true --timestamps
```

`--tail` limits the number of lines. `-l` selects pods by label, and `--prefix` adds the pod and container name to each line, which is how you tell pods apart. `--since` limits the time window. `--timestamps` adds the time of each line. For a pod with more than one container, `-c <name>` selects the container. `-p` (or `--previous`) shows the log of the container instance that ran before the last restart, which is the only place the cause of a crash can be found. `-f` follows the log live. `kubectl logs` on a Deployment reads one of its pods only, so use a label selector to cover all of them.

The log of a pod that was deleted is gone from the cluster. A logging stack that ships logs to central storage keeps it. The playground has no such stack.

## Events

An event is a record that a controller or the kubelet writes about an object: scheduling, image pulls, probe failures, kills and scaling. Events live in the cluster for about one hour by default, and they are not logs of the application.

```sh
kubectl -n starfleet get events --sort-by=.metadata.creationTimestamp
kubectl -n starfleet get events --field-selector type=Warning
kubectl -n starfleet get events --field-selector involvedObject.name=<POD>
```

Replace `<POD>` with a pod name from `kubectl -n starfleet get pods`. The first command orders events oldest to newest, which is the order of the story. The second shows only warnings. The third shows the events of one object. `kubectl describe` prints the same events at the bottom of its output.

## Output formats for many objects

With many pods, pick the fields you need. `custom-columns` prints a table and `jsonpath` prints values.

```sh
kubectl -n starfleet get pods -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName,RESTARTS:.status.containerStatuses[0].restartCount
kubectl -n starfleet get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.phase}{"\n"}{end}'
```

The first command prints one row for each pod with its node and restart count. The second prints the name and phase separated by a tab. Both read the same API objects that `kubectl get -o yaml` prints in full.

## Structured logs

An application that writes one JSON object for each log line is easier to filter. The fields usually include a time, a level, a message and a request identifier. The `podinfo` application writes JSON lines, so a tool such as `jq` can filter them if it is installed on your machine:

```sh
kubectl -n starfleet logs deployment/scout --tail=20 | jq -r '.msg'
```

If `jq` is not installed, the first command still shows the raw lines. A request identifier that appears in the logs of several services lets you follow one request across them.

You can now choose the log, the event and the output format that matches a symptom. Which of them to use first depends on the status, and the status table from the lifecycle states decides that.

## Common pitfalls

> [!WARNING]
> `kubectl logs` without `-p` shows the new container, which may have no output yet. Events expire, so read them soon after a failure. A Deployment name in `kubectl logs` selects only one pod. Do not paste logs that contain secrets or personal data into a ticket.
