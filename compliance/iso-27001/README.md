# ISO 27001:2022 — Overview

**ISO/IEC 27001:2022** is the international standard for Information Security Management Systems (ISMS). It defines requirements for establishing, implementing, maintaining, and continually improving an ISMS — a systematic approach to managing sensitive information and ensuring its confidentiality, integrity, and availability.

The 2022 revision (replacing ISO 27001:2013) restructured the Annex A control set from 114 controls across 14 domains to **93 controls across 4 themes**, reflecting the modern threat landscape including cloud security, threat intelligence, and ICT supply chain security.

---

## Standard Structure

ISO 27001:2022 consists of two main parts:

| Part | Contents |
|---|---|
| **Clauses 4–10** (normative) | ISMS management requirements: context, leadership, planning, support, operation, performance evaluation, improvement |
| **Annex A** (normative reference) | 93 information security controls across 4 themes, referenced from the Statement of Applicability |

Organisations seeking certification are audited against Clauses 4–10. Annex A controls are selected based on a risk assessment and documented in a **Statement of Applicability (SoA)**.

---

## Annex A Themes (2022)

| Theme | Controls | Scope |
|---|---|---|
| **A.5 Organisational Controls** | 37 controls | Policies, roles, incident management, supplier security, compliance |
| **A.6 People Controls** | 8 controls | Screening, terms of employment, awareness, disciplinary process |
| **A.7 Physical Controls** | 14 controls | Physical security perimeters, clear desk, equipment security |
| **A.8 Technological Controls** | 34 controls | Access control, cryptography, logging, vulnerability management, malware |

---

## Key Changes in ISO 27001:2022

### New controls introduced (11 new in 2022)

| Control | Description |
|---|---|
| A.5.7 Threat intelligence | Collecting and analysing information about threats |
| A.5.23 Information security for cloud services | Acquiring, using, and managing cloud services |
| A.5.30 ICT readiness for business continuity | ICT availability planning aligned to BC objectives |
| A.8.9 Configuration management | Managing secure configurations for hardware, software, services |
| A.8.10 Information deletion | Ensuring information is deleted when no longer required |
| A.8.11 Data masking | Masking of sensitive data in line with access control policy |
| A.8.12 Data leakage prevention | Detecting and preventing unauthorised disclosure of information |
| A.8.16 Monitoring activities | Monitoring networks, systems, and applications for anomalous behaviour |
| A.8.23 Web filtering | Controlling access to external websites to reduce malware exposure |
| A.8.28 Secure coding | Applying secure coding principles to software development |
| A.8.29 Security testing in DevOps | Integrating security testing into development and deployment pipelines |

---

## Certification Context

This portfolio includes content aligned to ISO 27001:2022 Annex A controls across multiple domains:

- **Incident response playbooks** (A.5.24–A.5.28) — structured playbooks for account compromise, BEC, ransomware, privileged access abuse, network intrusion, cloud account compromise, malicious code execution
- **Identity and access controls** (A.5.15, A.5.18, A.8.2) — MFA, passwordless, PIM, Conditional Access
- **Endpoint hardening** (A.8.7, A.8.8, A.8.9) — CIS benchmarks, patch management, configuration baselines
- **Detection and monitoring** (A.8.15, A.8.16) — Sentinel analytics rules, KQL hunting queries, workbooks
- **Email and web security** (A.8.23, A.8.12) — Proofpoint TAP, DLP, Cisco Umbrella
- **Cloud security** (A.5.23) — AWS log onboarding, Entra ID, Azure security

---

## Policy Documents

The `policies/` subfolder contains draft organisational policies aligned to ISO 27001:2022 Annex A controls:

| Policy | Code | Annex A Alignment |
|---|---|---|
| Acceptable Use Policy | POL-GEN-001 | A.5.10, A.6.2 |
| Privacy Policy | POL-GEN-002 | A.5.34 |
| Disciplinary Procedure | POL-HR-001 | A.6.4 |
| Cryptographic Control Policy | POL-SEC-001 | A.8.24 |
| Credential Management Policy | POL-SEC-005 | A.5.17 |
| Security Training and Awareness Policy | POL-SEC-006 | A.6.3 |
| Information Security Policy | POL-SEC-007 | A.5.1 |
| Information Classification Policy | POL-SEC-008 | A.5.12, A.5.13 |
| Access Control Policy | POL-SEC-009 | A.5.15, A.8.2, A.8.3 |
| Secure System Design Standard | POL-SEC-010 | A.8.25, A.8.28 |
| Security Event and Incident Response Policy | POL-SEC-011 | A.5.24–A.5.28 |
| Responsible Use of AI Policy | POL-AI-001 | A.5.10, A.5.36 |
| AI Governance Policy | POL-AI-002 | A.5.36 |
| AI Data Governance Policy | POL-AI-003 | A.5.12, A.8.12 |
| AI Audit Logging and Performance Monitoring Policy | POL-AI-004 | A.8.15, A.8.16 |

---

## Contents

| Document | Description |
|---|---|
| [annex-a-controls.md](annex-a-controls.md) | Reference table of all 93 Annex A controls across the 4 themes |
| [portfolio-mapping.md](portfolio-mapping.md) | Cross-reference of portfolio content to Annex A controls |
| [policies/](policies/) | Organisational policy documents (docx) aligned to Annex A |

---

## Related

- [ASD Essential Eight](../asd-essential-eight/README.md) — Australian government baseline framework
- [NIST CSF](../nist-csf/README.md) — NIST Cybersecurity Framework portfolio mapping
- [Incident Response Playbooks](../../incident-response/README.md) — ISO 27001:2022 A.5.24–A.5.28 aligned playbooks
- [Identity Access Controls](../../reference/identity-access/README.md)
