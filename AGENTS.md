# Contribution process

## Always use a feature branch

Don't commit directly to `main`. Create a feature branch, commit there, push, and open a PR. Merge to `main` only once the change has been tested live (see below).

## Repo layout

- `fluxcd/kustomization.yaml` is the app-of-apps list — every entry there gets applied to the cluster automatically by Flux.
- `fluxcd/gotk-sync.yaml` holds the `GitRepository` + `Kustomization` that make Flux watch this repo in the first place. It is **applied manually only** (`kubectl apply -f fluxcd/gotk-sync.yaml`) and is deliberately **not** listed in `fluxcd/kustomization.yaml`. Flux never re-applies it, so it can't self-heal over live changes and there's no recursive "the sync manifest applies itself" behavior to reason about. If you regenerate it via `flux bootstrap`, remember to re-exclude it before committing.

## Editing SOPS-encrypted files

Some files (e.g. `fluxcd/grafana-k8s-monitoring/helmrelease.yaml`) are SOPS-encrypted per `fluxcd/.sops.yaml` / `nixos/.sops.yaml`. Never hand-edit these files directly — SOPS computes a MAC over the *entire* document, including plaintext fields, so any edit outside `sops` invalidates it even if the field you touched wasn't itself encrypted.

The private key isn't necessarily in your local GPG keyring. It lives in-cluster as the `sops-gpg` Secret in the `flux-system` namespace (Flux's kustomize-controller needs it there to decrypt at reconcile time). Pull and import it if needed:

```
kubectl get secret sops-gpg -n flux-system -o jsonpath='{.data.sops\.asc}' | base64 -d | gpg --import
```

Then edit encrypted values with `sops set <file> <path> <value>` (or `sops <file>` to open the full editor), never with a text editor directly.

## Testing a branch against the live cluster

Because `gotk-sync.yaml` is manual-apply only, testing a branch is just repointing the live `GitRepository` — Flux will never fight you over it or revert it on its own:

```
kubectl patch gitrepository flux-system -n flux-system --type=merge \
  -p '{"spec":{"ref":{"branch":"<your-branch>"}}}'

flux reconcile source git flux-system -n flux-system
flux reconcile kustomization flux-system -n flux-system
```

Verify whatever you changed (`kubectl get helmrelease ... -o yaml`, pod status, etc.) — normal 10-minute reconciliation just keeps applying your branch until you point it back.

When done (merged or not), point back at `main`:

```
kubectl patch gitrepository flux-system -n flux-system --type=merge \
  -p '{"spec":{"ref":{"branch":"main"}}}'
flux reconcile source git flux-system -n flux-system
flux reconcile kustomization flux-system -n flux-system
```
