# NIST Cybersecurity Framework (CSF) — Portfolio Mapping

The **NIST Cybersecurity Framework (CSF)** provides a common language for describing cybersecurity risk management activities. It is organised around five core functions: Identify, Protect, Detect, Respond, and Recover.

This document maps the controls, tools, and documentation in this portfolio to the NIST CSF functions and categories, providing a framework view of the portfolio's coverage.

---

## Framework Overview

| Function | Purpose | Portfolio coverage |
|---|---|---|
| **Identify** | Understand assets, risks, and vulnerabilities | Asset inventory, risk assessments, compliance assessments |
| **Protect** | Implement safeguards to limit impact | Identity controls, endpoint hardening, email security, network security |
| **Detect** | Identify cybersecurity events | SIEM detection rules, KQL analytics, monitoring workbooks |
| **Respond** | Take action on detected incidents | Incident response playbooks, CrowdStrike automation |
| **Recover** | Restore capabilities after an incident | Backup configuration, recovery runbooks |

---

## Identify (ID)

### Asset Management (ID.AM)

Physical and software assets are inventoried and managed.

| Portfolio element | CSF subcategory |
|---|---|
| CIS benchmark converter — extract controls from CIS PDFs → `../../reference/endpoint-hardening/scripts/` | ID.AM-2: Software platforms and applications are inventoried |
| CrowdStrike cloud asset visibility → `../../reference/automation/crowdstrike/api-modules/cloud-security-assets/` | ID.AM-2 |
| CrowdStrike container security → `../../reference/automation/crowdstrike/api-modules/container-security/` | ID.AM-2 |

### Risk Assessment (ID.RA)

The organisation understands cybersecurity risk.

| Portfolio element | CSF subcategory |
|---|---|
| ASD Essential Eight maturity assessment → `../asd-essential-eight/maturity-assessment-template.md` | ID.RA-1: Asset vulnerabilities are identified and documented |
| CIS benchmark controls → `../../reference/endpoint-hardening/benchmarks/` | ID.RA-3: Threats are identified and documented |

---

## Protect (PR)

### Identity Management and Access Control (PR.AC)

Access to assets is limited to authorised users.

| Portfolio element | CSF subcategory |
|---|---|
| MFA deployment and passwordless → `../../reference/identity-access/guides/` | PR.AC-1: Identities and credentials are managed |
| Conditional Access policies → `../../reference/identity-access/policies/` | PR.AC-3: Remote access is managed |
| 802.1X network access control → `../../reference/network-security/` | PR.AC-5: Network integrity protected (network segregation) |
| WHFB, Passkey, TAP deployment → `../../reference/identity-access/guides/` | PR.AC-7: Users are authenticated commensurate with risk |

### Awareness and Training (PR.AT)

| Portfolio element | CSF subcategory |
|---|---|
| Customer communication templates in IR playbooks → `../../incident-response/` | PR.AT-1: Users are informed and trained |

### Data Security (PR.DS)

| Portfolio element | CSF subcategory |
|---|---|
| Proofpoint Data Security Workbench (DLP) → `../../reference/email-security/guides/proofpoint/data-security-workbench/` | PR.DS-1: Data-at-rest is protected |
| Data exfiltration response playbook → `../../incident-response/data-exfiltration-response-playbook.md` | PR.DS-5: Protections against data leaks implemented |

### Protective Technology (PR.PT)

| Portfolio element | CSF subcategory |
|---|---|
| CIS benchmarks (Windows, RHEL, browsers) → `../../reference/endpoint-hardening/benchmarks/` | PR.PT-3: Principle of least functionality applied |
| Palo Alto SSL decryption → `../../reference/network-security/` | PR.PT-4: Communications protected |
| Cisco Umbrella DNS security → `../../reference/network-security/guides/` | PR.PT-4 |
| ASD Essential Eight implementation → `../asd-essential-eight/implementation-guidance.md` | PR.PT-3, PR.PT-4 |

---

## Detect (DE)

### Anomalies and Events (DE.AE)

| Portfolio element | CSF subcategory |
|---|---|
| Microsoft Sentinel analytics rules → `../../reference/sentinel/` | DE.AE-1: Baseline of network operations established |
| KQL hunting queries → `../../reference/sentinel/hunting/` | DE.AE-2: Detected events analysed to understand attack targets and methods |
| CrowdStrike ZTA score retrieval → `../../reference/automation/crowdstrike/api-modules/zero-trust-assessment/` | DE.AE-3: Event data collected and correlated |

### Security Continuous Monitoring (DE.CM)

| Portfolio element | CSF subcategory |
|---|---|
| Microsoft Sentinel workbooks → `../../reference/sentinel/workbooks/` | DE.CM-1: Network monitoring performed |
| CrowdStrike incident management → `../../reference/automation/crowdstrike/api-modules/incidents/` | DE.CM-4: Malicious code detected |
| Proofpoint TAP API → `../../reference/email-security/api/proofpoint/` | DE.CM-3: Personnel activity monitored |
| Meraki API monitoring → `../../reference/network-security/api/meraki/` | DE.CM-1 |

### Detection Processes (DE.DP)

| Portfolio element | CSF subcategory |
|---|---|
| Sentinel detection operations → `../../projects/security-operations/sentinel-detection-operations-foundation.md` | DE.DP-1: Roles and responsibilities for detection defined |
| Security event investigation methodology → `../../projects/security-operations/security-event-investigation-methodology.md` | DE.DP-4: Event detection information communicated |

---

## Respond (RS)

### Response Planning (RS.RP)

| Portfolio element | CSF subcategory |
|---|---|
| Incident response playbooks → `../../incident-response/` | RS.RP-1: Response plan executed during/after incident |

### Communications (RS.CO)

| Portfolio element | CSF subcategory |
|---|---|
| Customer communication templates in IR playbooks → `../../incident-response/` | RS.CO-2: Incidents reported to stakeholders |
| Post-incident documentation sections → `../../incident-response/` | RS.CO-3: Information shared with appropriate parties |

### Analysis (RS.AN)

| Portfolio element | CSF subcategory |
|---|---|
| Security event investigation methodology → `../../projects/security-operations/security-event-investigation-methodology.md` | RS.AN-1: Notifications from detection systems investigated |
| KQL forensic queries in IR playbooks → `../../incident-response/` | RS.AN-3: Forensics performed |
| CrowdStrike indicators → `../../reference/automation/crowdstrike/api-modules/indicators/` | RS.AN-4: Incidents categorised |

### Mitigation (RS.MI)

| Portfolio element | CSF subcategory |
|---|---|
| Containment sections in all IR playbooks → `../../incident-response/` | RS.MI-1: Incidents contained |
| CrowdStrike installation token management → `../../reference/automation/crowdstrike/api-modules/installation-tokens/` | RS.MI-3: Newly identified vulnerabilities mitigated |

---

## Recover (RC)

### Recovery Planning (RC.RP)

| Portfolio element | CSF subcategory |
|---|---|
| Eradication and recovery sections in IR playbooks → `../../incident-response/` | RC.RP-1: Recovery plan executed during/after incident |
| ASD Essential Eight — Control 8 (backups) → `../asd-essential-eight/implementation-guidance.md` | RC.RP-1 |
| Veeam security configuration → `../../reference/endpoint-hardening/` | RC.RP-1 |

### Improvements (RC.IM)

| Portfolio element | CSF subcategory |
|---|---|
| Lessons-learned sections in all IR playbooks → `../../incident-response/` | RC.IM-1: Recovery plans incorporate lessons learned |

---

## Coverage Summary

| CSF Function | Portfolio coverage level |
|---|---|
| Identify | Moderate — asset inventory via CrowdStrike, risk assessment via E8 template |
| Protect | Strong — identity controls, endpoint hardening, network security, email security |
| Detect | Strong — Sentinel SIEM, KQL analytics, workbooks, CrowdStrike integration |
| Respond | Strong — four IR playbooks, investigation methodology, automation scripts |
| Recover | Moderate — backup configuration, recovery steps within IR playbooks |

---

## Related

- [ASD Essential Eight](../asd-essential-eight/README.md)
- [Incident Response](../../incident-response/README.md)
- [Microsoft Sentinel](../../reference/sentinel/)
