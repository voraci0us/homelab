This repo contains code representing my full homelab. Currently, this is a single node running k3s.

## Storage 
The boot drive itself had LUKS set up during Ubuntu installation, and later TPM unlock added with Clevis.

There are two large ZFS pools, one for HDDs and one for SSDs. These are mirrored in anticipation of drive failure. Each of these pools has a top-level dataset with native ZFS encryption enabled. Keys for this are stored on my boot drive.

The HDDs represent a large storage array. The ZFS dataset is mounted directly on my host and managed either locally or over SMB in the local network. This is always mounted read-only be any containers or VMs that need to access it.

The SSDs are, of course, for performance-sensitive workloads. For Kubernetes, the intention is to run both container workloads and virtual machines (Kubevirt). I'm using [democratic-csi](https://github.com/democratic-csi/democratic-csi) to create separate storage classes that provision datasets and zvols for these, respectively.

## GitOps

Since this is a learning project, I am using tools I am unfamiliar with: Flux to manage Kubernetes resources instead of ArgoCD, and SOPS to manage secrets instead of SealedSecrets. SOPS does also have benefits in that field-level encryption is possible - handy for any CRDs that may contain senstive fields. Encryption is done with the PGP key at `./.sops.pub.asc`.