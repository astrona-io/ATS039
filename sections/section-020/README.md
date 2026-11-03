---
draft: true
exam_objectives:
  - Debugging
---
# Debugging

This section teaches diagnosing application failures; debugging failed releases. These ideas help you explain system behavior and choose a suitable approach in a KCNA scenario.

You will work through Diagnosing Application Failures, Debugging Failed Releases. Each module introduces its goals, teaches the concepts through examples and a playground, adds a graded lab after the last part, and closes with a summary. The section ends with a capstone lab and a knowledge check with answer explanations.

## Learning Outcomes

- Distinguish process failure from application response failure.
- Use logs and termination evidence to form a diagnosis.
- Relate configuration and dependency access to application behavior.
- Explain correlation and safe reproduction of a failing request.
- Compare intended release identity with observed replicas and artifacts.
- Relate failed probes to rollout progress.
- Design a focused reproduce, correct and verify cycle.
- Choose rollback only when its compatibility requirements hold.
- Explain pod phases, container states and the status reasons that kubectl reports.
- Separate the effects of startup, liveness and readiness probe failures.
- Diagnose image and registry failures from events.
- Decide between rollback and fix-forward and verify the result after a release.
