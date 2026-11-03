---
draft: true
exam_objectives:
  - Debugging
---
# Summary

`kubectl exec` runs commands in a running container, `kubectl cp` copies files and needs `tar` in the image, and `kubectl port-forward` opens a local port to a pod and bypasses the Service. Changes made inside a container are lost on restart.

An ephemeral container, added with `kubectl debug`, brings its own tools to a pod that has no shell. With `--target` it shares the process namespace of another container. `kubectl debug --copy-to` creates a copy of a crashing pod with a command that keeps it running, and `kubectl debug node/NAME` starts a pod with the node filesystem mounted.

A memory limit that is exceeded ends the process with `OOMKilled` and exit code 137. A CPU limit throttles and shows no restart. `kubectl top` needs the metrics server. Security context settings, such as a read-only root filesystem and a non-root user, are good practice and a common cause of failed writes; fix them with a volume for the path, `fsGroup` or the right user, not by removing the protection.

- Ephemeral containers cannot be removed from a pod.
- Exit code 137 has more than one cause; read the reason.
- Raising a limit hides a leak.
- Grant write access to one path, not to the whole filesystem.

<!-- astrona:playground:destroy -->
