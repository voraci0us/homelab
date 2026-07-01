This repo contains code representing my full homelab. Currently, this is a single node running k3s.

For more info, see my blog at [voraci0.us](voraci0.us).

## GitOps

Since this is a learning project, I am using tools I am unfamiliar with: Flux to manage Kubernetes resources instead of ArgoCD, and SOPS to manage secrets instead of SealedSecrets. SOPS does also have benefits in that field-level encryption is possible - handy for any CRDs that may contain senstive fields. Encryption is done with the PGP key at `./.sops.pub.asc`.
