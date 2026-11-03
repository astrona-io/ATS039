---
estimated_duration: 25m
---

# Lab: Gate And Promote A Release With Evidence

Graded lab. **Status: UNTESTED.** The lab was written and statically validated (`astrona validate`, `bash -n`); it has not been run. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/module-01/labs/lab-02
astrona submit --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/module-01/labs/lab-02
astrona destroy ats-039-lab-010-01-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-gate-job.sh` | The Job gate-checks completed with two ordered init containers |
| `validate-approval.sh` | The staging Deployment carries the approval annotation |
| `validate-promotion.sh` | Production runs the staging image with the copied approval and the promoted-from annotation |
