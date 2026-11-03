---
estimated_duration: 25m
---

# Lab: Fix Probe And Image Failures

Graded lab. **Status: UNTESTED.** The lab was written and statically validated (`astrona validate`, `bash -n`); it has not been run. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-020/module-01/labs/lab-02
astrona submit --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-020/module-01/labs/lab-02
astrona destroy ats-039-lab-020-01-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-gauge.sh` | gauge uses the path /healthz and is available |
| `validate-ledger.sh` | The Service ledger has an endpoint |
| `validate-harbor.sh` | harbor runs the corrected image |
