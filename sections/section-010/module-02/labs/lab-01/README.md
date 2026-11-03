---
estimated_duration: 25m
---

# Lab: Correct Drift And Render With Kustomize

Graded lab for the GitOps module. **Status: UNTESTED.** Written and statically validated only (`astrona validate`, `bash -n`); it has not been run. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/module-02/labs/lab-01
astrona destroy ats-039-lab-010-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-live-matches-repo.sh` | `scout` has 2 replicas, the repository message and 2 available replicas |
| `validate-unmanaged-removed.sh` | `debug-tools` is gone |
| `validate-repo-unchanged.sh` | The ConfigMap content still matches the fingerprint taken at bootstrap |
| `validate-kustomize-overlay.sh` | `scout` in `outpost` has 2 replicas, the pinned image, `env=production` on object and pod template, a `last-applied-configuration` annotation (created by `kubectl apply`) and 2 available replicas |
