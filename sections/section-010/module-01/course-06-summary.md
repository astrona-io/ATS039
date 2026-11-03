---
draft: true
exam_objectives:
  - Application Delivery
---
# Summary

A delivery pipeline turns a reviewed source revision into a checked, identifiable artifact. Each stage is a process whose exit code decides whether the change continues. Continuous integration gives fast feedback on the checks that were configured, and a passing run proves only those checks.

An image tag can move to different content, while a digest names exact content. A release record that links the source revision, the controlled build inputs and the artifact digest lets a team explain what was tested and what runs. Building once and promoting the same image reference keeps the test evidence connected to the deployed bytes, and environment-specific values stay in configuration such as a ConfigMap.

Continuous delivery keeps every passing change releasable and adds an approval gate before production. Continuous deployment removes that gate and deploys automatically. Deploying code is separate from exposing a feature, and an image rollback does not undo configuration or data changes.

- A check is a process: exit code `0` continues the pipeline, any other code stops it.
- A digest is immutable; a tag is not.
- Promote the artifact, not a rebuild; change only the configuration.

<!-- astrona:playground:destroy -->
