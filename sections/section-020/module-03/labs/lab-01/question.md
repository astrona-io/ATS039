# Question

Solve this question on: `terminal`

In `outpost`, the Deployment `mill` does not stay running. It has a read-only root filesystem and writes the file `/data/state` when it starts. There is also a pod `sleeper` that runs a long sleep.

1. Find out why `mill` fails, with `kubectl logs` and `kubectl describe`.

2. Fix `mill` without removing its security settings: mount an `emptyDir` volume at `/data`. Wait until one replica is available.

3. Attach an ephemeral container named `inspector` to the pod `sleeper`, using the image `busybox:1.37.0` and `sleeper` as the target container.

4. Record the finding: set the annotation `debug/finding` on the Deployment `mill` to `read-only root filesystem`.

`kubectl` already points at the cluster as the cluster administrator.
