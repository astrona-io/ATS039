---
draft: true
exam_objectives:
  - Debugging
---
# Summary

A failure is either a process failure or an application response failure. A process failure shows in the pod and container state, the exit code and the log of the last terminated container. An application response failure shows in the HTTP status code, the response body and the log lines of the request, while the pod stays `Running` and `Ready`.

`CrashLoopBackOff` names the waiting period between restarts and not the cause. The cause is in `kubectl logs --previous`, the last `exitCode` and `reason`, and the events. A container that never started has no log, which is the case for `ImagePullBackOff` and `CreateContainerConfigError`. Exit codes above 128 mean a signal ended the process, and `137` with the reason `OOMKilled` means the memory limit was exceeded.

Configuration and dependencies explain many failures. A reference to a missing ConfigMap key blocks the container. A Service selector that matches no ready pod gives an empty endpoint list. A request identifier in a header lets a team find one request in the logs of several components. A safe investigation reproduces the failure with a throwaway client or a port-forward and reads before it changes anything.

- Logs exist only for containers that started.
- Read the previous log and the last exit code of a crash loop.
- Empty endpoints mean the selector matches no ready pod.
- Reproduce first, then change one thing.

<!-- astrona:playground:destroy -->
