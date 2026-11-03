---
estimated_duration: 25m
---

# Lab: Reconcile, Prune And Record A Revision

Graded lab. **Status: UNTESTED.** The lab was written and statically validated (`astrona validate`, `bash -n`); it has not been run. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/module-02/labs/lab-02
astrona submit --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/module-02/labs/lab-02
astrona destroy ats-039-lab-010-02-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-relay-matches.sh` | The relay Deployment matches the repository |
| `validate-stray-pruned.sh` | The Deployment stray is removed |
| `validate-revision-recorded.sh` | The synced revision annotation equals the repository revision |
| `validate-repo-unchanged.sh` | The repository ConfigMap is not edited |
