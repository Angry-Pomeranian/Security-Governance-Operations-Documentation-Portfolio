# CrowdStrike Automation

PowerShell modules for CrowdStrike Falcon API integration, covering incident management, indicator handling, installation tokens, container security, cloud asset visibility, and zero-trust assessment.

---

## Structure

```
crowdstrike/
└── api-modules/
    ├── cloud-security-assets/        # Cloud asset inventory via Falcon API
    ├── container-security/           # Container workload visibility
    ├── incidents/                    # Incident retrieval and triage automation
    ├── indicators/                   # IOC management (add/update/delete)
    ├── installation-tokens/          # Sensor installation token management
    └── zero-trust-assessment/        # Zero Trust Assessment score retrieval
```

---

## Module Reference

| Module | Script | Description |
|--------|--------|-------------|
| `incidents/` | `incidents.ps1` | Query and manage Falcon incidents |
| `indicators/` | `indicators.ps1` | Create and manage custom IOCs |
| `installation-tokens/` | `installation-tokens.ps1` | Generate and audit sensor install tokens |
| `cloud-security-assets/` | `cloud-security-assets.ps1` | Enumerate cloud assets via Falcon Horizon |
| `container-security/` | `container-security.ps1` | Container image and runtime assessment |
| `zero-trust-assessment/` | `zero-trust-assessment.ps1` | Pull ZTA score and device posture data |

Each module directory with a `README.md` contains usage examples and parameter references.
