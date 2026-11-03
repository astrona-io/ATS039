---
estimated_duration: 20m
---

# Lab: Fix Forward A Stalled Release

Graded lab for the failed releases module. **Status: UNTESTED.** Written and statically validated only (`astrona validate`, `bash -n`); it has not been run. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-020/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-020/module-02/labs/lab-01
astrona destroy ats-039-lab-020-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-rollout-complete.sh` | `updated`, `ready` and `available` equal 2 and `Progressing` has the reason `NewReplicaSetAvailable` |
| `validate-fixed-forward.sh` | The probe path is `/readyz`, the message is `lookout-v2` and the revision is 3 or higher |
| `validate-change-cause.sh` | `kubernetes.io/change-cause` on the Deployment mentions `readyz` |
| `validate-lookout-serves.sh` | `shuttle` gets HTTP 200 and `lookout-v2` from the Service `lookout` |
