---
estimated_duration: 45m
---

# Capstone: Release Scout Through A Delivery Pipeline

Capstone for the Application Delivery section. **Status: UNTESTED.** Written and statically validated only (`astrona validate`, `bash -n`); it has not been run. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/capstone
astrona submit --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/capstone
astrona destroy ats-039-capstone-010
```

Authors run the local copy with `astrona run -c <capstone>` and prove the reference solution with `astrona test -c <capstone>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-overlay-applied.sh` | `scout` in `outpost` has 3 available replicas, the pinned image, `env: production` on Deployment and pod template, a last-applied annotation, and the Service `scout` exists |
| `validate-canary-running.sh` | `scout-canary` has 1 available replica, pod labels `app: scout` and `track: canary` and the message `scout-canary` |
| `validate-traffic-split.sh` | 3 stable and 1 canary running pod, 4 endpoints on the Service |
| `validate-release-check.sh` | The Job `release-check` succeeded with the curl image and its log shows `200` |
| `validate-evidence.sh` | `kubernetes.io/change-cause` on `scout` mentions `canary` |
| `validate-repo-unchanged.sh` | The ConfigMap `delivery-repo` has the original content |
