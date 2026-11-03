---
draft: true
exam_objectives:
  - Application Delivery
---
# CI/CD Tools And Pipeline Definitions

A team needs software that runs the pipeline stages for every change. Many tools do this, and the exam expects you to know what kind of tool each one is. This part explains what a pipeline definition contains, what the parts of a pipeline runner are, and how the best known tools differ. It then runs a small three-stage pipeline as a Kubernetes Job, so you can see how ordered stages stop at the first failure.

## What every CI/CD tool provides

A CI/CD tool is software that starts a pipeline when something happens, runs its stages in order and records the result. Continuous integration (CI) is the part that builds and tests each change. Continuous delivery or continuous deployment (CD) is the part that moves the result to an environment. Every tool has the same building blocks, even when it uses different names.

- A trigger starts a run. Common triggers are a push to a branch, a pull request, a tag, a schedule or a manual click.
- A pipeline is the whole definition. It is a text file stored in the same repository as the source code, which is called pipeline as code. Because the file is versioned, a change to the pipeline gets the same review as a change to the application.
- A stage or job is a group of steps. A step is one command or one container image that runs a command.
- A runner (also called an agent or a worker) is the machine or container that executes the steps. The tool's control plane schedules work, and the runner does it.
- Artifacts and caches carry files between steps, such as a built image or downloaded dependencies.
- Secrets are credentials that the tool injects into a step, for example a registry password. A secret must never be printed in a log.

## The common tools

The tools differ in where they run and in how they define a pipeline. These are the names the exam and real projects use.

| Tool | Kind | Pipeline definition |
| --- | --- | --- |
| Jenkins | Self-hosted automation server with a large plugin system | `Jenkinsfile` in the repository |
| GitHub Actions | Service built into GitHub | YAML workflow files in `.github/workflows/` |
| GitLab CI/CD | Service built into GitLab | `.gitlab-ci.yml` in the repository |
| Tekton | Kubernetes-native pipeline framework, a Cloud Native Computing Foundation (CNCF) project | Kubernetes custom resources: `Task`, `Pipeline`, `PipelineRun` |
| Argo Workflows | Kubernetes-native workflow engine, a CNCF project | A `Workflow` custom resource |

Tekton and Argo Workflows run every step as a pod in a Kubernetes cluster. Jenkins, GitHub Actions and GitLab CI can also run their steps in a cluster, but they are not defined by Kubernetes objects. None of these tools is a GitOps controller. A GitOps controller, such as Argo CD or Flux, watches a repository and a cluster and does not build anything.

## A pipeline definition

This is a short GitHub Actions workflow. Read it as an example of the building blocks above. You do not run it in the playground:

```yaml
name: build
on:
  push:
    branches: [main]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: make test
  image:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: docker build -t registry.example.com/scout:${{ github.sha }} .
```

The `on` block is the trigger. Each entry under `jobs` is a job that a runner executes. The `needs: test` line makes the `image` job wait for the `test` job, and it stops if `test` fails. The image tag uses the commit hash, `github.sha`, so every image links back to one source revision.

## Run ordered stages in Kubernetes

A Kubernetes Job can show the same rule on a small scale. Init containers in a pod run one after another, and each must exit with code `0` before the next one starts. If one fails, the later ones never run. That is how a pipeline stops at the first failing stage.

<!-- astrona:playground:renew -->

Save this as `job-three-stages.yaml`. The three init containers stand in for the stages build, test and publish. The `test` stage exits with code `1`:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: three-stages
  namespace: starfleet
spec:
  backoffLimit: 0
  template:
    spec:
      restartPolicy: Never
      initContainers:
        - name: build
          image: curlimages/curl:8.22.0
          command: ["sh", "-c", "echo build ok"]
        - name: test
          image: curlimages/curl:8.22.0
          command: ["sh", "-c", "echo test failed; exit 1"]
        - name: publish
          image: curlimages/curl:8.22.0
          command: ["sh", "-c", "echo publish ok"]
      containers:
        - name: done
          image: curlimages/curl:8.22.0
          command: ["sh", "-c", "echo pipeline finished"]
```

Apply it and wait for the Job to fail:

```sh
kubectl apply -f job-three-stages.yaml
kubectl -n starfleet wait --for=condition=failed job/three-stages --timeout=120s
```

Then read the logs of the stages one by one:

```sh
kubectl -n starfleet logs job/three-stages -c build
kubectl -n starfleet logs job/three-stages -c test
kubectl -n starfleet get pods -l job-name=three-stages
```

The `build` log shows `build ok` and the `test` log shows `test failed`. The pod status shows that the pod did not reach the `publish` stage. Here the kubelet runs the containers in order, and the Job controller marks the Job failed. Now change the `test` command to `echo test ok`, delete the Job with `kubectl -n starfleet delete job three-stages`, apply the file again and check that the Job completes.

A real pipeline tool applies the same rule with more features: retries, parallel jobs, caches and approvals. When you meet a tool you do not know, find its trigger, its stage list, its runner and the place where it keeps secrets, and you can read any pipeline.

## Common pitfalls

> [!WARNING]
> A CI/CD tool builds and tests; it does not reconcile a cluster. Do not confuse a pipeline runner with a GitOps controller. A pipeline definition that is not in version control cannot be reviewed. Never print a secret in a step: logs are stored and readable by many people.
