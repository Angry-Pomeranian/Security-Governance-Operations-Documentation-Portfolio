# Reference — Technical Documentation Library

Detailed implementation guides, policy definitions, automation scripts, and API references organised by security domain and artifact type.

---

## Structure

```
reference/
├── identity-access/          # MFA, passwordless, Conditional Access policies
├── endpoint-hardening/       # CIS benchmarks (OS, browsers, cloud, containers, network, apps), tooling
├── network-security/         # 802.1X, Cisco Umbrella, Meraki API
├── email-security/           # Proofpoint TAP, Data Security Workbench (DLP/ITM), AI governance
├── automation/               # CrowdStrike Falcon API modules, runbooks, scripts
└── sentinel/                 # Microsoft Sentinel — connectors, KQL, workbooks, deployment
```

Each domain follows a consistent second-level layout:

| Artifact type | Contains |
|---|---|
| `guides/` | Step-by-step implementation guides |
| `policies/` | Policy definitions, configuration files, and validation scripts |
| `benchmarks/` | CIS benchmark PDFs and extracted control references |
| `scripts/` | Standalone scripts and utilities |
| `api/` | API integration references and endpoint documentation |
| `runbooks/` | Operational runbooks for repeatable delivery |
| `templates/` | Deployment templates (ARM, JSON) |

---

## Domains

### [identity-access/](identity-access/)
MFA deployment, passwordless rollout (Windows Hello for Business, Passkey/FIDO2, Microsoft Authenticator, Temporary Access Pass, Azure AD B2C), and Conditional Access policies — USB device restriction, BYOD MAM/App Protection, browser extension control, Windows Hello hardening, and CIS browser baseline deployment via Intune.

Includes PowerShell validation scripts for each policy and auditor summaries for the Chrome and Edge CIS baselines.

### [endpoint-hardening/](endpoint-hardening/)
CIS benchmark library covering:
- **Operating systems:** Windows Server (2012 R2 – 2025), Windows 10/11 via Intune, RHEL 8/9/10, Debian, Ubuntu, Oracle Linux
- **Browsers:** Chrome, Edge, Firefox (ESR), Safari
- **Cloud platforms:** AWS Foundations, Azure Foundations, Microsoft 365 Foundations
- **Containers:** Docker, Kubernetes, AKS, OpenShift
- **Network devices:** Cisco Firewall, FortiGate, Palo Alto
- **Applications:** SQL Server, MySQL, Microsoft Defender AV, SharePoint, VS Code, Apache HTTP Server

Includes the `cis_benchmark_converter.py` utility for extracting controls from CIS PDFs into Excel/CSV/JSON, and `cis_batch_runner.py` for bulk processing.

### [network-security/](network-security/)
Enterprise network access control guide (802.1X, ClearPass, SEPMAN, Palo Alto SSL decryption, Microsoft 365 EDL), Cisco Umbrella DNS security operations suite (11 guides across deployment, administration, troubleshooting, and reporting), and Cisco Meraki Dashboard API v1 reference.

### [email-security/](email-security/)
Proofpoint TAP API integration pipeline (Azure Function → Sentinel → Grafana), Proofpoint Data Security Workbench (DLP/ITM) activity event reference, email threat architecture, and the AI governance guide suite (9 guides covering CASB shadow AI discovery, GenAI DLP detection, Isolation Console, TAP integration, and OAuth governance).

### [automation/](automation/)
CrowdStrike Falcon API PowerShell modules (incidents, indicators, installation tokens, cloud assets, container security, zero-trust assessment), Windows-on-OpenShift operational runbook, Python scripts for Sentinel alert enrichment, and infrastructure deployment templates.

### [sentinel/](sentinel/)
Microsoft Sentinel deployment and operations resources:
- **automate-deployment/** — AWS connector automation scripts (CloudTrail, GuardDuty, VPC Flow, CloudWatch), CloudFormation templates, deployment tracker watchlists and workbooks
- **manual/** — Step-by-step data connector onboarding guides (AWS, Azure, Cisco Umbrella, Proofpoint TAP)
- **hunting/** — KQL threat hunting queries
- **queries/** — Analytical and operational KQL queries
- **templates/** — ARM templates for analytics rules, ML behaviour analytics, hunting rules, workbook deployment
- **workbooks/** — Dashboard JSON for 18+ platforms (Microsoft, AWS, Cisco, Proofpoint, Palo Alto, FortiGate, Duo, CrowdStrike, and AI/Copilot workbooks)

---

## Related

| Section | Path |
|---|---|
| Portfolio case studies | [`../case-studies/`](../case-studies/) |
| Architecture diagrams | [`../architecture/`](../architecture/) |
| Incident response playbooks | [`../incident-response/`](../incident-response/) |
| Compliance frameworks | [`../compliance/`](../compliance/) |
