# Incident Response

Operational playbooks for investigating and responding to security incidents. Each playbook follows a consistent six-phase structure aligned to the NIST SP 800-61 incident response lifecycle, with ISO 27001:2022 control references embedded throughout.

---

## Playbooks

### Original Set

| Playbook | Scenario | Severity |
|---|---|---|
| [Account Compromise](account-compromise-playbook.md) | Credential theft, BEC, unauthorised access | High |
| [Ransomware Response](ransomware-response-playbook.md) | Ransomware deployment, encryption events | Critical |
| [Phishing Investigation](phishing-investigation-playbook.md) | Spear-phishing, credential harvesting, malicious attachments | Medium–High |
| [Data Exfiltration Response](data-exfiltration-response-playbook.md) | Unauthorised data transfer, DLP alerts, insider threat indicators | High |

### ISO 27001:2022 Aligned Set

The following playbooks are based on scenarios already documented across the portfolio's case studies, architecture, and detection engineering content. Each playbook includes an **ISMS Obligations** section mapping response actions to specific ISO 27001:2022 Annex A controls.

| Playbook | Scenario | Severity | Key ISO 27001:2022 Controls |
|---|---|---|---|
| [Cloud Account Compromise](cloud-account-compromise-playbook.md) | AWS root/IAM abuse, GuardDuty findings, API key theft | High–Critical | A.5.23 · A.5.26 · A.5.28 · A.8.15 · A.8.16 |
| [Malicious Code Execution](malicious-code-execution-playbook.md) | EDR alert, offensive tooling, script execution, LSASS access | High–Critical | A.8.7 · A.8.8 · A.5.26 · A.5.28 · A.8.16 |
| [Privileged Access Abuse](privileged-access-abuse-playbook.md) | PIM abuse, admin misuse, service account compromise | High–Critical | A.5.15 · A.5.18 · A.8.2 · A.5.26 · A.5.28 |
| [Business Email Compromise](business-email-compromise-playbook.md) | Mail forwarding rules, executive impersonation, payment fraud | High–Critical | A.5.14 · A.6.8 · A.8.12 · A.5.26 · A.5.28 |
| [Network Intrusion](network-intrusion-playbook.md) | DNS C2, firewall IPS alerts, lateral movement, VPC anomalies | Medium–Critical | A.8.20 · A.8.21 · A.8.22 · A.8.23 · A.5.26 |

---

## Playbook Structure

Each playbook follows this six-phase structure:

1. **Detection** — alert triggers, SIEM signatures, KQL detection queries, and user-reported indicators
2. **Triage** — initial scoping, log source review, and severity classification
3. **Containment** — immediate actions to limit blast radius and prevent spread
4. **Investigation** — forensic analysis, evidence collection, KQL and tool-specific queries
5. **Eradication and Recovery** — remediation steps and return-to-operations verification
6. **Post-Incident** — stakeholder communication, evidence preservation, ISMS obligations, and lessons-learned review

---

## ISO 27001:2022 Annex A — Incident Management Controls Reference

The ISO 27001:2022 aligned playbooks implement the following core controls in every response:

| Control | Description | Where Applied |
|---|---|---|
| A.5.24 | Information security incident management planning and preparation | All playbooks — detection and triage phases |
| A.5.25 | Assessment and decision on information security events | All playbooks — triage and severity classification |
| A.5.26 | Response to information security incidents | All playbooks — containment through recovery |
| A.5.27 | Learning from information security incidents | All playbooks — lessons-learned review |
| A.5.28 | Collection of evidence | All playbooks — evidence preservation tables |

Scenario-specific controls (A.5.14, A.5.15, A.5.18, A.5.23, A.8.2, A.8.7, A.8.8, A.8.12, A.8.15, A.8.16, A.8.20–A.8.23) are documented in the ISMS Obligations section of each individual playbook.

---

## Related

- Detection rules and KQL → `../reference/sentinel/`
- Compliance framework context → `../compliance/`
- Identity and Conditional Access controls → `../reference/identity-access/`
- CrowdStrike automation modules → `../reference/automation/crowdstrike/`
- Email security guides → `../reference/email-security/`
- Network security reference → `../reference/network-security/`
- AWS telemetry and connectors → `../reference/sentinel/manual/aws/`
