---
draft: true
exam_objectives:
  - Application Delivery
---
# Environments, Promotion And Approvals

A real delivery process has more than one place to run the software. A change first runs where mistakes cost little, and it moves toward production only when the evidence supports it. This part explains what an environment is, how promotion decides when a release moves on, and how a team records approvals. It also shows how to keep environments close to each other, because a difference between them hides defects.

## What an environment is

An environment is a place where the application runs for a purpose, with its own configuration and its own data. Teams usually have development, staging (also called pre-production) and production. Development is where developers try changes. Staging copies production as closely as the team can afford, and it is where the full set of tests runs. Production serves real users.

Kubernetes gives three ways to separate environments. The first is a separate cluster per environment, which gives the strongest isolation. The second is a separate namespace in one cluster, which is cheaper and separates names, quotas and access rules. The third is a separate cluster for production and a shared cluster for the rest. This course uses two namespaces: `starfleet` plays staging and `outpost` plays production.

## Promotion moves an artifact

Promotion means that a release that passed the checks of one environment becomes the release of the next. The artifact stays the same, and the environment supplies the configuration. A promotion step usually has three parts: a check that the artifact passed, a change to the next environment's desired state, and a check that the new environment is healthy afterwards.

In a pipeline, promotion can happen in two ways. In a push model, the pipeline runs `kubectl apply` or `helm upgrade` against the next cluster. In a GitOps model, the pipeline changes a file in a repository, for example the image reference in a Kustomize overlay, and a controller in the cluster applies it. Both models promote the same artifact. They differ in who holds the cluster credentials: in the first the pipeline holds them, in the second only the controller does.

## Approval gates

An approval gate is a point where the pipeline waits for a decision. A gate can require a person, such as a release manager, or a policy, such as "no critical vulnerabilities". Continuous delivery has a gate before production, and continuous deployment has none. Gates give the organization an audit record: who approved which release and when.

A gate is useful only if it has evidence to look at. Good evidence is the digest of the image, the test results, the scan report and the diff of the desired state. A gate that asks for approval without any of these is a delay without safety.

## Record the promotion in the cluster

Kubernetes stores no approval records itself, but annotations can carry them. Read the annotations of the staging release, then add a record of an approval and a promotion time:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet get deployment scout -o jsonpath='{.metadata.annotations}{"\n"}'
kubectl -n starfleet annotate deployment scout release.astrona.io/approved-by=release-manager --overwrite
kubectl -n starfleet get deployment scout -o jsonpath='{.metadata.annotations.release\.astrona\.io/approved-by}{"\n"}'
```

The last command prints `release-manager`. The backslashes before the dots tell `jsonpath` that the dots belong to the annotation key. Here the API server stored the annotation, and `kubectl` only read it back.

You can also compare what staging and production run. A promotion check can be as simple as two reads:

```sh
kubectl -n starfleet get deployment scout -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
kubectl -n outpost get deployment scout -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

If the playground has no `scout` Deployment in `outpost` yet, the second command reports that the Deployment was not found. That is the state before promotion.

## Keep environments alike

A difference between staging and production can hide a defect that only appears in production. Teams reduce the gap in four ways: the same image, the same Kubernetes version, the same deployment method, and the same shape of configuration. They accept differences in size, such as fewer replicas, and in data, such as test data without personal information.

Configuration is the part that must differ. The image reference must not. If an environment needs a different image, the team has a different release, and the staging evidence no longer applies.

## Rolling back a promotion

A failed promotion needs a way back. The simplest is to promote the previous artifact again, because the pipeline already has its digest and its test evidence. In a GitOps model the team reverts the commit, and the controller applies the earlier desired state. Changes outside the image, such as a database migration, need their own reversal plan; an image rollback does not undo them.

## Common pitfalls

> [!WARNING]
> Do not rebuild the image for production. Do not let staging use an image reference that production does not use. An approval annotation is a record and not a control: only an admission policy or a pipeline gate stops a deployment. A namespace is not a security boundary unless quotas, network policies and access rules are also set.
