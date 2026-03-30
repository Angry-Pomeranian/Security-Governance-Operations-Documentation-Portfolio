# Proofpoint AI Governance Guide Suite

## Overview

This suite covers the operational procedures for governing, detecting, and responding to AI tool usage across your organisation using the Proofpoint Information and Cloud Security (ICS) platform. Guides are ordered to reflect a practical build sequence: discover what is happening first, then detect and prevent, then investigate and report, then systematise governance.

**The core problem these guides solve:** Employees are using AI tools — ChatGPT, Claude, Gemini, Copilot, Perplexity, AI coding assistants, AI browser extensions — and some of them are pasting data they should not be pasting. Standard email and endpoint DLP does not see this. These guides cover how to see it, stop the worst of it, investigate when alerts fire, and report on the risk in a way management and clients can act on.

---

## Products Referenced

| Product | Role in AI governance |
|---|---|
| Proofpoint CASB | Discovers which AI apps are in use, audits OAuth tokens, enforces app access policy |
| Data Security Workbench | Primary investigation and reporting interface; GenAI activity explorations; alert triage |
| Browser Extension / Agent | Captures web activity at the endpoint, including GenAI prompt submit events |
| Isolation Console | Applies upload/clipboard/download restrictions on AI sites; routes high-risk users |
| TAP (Targeted Attack Protection) | Provides VAP data and user risk scores used to drive adaptive AI controls |
| DSPM | Discovers and classifies data at rest in cloud environments; maps what Copilot for M365 can reach |

---

## Guides

### Visibility & Discovery

| Guide | Purpose |
|---|---|
| [Shadow AI Discovery Guide (CASB)](visibility/shadow-ai-discovery-casb.md) | Identify which AI tools users are connecting to, find unsanctioned OAuth authorisations, build your AI app landscape |
| [GenAI Site Monitoring Guide (Data Security Workbench)](visibility/genai-site-monitoring-workbench.md) | Query user activity on GenAI sites, identify data submissions, build explorations for high-risk AI behaviour |

### Detection & Prevention

| Guide | Purpose |
|---|---|
| [Detecting Sensitive Data in AI Prompts](detection/detecting-sensitive-data-in-ai-prompts.md) | Enable browser extension, configure GenAI Prompt Submit trigger, build classifiers for PII/credentials/code/IP, choose alert vs block vs redact |
| [Building GenAI DLP Rules and Policies](detection/building-genai-dlp-rules-and-policies.md) | Surgical policy design: allow tools but block data submission, differentiate by group, tune to reduce false positives |
| [Controlling AI Site Access via Isolation Console](detection/controlling-ai-site-access-via-isolation.md) | Apply upload/clipboard restrictions on AI sites, route high-risk users into isolation, tiered access model |

### Investigation & Reporting

| Guide | Purpose |
|---|---|
| [Investigating a GenAI Data Loss Alert](investigation/investigating-genai-data-loss-alert.md) | Work an alert from first notification to verdict; correlate DLP + CASB + Isolation events; escalate vs close criteria |
| [GenAI Risk Reporting for Management and Clients](investigation/genai-risk-reporting.md) | Build and present top-user metrics, data category risk, shadow AI app count, trends — client-ready output |

### Governance

| Guide | Purpose |
|---|---|
| [Adaptive AI Access Controls (TAP + Isolation)](governance/adaptive-ai-access-controls.md) | Use VAP data and user risk to dynamically tighten AI site controls; step-up isolation after DLP alerts |
| [CASB OAuth Governance for AI Apps](governance/casb-oauth-governance-for-ai-apps.md) | Audit and revoke OAuth tokens granted to AI tools, block high-risk OAuth authorisations, maintain approved app list |

### Reference

| Guide | Purpose |
|---|---|
| [DSPM Positioning Note](dspm-note.md) | Where DSPM is the right tool vs the guides above; data at rest discovery, Copilot for M365 exposure mapping, Data Risk Map |

---

## Implementation Sequence

For a new AI governance program, follow this order:

```
Week 1-2: Visibility
  → Shadow AI Discovery (CASB) — know what you're dealing with
  → GenAI Site Monitoring (Workbench) — baseline activity data

Week 3-4: Detection setup
  → Detecting Sensitive Data in AI Prompts — core detection capability
  → Building GenAI DLP Rules — tune policies before enforcing
  → Isolation Console setup — tiered access for high-risk scenarios

Week 5-6: Investigation and governance
  → Alert investigation workflow — prepare analysts
  → Adaptive Access Controls — link TAP risk to Isolation policy
  → OAuth Governance — remediate unsanctioned app access

Ongoing:
  → Risk reporting to management (monthly)
  → DSPM — data at rest discovery (parallel workstream)
```

---

## Related

- [Data Security Workbench](../data-security-workbench/README.md) — Core ITM/DLP investigation platform.
- [Admin Guide](../admin-guide.md) — Proofpoint email platform administration.
- [Proofpoint TAP API Pipeline](../../../api/proofpoint/README.md) — TAP event ingestion into Sentinel.
