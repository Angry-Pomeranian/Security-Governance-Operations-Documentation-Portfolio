# Certifications

Professional certifications and formal education demonstrating technical security competency across operations, governance, and platform-specific tooling.

---

## Summary

| Certification | Issuing Body | Achieved | Domain |
|---|---|---|---|
| Cybersecurity Certificate | Monash University | Jun 2022 | Security fundamentals, cloud, IAM |
| CompTIA Security+ | CompTIA | — | Security operations, threat analysis |
| ISO 27001:2022 | Citation Certification | — | Information security management |
| Threat Protection Level 1 — Administrators and Analysts | Proofpoint | — | Email threat detection and response |
| ThreatSim Foundations — Level 1 | Proofpoint | — | Phishing simulation administration |
| Security Awareness Training: Platform — Level 1 | Proofpoint | — | SAT platform configuration |
| Security Awareness Training: User Management — Level 1 | Proofpoint | — | SAT user lifecycle management |
| Security Awareness Training: Modules — Level 1 | Proofpoint | — | Content and campaign configuration |
| Security Awareness Training: Notifications — Level 2 | Proofpoint | — | Alert and notification workflows |
| SEC 202: Assignments — Level 2 | Proofpoint | — | Advanced SAT campaign management |

---

## Certification Details

### Cybersecurity Certificate — Monash University

**Issuing body:** Monash University
**Completed:** Jun 2022
**Grade:** A+
**Activities:** MoNu-Virt-Cyber11 Group

**Coverage:** Secure network design and architecture, cloud security via Azure Lab, risk management, vulnerability assessment, identity and access management, and detection of suspicious user behaviour. Practical lab work included configuring virtual machines, deploying to cloud environments, and investigating cloud-based security risks.

**Relevance to this portfolio:** Provides the foundational academic grounding for the hands-on Sentinel, Entra ID, and endpoint hardening work documented throughout this repository.

---

### CompTIA Security+

**Issuing body:** CompTIA
**Domain:** Security operations, threat analysis, network security, cryptography, identity management

**Relevance:** Validates broad security operations competency directly applicable to the SOC analyst and incident response work documented in `../incident-response/` and `../projects/security-operations/`. Covers threat detection methodologies aligned with the KQL detection engineering and alert triage workflows in this portfolio.

---

### ISO 27001:2022

**Issuing body:** Citation Certification (formerly Best Practice Certification)
**Standard:** ISO/IEC 27001:2022 — Information Security Management Systems

**Relevance:** Demonstrates working knowledge of the ISMS framework including risk treatment, control selection, and audit methodology. Directly supports the governance and compliance documentation in `../compliance/`, particularly the NIST CSF mapping and policy alignment work. ISO 27001 Annex A controls map closely to the ASD Essential Eight and NIST CSF controls covered in this portfolio.

---

### Threat Protection Level 1 — Administrators and Analysts

**Issuing body:** Proofpoint
**Domain:** Email threat detection, URL defence, attachment sandboxing, TAP alert triage

**Relevance:** Covers the operational use of Proofpoint Targeted Attack Protection (TAP) from both an administrator and analyst perspective — directly applicable to the Proofpoint integration guides and phishing investigation playbook documented in `../incident-response/phishing-investigation-playbook.md` and `../reference/email-security/`.

---

### Proofpoint Security Awareness Training — Certification Track

The following certifications cover the full Proofpoint Security Awareness Training (SAT) platform at both Level 1 and Level 2:

| Certification | Level | Coverage |
|---|---|---|
| ThreatSim Foundations | Level 1 | Phishing simulation design, campaign launch, reporting |
| SAT Platform | Level 1 | Platform navigation, tenant configuration, dashboard |
| SAT User Management | Level 1 | User provisioning, group management, directory sync |
| SAT Modules | Level 1 | Content library, custom modules, completion tracking |
| SAT Notifications | Level 2 | Alert configuration, escalation workflows, integrations |
| SEC 202: Assignments | Level 2 | Advanced campaign design, targeted assignment logic |

**Relevance:** End-to-end operational competency across the Proofpoint SAT platform — from initial tenant configuration through advanced phishing simulation and campaign reporting. Supports the SAT integration work documented in `../reference/email-security/`.

---

## Study Materials

Supporting notes and reference materials used during certification preparation:

| File | Certification | Description |
|---|---|---|
| [sc-300-study-guide.md](sc-300-study-guide.md) | SC-300 | High-level study notes across all four exam domains |
| [sc-300-exam-resources.md](sc-300-exam-resources.md) | SC-300 | Curated links — Microsoft Learn, practice tests, sandbox |
| [sc-300-lab-execution-order.md](sc-300-lab-execution-order.md) | SC-300 | Phased lab sequence optimised for exam coverage |
| [sc-300-identity-access-administrator-lab-notes.md](sc-300-identity-access-administrator-lab-notes.md) | SC-300 | Visual flashcard-style notes with screenshots across all domains |
| [pim-jit-passwordless-server-access.md](pim-jit-passwordless-server-access.md) | SC-300 | PIM + WHfB JIT server access — conceptual overview and configuration steps |
| [azure-ad-b2c-sso-setup-notes.md](azure-ad-b2c-sso-setup-notes.md) | Entra / B2C | Azure AD B2C single sign-on setup notes |
| [aws-cloud-practitioner-module-1-introduction.md](aws-cloud-practitioner-module-1-introduction.md) | AWS CCP | AWS CCP course — Module 1: Cloud fundamentals and deployment models |
| [aws-cloud-practitioner-module-2-compute.md](aws-cloud-practitioner-module-2-compute.md) | AWS CCP | AWS CCP course — Module 2: EC2, auto-scaling, load balancing |

---

## Notes on Experience Equivalence

Certifications represent a subset of demonstrated competency. Several platforms and frameworks in this portfolio reflect hands-on production experience beyond what any single certification covers:

- **Microsoft Sentinel** — SIEM configuration, KQL analytics, workbook authoring, and connector deployment in `../reference/sentinel/`
- **Microsoft Entra ID / Conditional Access** — MFA deployment, passwordless rollout, and Conditional Access policy design in `../reference/identity-access/`
- **CrowdStrike Falcon** — API module development and operational tooling in `../reference/automation/crowdstrike/`
- **Endpoint hardening** — CIS benchmark implementation for Windows, RHEL, Chrome, Edge, and Firefox in `../reference/endpoint-hardening/`
- **Incident response** — Playbooks for account compromise, ransomware, phishing, and data exfiltration in `../incident-response/`
- **Compliance frameworks** — ASD Essential Eight maturity assessment and NIST CSF mapping in `../compliance/`
