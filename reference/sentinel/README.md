# Microsoft Sentinel Reference

Documentation, deployment artifacts, detection content, and operational resources for Microsoft Sentinel. This covers both automated and manual deployment approaches, KQL hunting and analytic content, and workbook development.

---

## Directory Structure

| Directory | Contents |
|---|---|
| `automate-deployment/` | Scripted connector deployment including AWS CloudTrail, GuardDuty, and VPC Flow Logs via S3/SQS ingestion pipelines |
| `manual/` | Step-by-step connector setup and configuration guides for manual Sentinel deployments |
| `hunting/` | Threat hunting queries organised by scenario and threat actor technique |
| `queries/` | KQL reference queries for investigation, triage, and data validation |
| `templates/` | ARM deployment templates for Sentinel resources and connector configuration |
| `workbooks/` | Custom Sentinel workbooks for operational monitoring and governance reporting |

---

## Hunting Content

Hunting queries are organised by detection scenario. Current coverage includes:

- **Kali Linux WSL Execution Detection** — identifies Kali Linux execution patterns via Windows Subsystem for Linux, surfacing potential attacker tooling running within managed endpoints

---

## Related

- AWS telemetry onboarding case study: [`case-studies/aws-cloud-telemetry-centralization.md`](../../case-studies/aws-cloud-telemetry-centralization.md)
- SIEM foundation case study: [`case-studies/siem-monitoring-foundation.md`](../../case-studies/siem-monitoring-foundation.md)
- Incident response playbooks: [`incident-response/`](../../incident-response/)
