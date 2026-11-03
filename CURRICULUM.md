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
| 010 / 04 | Helm Charts And Releases | 4 | Describe the files of a Helm chart and how templates use values.; Install, upgrade, inspect and roll back a Helm release.; Predict which value wins when several sources set the same key.; Explain what chart repositories, dependencies and hooks add. |
| 010 / 05 | Kustomize Bases, Overlays And Patches | 4 | Describe the roles of a base, an overlay and a kustomization file.; Change an environment with transformers, strategic merge patches and JSON patches.; Explain how generators and name suffix hashes trigger rollouts.; Review a Kustomize result before applying it. |
| 010 / 06 | Configuration And Secrets In Delivery | 4 | Compare environment variables and mounted files as ways to read configuration.; Explain what a Secret protects and what protects it further.; Choose a method to deliver secrets with a GitOps workflow.; Make a configuration change roll out in a controlled way. |
| 010 / 07 | Rollout Controls And Disruption Safety | 4 | Tune maxSurge, maxUnavailable, minReadySeconds and the deadline of a rollout.; Explain what a PodDisruptionBudget protects and what it does not.; Describe how a pod shuts down and configure it for graceful shutdown.; Explain how spreading and capacity limits affect a rollout. |
| 020 / 01 | Diagnosing Application Failures | 5 | Distinguish process failure from application response failure.; Use logs and termination evidence to form a diagnosis.; Relate configuration and dependency access to application behavior.; Explain correlation and safe reproduction of a failing request. |
| 020 / 02 | Debugging Failed Releases | 5 | Compare intended release identity with observed replicas and artifacts.; Relate failed probes to rollout progress.; Design a focused reproduce, correct and verify cycle.; Choose rollback only when its compatibility requirements hold. |
| 020 / 03 | Debugging Inside Pods With kubectl | 4 | Run commands, copy files and forward ports to reach a pod.; Attach an ephemeral debug container to a pod that has no shell.; Recognise out-of-memory kills and resource limit problems.; Diagnose permission and read-only filesystem failures. |
| 020 / 04 | Debugging Services, DNS And Ingress | 4 | Find a Service with no endpoints and name the cause.; Test name resolution from inside a pod and read CoreDNS state.; Recognise when a NetworkPolicy blocks traffic.; Trace a request from an Ingress or Gateway to a pod. |
| 020 / 05 | Debugging Scheduling, Storage And Cluster Dependencies | 4 | Read FailedScheduling events and name the cause.; Use taints, tolerations and node selectors to explain placement.; Diagnose a PersistentVolumeClaim that stays Pending.; Find quota, limit range and node condition problems. |
| 020 / 06 | Debugging Helm And GitOps Delivery Failures | 4 | Read Helm release status, history and failure messages.; Render a chart locally to find a template or values fault.; Tell sync status from health and find drift in a GitOps tool.; Roll back safely and record what failed. |

Every section begins with an introduction. Every module ends with a summary before the next module. Each module has a playground and a graded lab after its last part. Each section closes with a capstone and a `quiz.yaml` knowledge check; `sections/final-domain-quiz.yaml` closes the course.

Labs and playgrounds are written and statically validated only; no runtime execution is claimed. Technical content remains draft until review.
