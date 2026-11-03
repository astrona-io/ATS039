---
estimated_duration: 25m
---

# Lab: Tune A Rollout And Protect It With A Budget Lab

Graded lab. **Status: UNTESTED.** The lab was written and statically validated (`astrona validate`, `bash -n`); it has not been run. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/module-07/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/module-07/labs/lab-01
astrona destroy ats-039-lab-010-07
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `01-rollout-settings.sh` | dock uses maxSurge 1, maxUnavailable 0 and minReadySeconds 5 |
| `02-budget.sh` | The PodDisruptionBudget dock-pdb requires 3 available pods for app dock |
| `03-shutdown.sh` | dock has a 20 second grace period and a 5 second preStop sleep |
