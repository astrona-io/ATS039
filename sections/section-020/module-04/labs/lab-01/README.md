---
estimated_duration: 20m
---

# Lab: Fix A Service With No Endpoints Lab

Graded lab. **Status: UNTESTED.** The lab was written and statically validated (`astrona validate`, `bash -n`); it has not been run. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-020/module-04/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-020/module-04/labs/lab-01
astrona destroy ats-039-lab-020-04
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `01-endpoints.sh` | The Service web has two endpoint addresses |
| `02-target-port.sh` | The Service sends traffic to port 9898 |
| `03-selector-kept.sh` | The Deployment labels are unchanged |
| `04-dns-name.sh` | The Service records its full DNS name in an annotation |
