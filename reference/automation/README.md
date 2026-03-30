# Automation

Scripts, runbooks, templates, and API modules for security automation across CrowdStrike Falcon, infrastructure deployment, and DevSecOps tooling.

---

## Structure

```
automation/
├── crowdstrike/
│   └── api-modules/                  # 6 PowerShell modules for Falcon API
│       ├── cloud-security-assets/
│       ├── container-security/
│       ├── incidents/
│       ├── indicators/
│       ├── installation-tokens/
│       └── zero-trust-assessment/
├── runbooks/
│   ├── README.md                     # Runbook index
│   └── windows-on-openshift-runbook.md  # Windows workload on OpenShift
└── templates/
    ├── README.md                     # Template index
    └── windows2k22-server-medium.yaml   # Windows Server 2022 VM template
```

---

## Key Documents

| Path | Description |
|------|-------------|
| `crowdstrike/` | CrowdStrike Falcon API PowerShell modules |
| `runbooks/windows-on-openshift-runbook.md` | Deploy Windows workloads on OpenShift |
| `templates/windows2k22-server-medium.yaml` | Windows Server 2022 medium-sized VM spec |

---

## Related

- Sentinel deployment automation → `../../sentinel/Automate-deployment/`
- Proofpoint API reference → `../email-security/api/proofpoint/`
