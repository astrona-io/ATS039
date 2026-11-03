---
estimated_duration: 25m
---

# Lab: Fix A Read-Only Filesystem And Attach A Debug Container Lab

Graded lab. **Status: UNTESTED.** The lab was written and statically validated (`astrona validate`, `bash -n`); it has not been run. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-020/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-020/module-03/labs/lab-01
astrona destroy ats-039-lab-020-03
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `01-mill-running.sh` | mill has an emptyDir volume at /data and one available replica |
| `02-hardening-kept.sh` | mill keeps the read-only root filesystem |
| `03-debug-container.sh` | The pod sleeper has an ephemeral container named inspector |
| `04-finding.sh` | The Deployment mill records the finding in an annotation |
