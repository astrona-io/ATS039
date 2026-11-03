---
estimated_duration: 45m
---

# Capstone: Debug A Broken Delivery In Starfleet

Capstone for the Troubleshooting section. **Status: UNTESTED.** Written and statically validated only (`astrona validate`, `bash -n`); it has not been run. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-020/capstone
astrona submit --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-020/capstone
astrona destroy ats-039-capstone-020
```

Authors run the local copy with `astrona run -c <capstone>` and prove the reference solution with `astrona test -c <capstone>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-dispatch-released.sh` | Path `/readyz`, message `dispatch-v2`, `updated`, `ready` and `available` equal 2, `Progressing` is `NewReplicaSetAvailable` |
| `validate-beacon-running.sh` | `beacon-config` has `mode: serve`, `beacon` still reads it and has 1 ready replica |
| `validate-relay-endpoints.sh` | The Service `relay` lists at least one endpoint address |
| `validate-clients-served.sh` | `shuttle` gets HTTP 200 from `relay` and `dispatch-v2` from `dispatch` |
| `validate-uids-unchanged.sh` | The UIDs of the three Deployments match the record in `lab-meta` |
| `validate-evidence.sh` | `kubernetes.io/change-cause` on `dispatch` mentions `readyz` |
