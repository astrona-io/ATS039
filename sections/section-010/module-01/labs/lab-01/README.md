---
estimated_duration: 20m
---

# Lab: Promote One Image From Staging To Production

Graded lab for the build and release pipelines module. **Status: UNTESTED.** The lab was written and statically validated (`astrona validate`, `bash -n`); it has not been run. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/module-01/labs/lab-01
astrona destroy ats-039-lab-010-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-image-promoted.sh` | Production runs the staging image reference and not `latest` |
| `validate-release-annotations.sh` | Source revision and build id annotations are copied |
| `validate-production-config.sh` | `scout-config` in `outpost` is set and read with `envFrom` |
| `validate-production-available.sh` | 2 replicas are available and `drifter` gets HTTP 200 |
| `validate-release-check-job.sh` | The Job `release-check` completed against the production Service |
