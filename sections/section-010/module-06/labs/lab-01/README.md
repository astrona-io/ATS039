---
estimated_duration: 25m
---

# Lab: Version Configuration And Mount A Secret Lab

Graded lab. **Status: UNTESTED.** The lab was written and statically validated (`astrona validate`, `bash -n`); it has not been run. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/module-06/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/module-06/labs/lab-01
astrona destroy ats-039-lab-010-06
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `01-immutable-config.sh` | The ConfigMap ledger-config-v2 is immutable and has LEVEL debug |
| `02-rollout.sh` | ledger reads ledger-config-v2 and runs two updated replicas |
| `03-secret-volume.sh` | The token Secret is mounted read-only at /etc/ledger-token |
