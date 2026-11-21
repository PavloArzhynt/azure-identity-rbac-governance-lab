# Azure Identity, RBAC & Governance Baseline (AZ-104 Lab)

Automated Infrastructure-as-Code (Bicep) and Azure CLI governance baseline enforcing **Least-Privilege RBAC**, **EU Data Residency (`germanywestcentral`)**, and **Resource Locks** for enterprise cloud environments.

## Architecture & Security Controls

```text
[ Microsoft Entra ID Tenant ]
       │
       ├── Security Group: SG-Azure-Cloud-Engineers  ──► RBAC: Contributor (Scoped to RG)
       └── Security Group: SG-Azure-Security-Auditors ──► RBAC: Reader (Scoped to RG)
                                                               │
                                                               ▼
                                          [ Resource Group: rg-governance-eu-prod ]
                                                │ (Region: Germany West Central)
                                                ▼
                                          [ Audit Storage Account (TLS 1.2, HTTPS) ]
                                                └── Resource Lock: CanNotDelete
```

## Key Engineering Highlights
- **Role-Based Access Control (Azure RBAC):** Separates operational duties between engineering (`Contributor`) and compliance (`Reader`) using Entra ID Security Groups instead of direct user assignments.
- **GDPR & EU Data Residency:** Deploys governance and audit storage strictly in `germanywestcentral` (Frankfurt) with public blob access disabled (`allowBlobPublicAccess: false`) and `TLS 1.2` enforced.
- **Accidental Deletion Protection:** Applies an ARM `CanNotDelete` resource lock via Bicep to protect critical audit logs from unauthorized or accidental removal.
- **Idempotent Automation:** Combines declarative **Azure Bicep** (`governance.bicep`) with **Azure CLI** scripting (`setup-entra-rbac.sh`) for repeatable deployments.

## Quick Deployment

```bash
chmod +x setup-entra-rbac.sh
./setup-entra-rbac.sh
```
