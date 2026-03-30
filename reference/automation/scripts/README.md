# Automation Scripts

Standalone Python utilities for security operations tasks. Complements the PowerShell modules in `../crowdstrike/api-modules/`.

---

## Scripts

| Script | Language | Description |
|---|---|---|
| [sentinel-alert-enricher.py](sentinel-alert-enricher.py) | Python 3.10+ | Queries Microsoft Sentinel alerts via Azure SDK, enriches with IP geolocation and threat context, outputs a structured triage report |

---

## Requirements

```
azure-mgmt-securityinsight>=2.0.0
azure-identity>=1.15.0
requests>=2.31.0
```

Install:

```bash
pip install azure-mgmt-securityinsight azure-identity requests
```

---

## Authentication

Scripts use **DefaultAzureCredential** from the Azure Identity SDK. This supports:

- Azure CLI (`az login`)
- Managed Identity (when running in Azure)
- Service principal via environment variables:
  ```
  AZURE_TENANT_ID
  AZURE_CLIENT_ID
  AZURE_CLIENT_SECRET
  ```

Required RBAC role: **Microsoft Sentinel Reader** on the target workspace.

---

## Related

- CrowdStrike PowerShell modules → `../crowdstrike/api-modules/`
- Sentinel automation → `../../../../reference/sentinel/automate-deployment/`
