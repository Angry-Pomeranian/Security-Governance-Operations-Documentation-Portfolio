# Certifications and Learning

Active certifications, completed study materials, and the learning that produced the technical content in this portfolio.

---

## Certifications in Progress

### SC-300 — Microsoft Identity and Access Administrator

Vendor: Microsoft
Status: Active study

Covers: Microsoft Entra ID, identity governance, hybrid identity, Conditional Access, PIM, application access, and identity protection.

The SC-300 lab work in this portfolio was performed in a live Entra ID tenant, not just exam cram. Lab notes document actual configuration steps and outcomes rather than memorised answers.

**Portfolio evidence:**
- [`certification/sc-300-identity-access-administrator-lab-notes.md`](../certification/sc-300-identity-access-administrator-lab-notes.md) — Full lab notes across all SC-300 modules
- [`certification/sc-300-study-guide.md`](../certification/sc-300-study-guide.md) — Condensed study guide for the exam domains
- [`certification/sc-300-exam-resources.md`](../certification/sc-300-exam-resources.md) — Resource links and reference materials
- [`certification/sc-300-lab-execution-order.md`](../certification/sc-300-lab-execution-order.md) — Recommended lab sequence for efficient study

**Practical application in portfolio:**
The SC-300 lab work directly informed the Conditional Access policies, Authentication Methods policies, and PIM/JIT server access guides in [`reference/identity-access/`](../reference/identity-access/).

---

### AWS Cloud Practitioner (CLF-C02)

Vendor: Amazon Web Services
Status: Active study

Covers: AWS core services, cloud concepts, security and compliance, pricing and billing, and the AWS shared responsibility model.

**Portfolio evidence:**
- [`certification/aws-cloud-practitioner-module-1-introduction.md`](../certification/aws-cloud-practitioner-module-1-introduction.md) — Module 1: Introduction to AWS
- [`certification/aws-cloud-practitioner-module-2-compute.md`](../certification/aws-cloud-practitioner-module-2-compute.md) — Module 2: Compute in the cloud

**Practical application in portfolio:**
AWS knowledge applied in the Sentinel telemetry onboarding work — CloudTrail, GuardDuty, VPC Flow Logs, S3/SQS transport pipeline documented in [`reference/sentinel/automate-deployment/`](../reference/sentinel/automate-deployment/).

---

## Study and Reference Materials

### Azure AD B2C — SSO Setup

Hands-on implementation notes from configuring Azure AD B2C with custom user flows and SSO integration.

- [`certification/azure-ad-b2c-sso-setup-notes.md`](../certification/azure-ad-b2c-sso-setup-notes.md)

---

### PIM, JIT, and Passwordless Server Access

Study notes covering the intersection of PIM, Just-in-Time server access, and passwordless authentication — directly applied in the PIM server access Conditional Access policy.

- [`certification/pim-jit-passwordless-server-access.md`](../certification/pim-jit-passwordless-server-access.md)

---

## Next Targets

| Certification | Domain | Notes |
|---|---|---|
| SC-300 | Identity and Access | In progress — exam target: 2025 |
| AWS CLF-C02 | Cloud | In progress — exam target: 2025 |
| AZ-500 (Azure Security Engineer) | Cloud Security | Planned — builds on SC-300 identity foundation |
| SC-200 (Microsoft Security Operations Analyst) | Detection / SIEM | Planned — aligns with Sentinel work in portfolio |

---

## Related

- [`certification/README.md`](../certification/README.md) — Full index of all certification and study materials
- [`reference/identity-access/`](../reference/identity-access/) — Where SC-300 lab knowledge was applied
- [`reference/sentinel/`](../reference/sentinel/) — Where AWS and Azure monitoring knowledge was applied
