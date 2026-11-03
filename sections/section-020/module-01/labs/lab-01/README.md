---
estimated_duration: 20m
---

# Lab: Find And Fix Three Application Failures

Graded lab for the failure diagnosis module. **Status: UNTESTED.** Written and statically validated only (`astrona validate`, `bash -n`); it has not been run. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-020/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-020/module-01/labs/lab-01
astrona destroy ats-039-lab-020-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-beacon-running.sh` | `MODE` of `beacon` is `serve` and one replica is ready |
| `validate-relay-running.sh` | `relay` has one ready replica and a non-empty `ENDPOINT` |
| `validate-lookout-endpoints.sh` | The Service `lookout` lists at least one endpoint address |
| `validate-lookout-serves.sh` | `shuttle` gets HTTP 200 from `lookout` at `/healthz` |
