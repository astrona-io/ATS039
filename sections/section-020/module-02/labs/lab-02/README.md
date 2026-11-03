---
estimated_duration: 25m
---

# Lab: Roll Back An Image Failure And Verify

Graded lab. **Status: UNTESTED.** The lab was written and statically validated (`astrona validate`, `bash -n`); it has not been run. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-020/module-02/labs/lab-02
astrona submit --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-020/module-02/labs/lab-02
astrona destroy ats-039-lab-020-02-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-rollback.sh` | relay runs the good image with two available replicas |
| `validate-change-cause.sh` | The change cause records the rollback |
| `validate-smoke-test.sh` | The smoke test Job completed against the relay Service |
