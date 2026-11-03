# Curriculum Coverage

Exam: Kubernetes and Cloud Native Associate (KCNA). Domain: Cloud Native Application Delivery (16%).

Verified against the [official objectives](https://training.linuxfoundation.org/certification/kubernetes-cloud-native-associate/) on 2026-10-10. Module titles and questions are original teaching material, not official exam questions.

| Section | Official objective | Modules | Status |
| --- | --- | --- | --- |
| 010 | Application Delivery | 3 | Written; review pending |
| 020 | Debugging | 2 | Written; review pending |

| Section / module | Module | Teaching lessons | Measurable outcomes |
| --- | --- | --- | --- |
| 010 / 01 | Build And Release Pipelines | 5 | Trace source changes through build, checks and artifact publication.; Explain what continuous integration checks.; Distinguish continuous delivery from continuous deployment.; Relate release identity to an immutable artifact. |
| 010 / 02 | GitOps And Deployment Configuration | 5 | Explain declarative, versioned desired state.; Describe pull-based reconciliation and drift correction.; Compare Helm templating with Kustomize overlays.; Identify what a GitOps controller cannot infer from repository state. |
| 010 / 03 | Safe Application Releases | 5 | Explain rolling update behavior and readiness gates.; Compare rolling, blue-green and canary strategies.; Identify evidence needed to promote or reverse a release.; Explain compatibility limits of rollback. |
| 020 / 01 | Diagnosing Application Failures | 5 | Distinguish process failure from application response failure.; Use logs and termination evidence to form a diagnosis.; Relate configuration and dependency access to application behavior.; Explain correlation and safe reproduction of a failing request. |
| 020 / 02 | Debugging Failed Releases | 5 | Compare intended release identity with observed replicas and artifacts.; Relate failed probes to rollout progress.; Design a focused reproduce, correct and verify cycle.; Choose rollback only when its compatibility requirements hold. |

Every section begins with an introduction. Every module ends with a summary before the next module. Each module has a playground and a graded lab after its last part. Each section closes with a capstone and a `quiz.yaml` knowledge check; `sections/final-domain-quiz.yaml` closes the course.

Labs and playgrounds are written and statically validated only; no runtime execution is claimed. Technical content remains draft until review.
