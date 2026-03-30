# DSPM Positioning Note — Proofpoint AI Governance Suite

## What This Note Covers

Each guide in this AI governance suite includes a "DSPM Note" callout identifying scenarios where the guide's tools (CASB, Workbench, Isolation) are not the right answer — and where Proofpoint DSPM (Data Security Posture Management) is. This document explains what DSPM covers, where it fits in the overall AI governance architecture, and what to document in DSPM-specific guides.

---

## The Gap the Other Guides Do Not Cover

The visibility, detection, and governance guides in this suite address one attack surface: **data flowing from users to AI tools**. They detect when a user copies a salary file and pastes it into ChatGPT. They restrict clipboard paste on AI sites. They revoke OAuth tokens.

What they do not cover:

**Microsoft Copilot for M365 reading your SharePoint without a user action.**

Copilot for M365 is not a third-party AI tool that users connect to. It is a Microsoft product built into the M365 tenant. When a user asks Copilot "What is our Q4 revenue forecast?", Copilot searches across all SharePoint, OneDrive, Exchange, and Teams content that the user has permission to access — and synthesises an answer. No DLP trigger fires. No clipboard paste occurs. No OAuth grant is needed.

If your SharePoint contains an overshared budget spreadsheet, a confidential HR report, or an M&A term sheet that 500 people have read access to (because it was shared to "Everyone in the organisation" years ago), Copilot will find it and surface it in response to a natural language question from any of those 500 users.

**This is the data-at-rest problem, and it requires DSPM.**

---

## What Proofpoint DSPM Does

Proofpoint DSPM (previously known as Proofpoint Information Protection) discovers and classifies sensitive data at rest in cloud and hybrid environments. For AI governance, the key capabilities are:

### 1. Data Discovery and Classification

DSPM scans cloud storage (SharePoint, OneDrive, Exchange, Google Workspace, Box, and others) and classifies files by content:
- PII (names, identifiers, health information)
- Financial data (account numbers, payment card data)
- Credentials (API keys in files, password documents)
- Intellectual property (contracts, patents, source code repositories)
- Regulated data (GDPR-relevant content, HIPAA PHI, PCI DSS data)

This gives you a map of where sensitive data lives in your cloud environment.

### 2. Copilot for M365 Exposure Mapping

DSPM's Copilot-specific capability identifies which sensitive files are accessible to Copilot — meaning files where the user asking Copilot has read permission. It highlights:
- Files with sensitive content that are broadly accessible (shared to "Everyone", "All Staff", or large groups)
- Files that a specific user can access via Copilot that they should not be able to see in a normal workflow
- Files labelled Confidential or Highly Confidential that are accessible beyond the intended audience

**The Data Risk Map:** DSPM produces a visualisation (the Data Risk Map) showing concentrations of sensitive data by location, classification type, and access exposure level. This is the primary output for Copilot-readiness assessments.

### 3. Remediation Guidance

DSPM does not just identify exposure — it guides remediation:
- Files that are overshared: recommended action is to restrict sharing permissions
- Files with no sensitivity label applied: recommended action is to apply the appropriate label
- Files in locations where they should not be (e.g. confidential HR files in a general department SharePoint site): recommended relocation or access restriction

---

## Where to Flag DSPM in Each Guide

The following situations, mentioned in other guides in this suite, are where DSPM is the right tool rather than (or in addition to) Workbench/CASB/Isolation:

| Scenario | Guide that flags it | DSPM relevance |
|---|---|---|
| Copilot for M365 surfacing SharePoint data | Shadow AI Discovery, Isolation, Adaptive Controls, Reporting | DSPM maps which SharePoint files Copilot can reach and their sensitivity |
| OAuth-connected AI tool reading OneDrive | CASB OAuth Governance | DSPM classifies the sensitivity of files in OneDrive before the OAuth risk is assessed |
| "What data is at rest that AI can access?" | All guides | DSPM Data Risk Map |
| Data submitted to AI came from a SharePoint file | Investigating a GenAI Alert | DSPM can confirm the classification and sharing state of the source file |
| Reporting data category exposure to management | GenAI Risk Reporting | DSPM adds the "at rest" dimension to the endpoint-focused Workbench data |

---

## DSPM Guides to Build Separately

These guides should be documented as a separate DSPM sub-suite, parallel to this AI governance suite:

| Guide | What it covers |
|---|---|
| **Data Discovery and Classification — Cloud Environments** | Running DSPM scans on SharePoint, OneDrive, Exchange, Google Workspace; reviewing results; understanding classification confidence scores |
| **Data Risk Map — Reading and Acting on Results** | How to interpret the Data Risk Map, filter by sensitivity level and exposure, export findings, prioritise remediation |
| **Copilot for M365 Readiness Assessment** | Using DSPM to map what Copilot can access, identifying high-risk overexposed files, generating a pre-Copilot deployment remediation plan |
| **Remediating Overexposed Sensitive Data** | Acting on DSPM findings: restricting SharePoint sharing, applying sensitivity labels, moving misplaced files, setting up ongoing DSPM monitoring |
| **DSPM + Workbench Correlation** | How to use DSPM's data classification findings alongside Workbench activity data — when a user submits data to an AI tool, correlate the content classification from DSPM to understand the asset's full exposure context |

---

## Where DSPM Sits in the AI Governance Architecture

```
User submits data to AI tool (browser/app)
    ↓
Endpoint agent captures event
    ↓
DLP classifier matches (Workbench)         ← Workbench/detection guides cover this
    ↓
Alert → Investigation → Response           ← Investigation guides cover this

        ↕ (parallel, not sequential)

Data exists at rest in SharePoint/OneDrive
    ↓
Copilot for M365 reads it on user request
    ↓
DSPM maps exposure and classification      ← DSPM guides cover this
    ↓
Remediation: restrict sharing, apply labels
```

The two tracks are complementary. The Workbench/CASB track secures the **flow** of data to AI tools. DSPM secures the **state** of data that AI tools can access at rest.

A complete AI governance program needs both.

---

## Immediate DSPM Actions for AI Governance

If DSPM is available in your tenant and you are standing up an AI governance program, these are the priority actions:

1. **Run a Copilot-readiness scan** — identify overshared sensitive files before enabling Copilot for M365 for any users
2. **Generate a Data Risk Map** — understand the concentration and distribution of sensitive data in cloud storage
3. **Remediate the top 20 overexposed files** — the Data Risk Map will show you the highest-exposure items; fix the most sensitive ones first
4. **Apply sensitivity labels** to unlabelled sensitive files so downstream controls (Conditional Access, DLP, Copilot content restrictions) can act on classification

**If Copilot for M365 is already deployed:** Run the Copilot readiness scan immediately to understand current exposure. The remediation is the same — but the urgency is higher if Copilot is already active.

---

## Related

- [Shadow AI Discovery Guide (CASB)](visibility/shadow-ai-discovery-casb.md)
- [GenAI Site Monitoring Guide (Workbench)](visibility/genai-site-monitoring-workbench.md)
- [Detecting Sensitive Data in AI Prompts](detection/detecting-sensitive-data-in-ai-prompts.md)
- [Building GenAI DLP Rules and Policies](detection/building-genai-dlp-rules-and-policies.md)
- [Controlling AI Site Access via Isolation Console](detection/controlling-ai-site-access-via-isolation.md)
- [Investigating a GenAI Data Loss Alert](investigation/investigating-genai-data-loss-alert.md)
- [GenAI Risk Reporting for Management and Clients](investigation/genai-risk-reporting.md)
- [Adaptive AI Access Controls](governance/adaptive-ai-access-controls.md)
- [CASB OAuth Governance for AI Apps](governance/casb-oauth-governance-for-ai-apps.md)
