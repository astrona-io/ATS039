# Question

Solve this question on: `terminal`

The Helm chart `beacon` is in `/tmp/ats039-lab/beacon`. The release `beacon` is installed in the namespace `outpost` at revision 1 with one replica and the message `first`.

1. Upgrade the release `beacon` so that it runs three replicas and the message `second`. This is revision 2.

2. Upgrade the release again so that the message is `third` and the replica count stays at three. This is revision 3.

3. Roll the release back to revision 2, and wait until the pods are available.

`helm` and `kubectl` already point at the cluster as the cluster administrator.
