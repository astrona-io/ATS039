---
estimated_duration: 25m
---

# Lab: Upgrade And Roll Back A Helm Release Lab

Graded lab. **Status: UNTESTED.** The lab was written and statically validated (`astrona validate`, `bash -n`); it has not been run. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/module-04/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/module-04/labs/lab-01
astrona destroy ats-039-lab-010-04
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `01-release-revision.sh` | The latest deployed revision of release beacon is 4 |
| `02-replicas.sh` | beacon has three available replicas |
| `03-message.sh` | The message is second after the rollback |
