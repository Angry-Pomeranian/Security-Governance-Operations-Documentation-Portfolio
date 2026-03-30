# ISO 27001:2022 — Portfolio Mapping

This document maps portfolio content to relevant ISO 27001:2022 Annex A controls. It can be used as an input when developing a Statement of Applicability (SoA) or demonstrating evidence of control implementation.

---

## A.5 — Organisational Controls

### A.5.7 Threat Intelligence

| Portfolio element | Evidence of control |
|---|---|
| Sentinel KQL hunting queries → `../../reference/sentinel/hunting/` | Threat hunting using current TTPs from MITRE ATT&CK |
| AWS GuardDuty integration → `../../reference/sentinel/manual/aws/guardduty/` | Cloud threat intelligence ingested into centralised SIEM |
| CrowdStrike indicators module → `../../reference/automation/crowdstrike/api-modules/indicators/` | IOC management and threat indicator correlation |

### A.5.14 Information Transfer

| Portfolio element | Evidence of control |
|---|---|
| Proofpoint TAP API integration → `../../reference/email-security/api/proofpoint/` | Email-borne data transfer monitoring and threat detection |
| Data Security Workbench (DLP) → `../../reference/email-security/guides/proofpoint/data-security-workbench/` | Data leakage prevention across endpoints and cloud |
| BEC incident response playbook → `../../incident-response/business-email-compromise-playbook.md` | Controls for information transfer misuse and BEC detection |

### A.5.15 Access Control

| Portfolio element | Evidence of control |
|---|---|
| Conditional Access policies → `../../reference/identity-access/policies/conditional-access/` | Enforced access control based on user, device, location, and risk |
| PIM server access guide → `../../reference/identity-access/guides/passwordless/servers/` | Just-in-time privileged access |
| Privileged access abuse playbook → `../../incident-response/privileged-access-abuse-playbook.md` | Detection and response for access control violations |

### A.5.16 Identity Management

| Portfolio element | Evidence of control |
|---|---|
| MFA deployment guide → `../../reference/identity-access/guides/mfa/` | Identity verification through multifactor authentication |
| Passwordless rollout (WHfB, Passkey, TAP, Authenticator) → `../../reference/identity-access/guides/passwordless/` | Modern identity management reducing credential risk |

### A.5.18 Access Rights

| Portfolio element | Evidence of control |
|---|---|
| BYOD MAM/App Protection policy → `../../reference/identity-access/policies/conditional-access/byomd-app-protect/` | Access rights scoped to managed apps on unmanaged devices |
| CrowdStrike installation tokens module → `../../reference/automation/crowdstrike/api-modules/installation-tokens/` | Controlled provisioning of access to security tooling |

### A.5.23 Information Security for Cloud Services

| Portfolio element | Evidence of control |
|---|---|
| AWS CloudTrail integration → `../../reference/sentinel/manual/aws/cloudtrail/` | Audit logging for cloud service usage |
| AWS GuardDuty integration → `../../reference/sentinel/manual/aws/guardduty/` | Threat detection in cloud environments |
| Cloud account compromise playbook → `../../incident-response/cloud-account-compromise-playbook.md` | Response procedures for cloud service security incidents |
| CrowdStrike cloud security assets → `../../reference/automation/crowdstrike/api-modules/cloud-security-assets/` | Cloud workload visibility and security posture |

### A.5.24–A.5.28 Information Security Incident Management

These five controls collectively define the incident management lifecycle. All incident response playbooks in this portfolio are aligned to this control set.

| Control | Playbook evidence |
|---|---|
| A.5.24 Planning and preparation | All playbooks include detection triggers, triage steps, and defined response procedures |
| A.5.25 Assessment and decision | Triage and severity classification sections in all playbooks |
| A.5.26 Response | Containment, eradication, and recovery actions in all playbooks |
| A.5.27 Learning from incidents | Post-incident review and lessons learned sections |
| A.5.28 Collection of evidence | Evidence preservation steps, KQL export queries, forensic reconstruction procedures |

| Playbook | Primary controls |
|---|---|
| [Account compromise](../../incident-response/account-compromise-playbook.md) | A.5.24, A.5.25, A.5.26, A.5.27, A.5.28, A.5.15 |
| [Cloud account compromise](../../incident-response/cloud-account-compromise-playbook.md) | A.5.24–A.5.28, A.5.23, A.8.15, A.8.16 |
| [Malicious code execution](../../incident-response/malicious-code-execution-playbook.md) | A.5.24–A.5.28, A.8.7, A.8.8, A.8.16 |
| [Privileged access abuse](../../incident-response/privileged-access-abuse-playbook.md) | A.5.24–A.5.28, A.5.15, A.5.18, A.8.2, A.8.16 |
| [Business email compromise](../../incident-response/business-email-compromise-playbook.md) | A.5.24–A.5.28, A.5.14, A.6.8, A.8.12, A.8.23 |
| [Network intrusion](../../incident-response/network-intrusion-playbook.md) | A.5.24–A.5.28, A.8.16, A.8.20, A.8.21, A.8.22, A.8.23 |
| [Ransomware response](../../incident-response/ransomware-response-playbook.md) | A.5.24–A.5.28, A.8.7, A.8.13 |
| [Phishing investigation](../../incident-response/phishing-investigation-playbook.md) | A.5.24–A.5.28, A.6.8, A.8.23 |
| [Data exfiltration](../../incident-response/data-exfiltration-response-playbook.md) | A.5.24–A.5.28, A.8.12, A.5.14 |

---

## A.6 — People Controls

### A.6.8 Information Security Event Reporting

| Portfolio element | Evidence of control |
|---|---|
| Phishing investigation playbook → `../../incident-response/phishing-investigation-playbook.md` | Procedures for handling user-reported phishing events |
| BEC incident response playbook → `../../incident-response/business-email-compromise-playbook.md` | Channels and procedures for reporting suspected BEC |

---

## A.8 — Technological Controls

### A.8.2 Privileged Access Rights

| Portfolio element | Evidence of control |
|---|---|
| PIM server access guide → `../../reference/identity-access/guides/passwordless/servers/` | Time-bound privileged role activation via PIM |
| Disable USB policies → `../../reference/identity-access/policies/conditional-access/disable-usb-v1/` | Restricting device installation privileges |
| Privileged access abuse playbook → `../../incident-response/privileged-access-abuse-playbook.md` | Detection and response for privilege misuse |

### A.8.7 Protection Against Malware

| Portfolio element | Evidence of control |
|---|---|
| CrowdStrike API modules → `../../reference/automation/crowdstrike/` | Endpoint detection and response, malware containment |
| CIS benchmark — Microsoft Defender AV → `../../reference/endpoint-hardening/benchmarks/applications/microsoft/` | AV configuration baseline |
| Malicious code execution playbook → `../../incident-response/malicious-code-execution-playbook.md` | Malware response procedures |

### A.8.8 Management of Technical Vulnerabilities

| Portfolio element | Evidence of control |
|---|---|
| CIS benchmarks (OS and applications) → `../../reference/endpoint-hardening/benchmarks/` | Benchmark controls include patching and vulnerability guidance |
| CrowdStrike zero-trust assessment → `../../reference/automation/crowdstrike/api-modules/zero-trust-assessment/` | Endpoint security posture and vulnerability scoring |

### A.8.9 Configuration Management

| Portfolio element | Evidence of control |
|---|---|
| CIS benchmark controls (Windows, RHEL, browsers) → `../../reference/endpoint-hardening/` | Configuration baselines for OS and browsers |
| Intune Conditional Access policies → `../../reference/identity-access/policies/conditional-access/` | Enforced device configuration via MEM |
| CIS benchmark converter → `../../reference/endpoint-hardening/scripts/` | Extract and track configuration controls at scale |

### A.8.12 Data Leakage Prevention

| Portfolio element | Evidence of control |
|---|---|
| Proofpoint Data Security Workbench → `../../reference/email-security/guides/proofpoint/data-security-workbench/` | Endpoint and cloud DLP detection and investigation |
| BEC playbook — data exfiltration detection → `../../incident-response/business-email-compromise-playbook.md` | KQL queries for detecting data exfiltration via email |
| Data exfiltration playbook → `../../incident-response/data-exfiltration-response-playbook.md` | DLP incident response procedures |

### A.8.15 Logging

| Portfolio element | Evidence of control |
|---|---|
| Microsoft Sentinel connectors → `../../reference/sentinel/manual/` | Centralised log ingestion from Entra ID, M365, AWS, Cisco Umbrella |
| AWS CloudTrail and GuardDuty → `../../reference/sentinel/manual/aws/` | Cloud audit logging |
| Azure Activity and Entra ID logs → `../../reference/sentinel/manual/azure/` | Identity and Azure platform activity logging |
| Sentinel deployment tracker → `../../reference/sentinel/automate-deployment/sentinel-deployment-tracker/` | Log source coverage tracking |

### A.8.16 Monitoring Activities

| Portfolio element | Evidence of control |
|---|---|
| Sentinel analytics rules → `../../reference/sentinel/templates/arm/` | Automated alerting on anomalous activity |
| KQL hunting queries → `../../reference/sentinel/hunting/` | Proactive threat hunting across collected logs |
| Sentinel workbooks → `../../reference/sentinel/workbooks/` | Continuous visibility dashboards |
| Impossible travel pipeline → `../../pipeline/` | Full detection-to-response pipeline for identity anomalies |

### A.8.20–A.8.22 Network Security

| Control | Portfolio element |
|---|---|
| A.8.20 Network security | 802.1X, Palo Alto SSL decryption, EDL → `../../reference/network-security/README.md` |
| A.8.21 Security of network services | Cisco Umbrella DNS security → `../../reference/sentinel/manual/cisco/umbrella/` |
| A.8.22 Segregation of networks | VLAN and firewall architecture in network security guide |

### A.8.23 Web Filtering

| Portfolio element | Evidence of control |
|---|---|
| Cisco Umbrella integration → `../../reference/sentinel/manual/cisco/umbrella/` | DNS-layer web filtering with Sentinel integration |
| Cisco Umbrella GUI guide → `../../reference/network-security/guides/` | Operational configuration of web filtering |
| Network intrusion playbook → `../../incident-response/network-intrusion-playbook.md` | C2 and malicious domain blocking via Umbrella |

---

## Coverage Summary

| Theme | Controls in scope | Portfolio coverage |
|---|---|---|
| A.5 Organisational | A.5.7, A.5.14, A.5.15, A.5.16, A.5.18, A.5.23, A.5.24–A.5.28 | Strong — incident management fully documented |
| A.6 People | A.6.8 | Partial — event reporting procedures via IR playbooks |
| A.7 Physical | None directly | Out of scope for this technical portfolio |
| A.8 Technological | A.8.2, A.8.7, A.8.8, A.8.9, A.8.12, A.8.15, A.8.16, A.8.20–A.8.23 | Strong — detection, hardening, and response well covered |
