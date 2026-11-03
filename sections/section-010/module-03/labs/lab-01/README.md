---
estimated_duration: 20m
---

# Lab: Switch Blue-Green Traffic And Roll Back A Stuck Release

Graded lab for the safe releases module. **Status: UNTESTED.** Written and statically validated only (`astrona validate`, `bash -n`); it has not been run. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/module-03/labs/lab-01
astrona destroy ats-039-lab-010-03
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-service-on-green.sh` | The selector is `version: green` and a request returns the green message |
| `validate-blue-kept.sh` | `scout-blue` and `scout-green` both have available replicas |
| `validate-cutover-evidence.sh` | `kubernetes.io/change-cause` on the Service mentions green |
| `validate-probe-rolled-back.sh` | The readiness path is `/status/200`, the revision is 3 or higher and all replicas are updated and ready |
| `validate-probe-serves.sh` | `shuttle` gets HTTP 200 from `probe` |
