---
estimated_duration: 20m
---

# Lab: Fix A Quota Limit And A Pending Pod Lab

Graded lab. **Status: UNTESTED.** The lab was written and statically validated (`astrona validate`, `bash -n`); it has not been run. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-020/module-05/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-020/module-05/labs/lab-01
astrona destroy ats-039-lab-020-05
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `01-crew-available.sh` | The Deployment crew has five available replicas |
| `02-quota-kept.sh` | The quota still exists and limits pods |
| `03-wanderer-running.sh` | The pod wanderer is running without the bad node selector |
| `04-finding.sh` | The Deployment crew records the finding in an annotation |
