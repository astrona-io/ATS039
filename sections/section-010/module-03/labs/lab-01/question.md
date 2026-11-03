# Question

Solve this question on: `terminal`

The `starfleet` namespace runs two versions of `scout`: the Deployments `scout-blue` (current) and `scout-green` (new). The Service `scout` selects `version: blue`. A second problem: someone updated the Deployment `probe` and its new pods never become ready, so the rollout is stuck while the old pods still serve.

1. Confirm that `scout-green` has all its replicas ready. Then switch the Service `scout` so that it sends traffic to the green version only. Do not scale down or delete `scout-blue`: it stays for a quick return.

2. Record the cutover by setting the annotation `kubernetes.io/change-cause` on the Service `scout` to a text that contains the word `green`.

3. Return the Deployment `probe` to its previous, working revision with a rollback. Do not delete or recreate the Deployment. When you finish, all replicas of `probe` must be updated and ready.

`shuttle` must still get HTTP 200 from the `probe` Service at the end. `kubectl` already points at the cluster as the cluster administrator.
