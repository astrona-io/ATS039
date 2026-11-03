---
estimated_duration: 20m
---

# Lab: Change Strategy And Roll Back A Stuck Release

Graded lab. **Status: UNTESTED.** The lab was written and statically validated (`astrona validate`, `bash -n`); it has not been run. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/module-03/labs/lab-02
astrona submit --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/module-03/labs/lab-02
astrona destroy ats-039-lab-010-03-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-strategy.sh` | The strategy is Recreate and the history limit is 5 |
| `validate-rolled-back.sh` | relay runs MODE=v1 with two available replicas |
| `validate-change-cause.sh` | The change cause records the rollback |
