# Debugging Scheduling, Storage And Cluster Dependencies - Playground

- **Slug:** ats-039-playground-020-05
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** UNTESTED (written and statically validated only)

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.8`) with the Starfleet example workloads. Nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy ats-039-playground-020-05
```

`astrona destroy` takes the environment name, not the config path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `manifests/starfleet.yaml` | Starting workloads |
| `docs/overview.md` | What the environment contains and ideas to try |
