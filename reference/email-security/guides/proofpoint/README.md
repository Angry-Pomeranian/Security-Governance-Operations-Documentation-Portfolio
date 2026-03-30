# Proofpoint Guides

## Overview

This folder contains operational guides for Proofpoint platform configuration and administration, focusing on data security, insider threat management (ITM), and data loss prevention (DLP).

These guides complement the Proofpoint TAP (Targeted Attack Protection) API pipeline documented in the parent email security section, covering the data security and user activity monitoring side of the Proofpoint platform.

---

## Guides

| Guide | Description | File |
|---|---|---|
| End User Guide | URL rewriting explanation, quarantine digest usage, safe/blocked sender management, false positive reporting, phishing reporting, and encrypted email | [`end-user-guide.md`](end-user-guide.md) |
| Admin Guide | DMARC/SPF/DKIM configuration, anti-spoofing policy, false positive management, TAP/URL Defense tuning, phishing simulation allowlisting (KnowBe4), M365 integration, TRAP auto-remediation | [`admin-guide.md`](admin-guide.md) |
| MSP Guide | Client onboarding checklist, monthly health check template, TAP threat dashboard interpretation for non-technical clients, multi-tenant management tips | [`msp-guide.md`](msp-guide.md) |
| Data Security Workbench | Configuration reference and activity event schema for Proofpoint ITM/DLP — covering file operations, web uploads, clipboard events, and DLP signal types | [`data-security-workbench/`](data-security-workbench/README.md) |
| AI Governance Suite | 9 guides covering shadow AI discovery (CASB), GenAI site monitoring, sensitive data detection in AI prompts, DLP policy design, Isolation Console controls, alert investigation, risk reporting, adaptive access controls (TAP + Isolation), and OAuth governance for AI apps | [`ai-governance/`](ai-governance/README.md) |

---

## Platform Context

The Proofpoint content in this portfolio spans two distinct product lines:

| Product Line | Coverage | Location |
|---|---|---|
| Proofpoint TAP (email threats) | API pipeline: ingest click/message events into Sentinel via Azure Function; Grafana dashboards | [`../../api/proofpoint/README.md`](../../api/proofpoint/README.md) |
| Proofpoint ICS / ITM / DLP (data security) | Data Security Workbench event schema; activity event categories (file, web, clipboard, print); DLP and ITM signal types | This folder |

Proofpoint's Information and Cloud Security (ICS) platform monitors endpoint and cloud activity for insider threat and data loss scenarios. The Data Security Workbench is the primary investigation interface for ITM analysts.

---

## Related

- [Proofpoint TAP API Pipeline](../../api/proofpoint/README.md) — Ingest TAP click/message threat events into Microsoft Sentinel.
- [Email Security Overview](../../README.md) — Parent section covering email security architecture, connectors, and playbooks.
- [BEC Incident Response Playbook](../../../../../incident-response/business-email-compromise-playbook.md) — Incident response for BEC scenarios, including Proofpoint TAP correlation.
