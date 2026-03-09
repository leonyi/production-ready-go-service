# k8s-ready-go-service
<in progress>

**This repository values learning in public over presenting finished answers.**

## Repository structure (layered, not grouped)

This repo follows a **layered architecture**, where imports flow strictly
downward and each layer has a narrow responsibility, not by feature or framework.

The goal is to keep the mental model small, boundaries clear, and dependencies flowing in one direction.

### Layer responsibilities
```text
src/prod_skeleton/
├── api/ # Transport & process boundaries (protocols, middleware)
├── app/ # External-facing handlers & request/response models
├── business/ # Domain logic and ops-aware components
├── foundation/ # Reusable, dependency-free building blocks
├── zarf/   # Container native infra: image artifact builds, k8s manifests,etc.
```

#### Dependency Rule (IMPORTANT!)

api → app → business → foundation -> zarf

Lower layers must never import from higher layers. 
This rule is enforced to preserve clarity, testability, and long-term maintainability.

## Design principles

This repo explicitly optimizes for:

- **Single Responsibility & Cohesion**
- **Loose coupling and clear abstractions**
- **Deterministic testing** (e.g. FakeClock instead of sleeps)
- **12-Factor App compliance**
- **Defensibility over cleverness**
- **KISS / DRY / YAGNI**

Tradeoffs are documented as they arise.

## Development workflow
<in progress>

This project intentionally defers CI setup until core service features are in place.
All checks (tests, linting, type-checking, import contracts) are designed to run locally
and will later be automated via CI without structural changes.


---
## Helm Deployment Example (`helm-deploys` branch)

This branch adds a **Helm-based deployment example** for the `coolkit` service.  
The main repository primarily uses **Kustomize**, but this demonstrates how a workload can be packaged and deployed using **Helm** when templating and environment parameterization are useful.

Chart location:
```bash
zarf/k8s/helm-apps/coolkit
```
### Structure:

```text
zarf/k8s/helm-apps/coolkit/
├── Chart.yaml
├── values.yaml
├── values-prestaging.yaml
├── values-production.yaml
└── templates/
    ├── _helpers.tpl
    ├── configmap.yaml
    ├── deployment.yaml
    ├── keda-scaledobject.yaml
    ├── secret.yaml
    └── service.yaml
```


### Features

The chart models the deployment requirements for the `coolkit` service:

- Container image deployed using **SHA tags**
- Service exposed on **port 8080**
- Observability endpoint on **port 2345**
- **KEDA external scaler** integration
- Autoscaling between **10–100 pods**
- Environment-specific configuration via values files

### Local Validation

The Makefile includes targets to lint and render the chart locally.

Lint the chart:

```bash
make helm-lint

Output:
Linting Helm chart...
helm lint zarf/k8s/helm-apps/coolkit
==> Linting zarf/k8s/helm-apps/coolkit
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, 0 chart(s) failed
```

Render manifests:
```bash
make helm-render

Output:
Rendering Helm chart to file...
mkdir -p rendered
helm template coolkit zarf/k8s/helm-apps/coolkit > rendered/coolkit.yaml
Output written to rendered/coolkit.yaml
```

Other targets can later be added to buld the environment specific templates. The commands aim to validate and render K8S manifests before deployment to cluster.
