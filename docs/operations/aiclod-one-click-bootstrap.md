# AiClod One-Click Bootstrap

## Recommendation

For a project like AiClod, the best "one-click" pattern is:

- a cross-platform bootstrap runner for prerequisite detection and local/cloud orchestration, and
- Terraform for cloud infrastructure provisioning because it gives a provider-specific implementation behind a common workflow.

This repository now uses that approach.

## Entry Commands

### Linux / macOS

```bash
./bootstrap.sh --target local
./bootstrap.sh --target aws
./bootstrap.sh --target gcp
./bootstrap.sh --target azure
./scripts/bootstrap.sh --target local
./scripts/bootstrap.sh --target aws
./scripts/bootstrap.sh --target gcp
./scripts/bootstrap.sh --target azure
```

### Windows PowerShell

```powershell
pwsh -File .\bootstrap.ps1 -Target local
pwsh -File .\bootstrap.ps1 -Target aws
pwsh -File .\bootstrap.ps1 -Target gcp
pwsh -File .\bootstrap.ps1 -Target azure
pwsh -File .\scripts\bootstrap.ps1 -Target local
pwsh -File .\scripts\bootstrap.ps1 -Target aws
pwsh -File .\scripts\bootstrap.ps1 -Target gcp
pwsh -File .\scripts\bootstrap.ps1 -Target azure
```

## What the Bootstrap Does

- detects the operating system and available package manager,
- checks required prerequisites,
- attempts automatic installation when the package manager is supported,
- builds and starts the local Docker Compose stack for `local`, or
- starts the local Docker Compose stack for `local`, or
- provisions cloud infrastructure with Terraform and deploys the Helm chart for `aws`, `gcp`, or `azure`.

## Prerequisite Strategy

The bootstrap script supports automatic installation paths for common package managers:

- Linux: `apt`, `dnf`, `yum`, `zypper`
- macOS: `brew`
- Windows: `winget`, `choco`

For cloud targets it also checks the matching cloud CLI:

- AWS → `aws`
- GCP → `gcloud`
- Azure → `az`

## Terraform Layout

- `infra/terraform/aws/` provisions an EKS-based baseline.
- `infra/terraform/gcp/` provisions a GKE-based baseline.
- `infra/terraform/azure/` provisions an AKS-based baseline.

Each provider directory includes a `terraform.tfvars.example` file that should be copied to `terraform.tfvars` and adjusted before the first apply.

## Notes

- Local bootstrap is the fastest path for contributor onboarding.
- Cloud bootstrap assumes credentials for the selected provider are already available.
- The bootstrap layer is designed to be opinionated but extensible; enterprise teams can swap provider modules or override Helm values as needed.


## Local Placeholder Services

The repository includes minimal buildable placeholder containers under `apps/web`, `apps/api`, and `apps/worker` so `--target local` works immediately even before the production application code is implemented.
