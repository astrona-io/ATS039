---
estimated_duration: 20m
---

# Lab: Roll Back A Bad Update And Fix Drift Lab

Graded lab. **Status: UNTESTED.** The lab was written and statically validated (`astrona validate`, `bash -n`); it has not been run. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-020/module-06/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-020/module-06/labs/lab-01
astrona destroy ats-039-lab-020-06
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `01-beacon-available.sh` | The Deployment beacon has two available replicas |
| `02-beacon-image.sh` | beacon runs the good image tag |
| `03-ledger-replicas.sh` | ledger matches the replica count it declares |
| `04-finding.sh` | The Deployment beacon records the finding in an annotation |
