---
estimated_duration: 25m
---

# Lab: Build A Production Overlay With Kustomize Lab

Graded lab. **Status: UNTESTED.** The lab was written and statically validated (`astrona validate`, `bash -n`); it has not been run. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/module-05/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/module-05/labs/lab-01
astrona destroy ats-039-lab-010-05
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `01-replicas.sh` | prod-relay has three available replicas |
| `02-merged-config.sh` | The generated ConfigMap of prod-relay has MESSAGE production |
| `03-limit.sh` | The container has a memory limit of 128Mi |
