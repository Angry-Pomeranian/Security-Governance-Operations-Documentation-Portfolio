# Skills Matrix

Competency depth across security domains and technologies represented in this portfolio. Depth is rated on a four-level scale:

| Level | Meaning |
|---|---|
| **Designing** | Architecting controls from requirements through to implementation plan; making technology and policy decisions |
| **Implementing** | Building and deploying the control end-to-end; writing the automation, configuring the platform, writing the documentation |
| **Operating** | Running, tuning, and maintaining the control in production; handling incidents, false positives, and changes |
| **Studying** | Actively learning — coursework, labs, or structured self-study underway |

---

## Identity and Access Security

| Technology / Capability | Depth | Portfolio evidence |
|---|---|---|
| Microsoft Entra ID — Conditional Access policy design | Implementing | [`reference/identity-access/policies/conditional-access/`](../reference/identity-access/policies/conditional-access/) |
| Passwordless authentication (WHfB, FIDO2, Authenticator passkey) | Implementing | [`reference/identity-access/guides/passwordless/`](../reference/identity-access/guides/passwordless/) |
| Temporary Access Pass (TAP) lifecycle | Implementing | [`reference/identity-access/policies/conditional-access/authentication-method-tap/`](../reference/identity-access/policies/conditional-access/authentication-method-tap/) |
| Privileged Identity Management (PIM) / JIT server access | Implementing | [`reference/identity-access/guides/passwordless/servers/`](../reference/identity-access/guides/passwordless/servers/) |
| Azure AD B2C — SSO setup | Implementing | [`reference/identity-access/guides/passwordless/b2c/`](../reference/identity-access/guides/passwordless/b2c/) |
| Microsoft Intune / MEM — policy deployment | Implementing | [`reference/identity-access/policies/conditional-access/`](../reference/identity-access/policies/conditional-access/) |
| SC-300 exam preparation | Studying | [`certification/sc-300-identity-access-administrator-lab-notes.md`](../certification/sc-300-identity-access-administrator-lab-notes.md) |

---

## Detection Engineering and SIEM

| Technology / Capability | Depth | Portfolio evidence |
|---|---|---|
| Microsoft Sentinel — connector deployment | Implementing | [`reference/sentinel/manual/`](../reference/sentinel/manual/) · [`reference/sentinel/automate-deployment/`](../reference/sentinel/automate-deployment/) |
| KQL — analytics rules and hunting queries | Implementing | [`reference/sentinel/hunting/`](../reference/sentinel/hunting/) · [`reference/sentinel/queries/`](../reference/sentinel/queries/) |
| Sentinel workbook/dashboard development | Implementing | [`reference/sentinel/workbooks/`](../reference/sentinel/workbooks/) |
| Sentinel ARM template authoring | Implementing | [`reference/sentinel/templates/`](../reference/sentinel/templates/) |
| AWS log source onboarding (CloudTrail, GuardDuty, VPC Flow) | Implementing | [`reference/sentinel/automate-deployment/aws/`](../reference/sentinel/automate-deployment/aws/) |
| Incident response triage and investigation | Operating | [`incident-response/`](../incident-response/) |

---

## Cloud Security

| Technology / Capability | Depth | Portfolio evidence |
|---|---|---|
| AWS CloudTrail, GuardDuty, VPC Flow Logs | Implementing | [`reference/sentinel/automate-deployment/`](../reference/sentinel/automate-deployment/) |
| AWS S3/SQS telemetry transport pipeline | Implementing | [`reference/sentinel/automate-deployment/aws/`](../reference/sentinel/automate-deployment/aws/) |
| AWS Cloud Practitioner | Studying | [`certification/aws-cloud-practitioner-module-1-introduction.md`](../certification/aws-cloud-practitioner-module-1-introduction.md) |
| Azure services (Logic Apps, Functions, Log Analytics) | Implementing | [`reference/email-security/api/proofpoint/`](../reference/email-security/api/proofpoint/) |

---

## Infrastructure and Endpoint Hardening

| Technology / Capability | Depth | Portfolio evidence |
|---|---|---|
| CIS benchmark application — Windows Server | Implementing | [`reference/endpoint-hardening/benchmarks/os/windows/`](../reference/endpoint-hardening/benchmarks/os/windows/) |
| CIS benchmark application — RHEL / Ubuntu / Debian | Implementing | [`reference/endpoint-hardening/benchmarks/os/`](../reference/endpoint-hardening/benchmarks/os/) |
| CIS benchmark application — Chrome / Edge / Firefox | Implementing | [`reference/endpoint-hardening/benchmarks/browsers/`](../reference/endpoint-hardening/benchmarks/browsers/) |
| CIS benchmark application — containers (Docker, Kubernetes, OpenShift) | Implementing | [`reference/endpoint-hardening/benchmarks/containers/`](../reference/endpoint-hardening/benchmarks/containers/) |
| CIS benchmark tooling (PDF converter, batch runner) | Implementing | [`reference/endpoint-hardening/scripts/`](../reference/endpoint-hardening/scripts/) |

---

## Email and Web Security

| Technology / Capability | Depth | Portfolio evidence |
|---|---|---|
| Proofpoint TAP — API pipeline (Azure Function → Sentinel) | Implementing | [`reference/email-security/api/proofpoint/`](../reference/email-security/api/proofpoint/) |
| Proofpoint Data Security Workbench (DLP/ITM) | Operating | [`reference/email-security/guides/proofpoint/data-security-workbench/`](../reference/email-security/guides/proofpoint/data-security-workbench/) |
| Proofpoint CASB, Isolation, TRAP | Designing | [`reference/email-security/guides/proofpoint/ai-governance/`](../reference/email-security/guides/proofpoint/ai-governance/) |
| Proofpoint DMARC/SPF/DKIM configuration | Operating | [`reference/email-security/guides/proofpoint/admin-guide.md`](../reference/email-security/guides/proofpoint/admin-guide.md) |
| Cisco Umbrella DNS security | Implementing | [`reference/network-security/guides/umbrella/`](../reference/network-security/guides/umbrella/) |
| GenAI / AI governance tooling | Designing | [`reference/email-security/guides/proofpoint/ai-governance/`](../reference/email-security/guides/proofpoint/ai-governance/) |

---

## Network Security

| Technology / Capability | Depth | Portfolio evidence |
|---|---|---|
| Cisco Meraki Dashboard API v1 | Implementing | [`reference/network-security/api/meraki/`](../reference/network-security/api/meraki/) |
| Cisco Umbrella — deployment, policy, troubleshooting | Implementing | [`reference/network-security/guides/umbrella/`](../reference/network-security/guides/umbrella/) |
| 802.1X / ClearPass / SEPMAN | Designing | [`reference/network-security/README.md`](../reference/network-security/README.md) |
| Palo Alto SSL decryption | Designing | [`reference/network-security/README.md`](../reference/network-security/README.md) |

---

## Automation and DevSecOps

| Technology / Capability | Depth | Portfolio evidence |
|---|---|---|
| PowerShell — security automation scripting | Implementing | [`reference/automation/`](../reference/automation/) · [`reference/sentinel/automate-deployment/`](../reference/sentinel/automate-deployment/) |
| Python — API clients and data processing | Implementing | [`reference/network-security/api/meraki/meraki_api_client.py`](../reference/network-security/api/meraki/meraki_api_client.py) · [`reference/automation/scripts/`](../reference/automation/scripts/) |
| CrowdStrike Falcon API | Implementing | [`reference/automation/crowdstrike/`](../reference/automation/crowdstrike/) |
| ARM / JSON deployment templates | Implementing | [`reference/sentinel/templates/`](../reference/sentinel/templates/) |
| GitHub Actions CI/CD | Operating | [`.github/workflows/`](../.github/workflows/) |

---

## Compliance and Governance

| Technology / Capability | Depth | Portfolio evidence |
|---|---|---|
| ISO 27001:2022 controls mapping | Designing | [`compliance/iso-27001/`](../compliance/iso-27001/) |
| ASD Essential Eight — all 8 controls | Designing | [`compliance/asd-essential-eight/`](../compliance/asd-essential-eight/) |
| NIST CSF framework mapping | Designing | [`compliance/nist-csf/`](../compliance/nist-csf/) |
| Security incident response (ISO 27001 / NIST 800-61) | Designing | [`incident-response/`](../incident-response/) |
