# Shadow AI Discovery Guide — Proofpoint CASB

## Overview

Before writing a single DLP rule, you need to know which AI tools your organisation is actually using. Shadow AI — AI tools employees have adopted without IT's knowledge or approval — is the starting point of any AI governance program.

Proofpoint CASB (Cloud App Security Broker) gives you the app discovery capability: it analyses web traffic to build a picture of which cloud apps are in use, categorises them by risk, and surfaces OAuth authorisations that give AI tools ongoing access to corporate data. This guide covers how to use CASB to build that picture.

**What CASB can see:**
- Web traffic to cloud app domains (from browser extension and network proxy/log ingestion)
- User-to-app mapping (who is using which AI tools, how frequently)
- OAuth authorisations: when users have granted an AI app permission to access Google Workspace, Microsoft 365, or other cloud storage
- App risk scoring based on Proofpoint's cloud app catalogue

**What this guide does not cover:** Detection of data submitted within AI prompts — that is covered in [Detecting Sensitive Data in AI Prompts](../detection/detecting-sensitive-data-in-ai-prompts.md). CASB sees the apps; the Workbench sees the content.

---

## Step 1 — Access the CASB App Discovery View

1. Log in to the Proofpoint Information and Cloud Security (ICS) portal
2. Navigate to **CASB → App Discovery** (or **Cloud Apps → Discovered Apps** depending on your platform version)
3. Set the time range to **Last 30 days** for an initial baseline

The App Discovery view lists all cloud applications detected in your environment, with:
- Application name and category
- Number of users
- Usage volume (bytes / events)
- Risk score (1–10, Proofpoint's assessment based on security controls, compliance certifications, data residency)
- Sanction status (Sanctioned / Unsanctioned / Blocked)

---

## Step 2 — Filter for AI and GenAI Applications

CASB categorises applications into categories. Filter for AI-related categories:

1. In App Discovery, click **Filters**
2. Filter by **Category**:
   - `Artificial Intelligence` (or `GenAI` / `AI Tools` — category name varies by platform version)
   - `AI Assistants`
   - `AI Code Assistants`
3. Also review: `Collaboration Tools` — AI-augmented tools like Notion AI, Slack AI, Zoom AI Companion may appear here

**If AI-specific categories are not available in your CASB version:**
Search by app name for known AI tools:
```
ChatGPT, Claude, Gemini, Copilot, Perplexity, Midjourney, Stable Diffusion, Runway,
GitHub Copilot, Tabnine, Codeium, Cursor, Replit, v0.dev,
Notion AI, Otter.ai, Jasper, Copy.ai, Writesonic,
Character.ai, Poe, Hugging Face
```

---

## Step 3 — Assess Each AI App

For each AI application discovered, review:

| Field | What to assess |
|---|---|
| User count | How widely adopted is this tool? |
| Risk score | Proofpoint's risk rating — check score breakdown for specific risk factors |
| Data residency | Where does the vendor process data? |
| Compliance certifications | SOC 2, ISO 27001, GDPR compliance? |
| Data retention policy | Does the vendor train on submitted data by default? |
| OAuth permissions | Has this app been granted access to corporate cloud storage? |

**Risk score breakdown:**
Click on any app → **App Details** → the risk score breaks down across categories:
- Data security (encryption at rest/transit, DLP controls)
- Identity and access (MFA support, SSO, admin controls)
- Legal and compliance (GDPR compliance, data residency disclosure)
- Reputation (breach history, security disclosures)

### AI-Specific Risk Factors to Check

Beyond the standard CASB risk score, evaluate AI tools for:

| Risk factor | Why it matters | Where to find it |
|---|---|---|
| Training data opt-out | Does submitted data train the model by default? | Vendor privacy policy / App Details in CASB |
| Data retention period | How long does the vendor retain prompts and outputs? | Vendor privacy policy |
| Enterprise tier required for data protection | Free/consumer tier may have weaker protections | App Details / vendor pricing |
| Browser extensions available | AI browser extensions may have broader data access | App Details → Known Extensions |

---

## Step 4 — Build Your AI App Landscape

Create a working register of discovered AI apps. Use the CASB export:

1. **App Discovery → Export** (CSV)
2. Filter to AI-related categories only
3. The export includes: app name, category, user count, risk score, sanction status, OAuth status

Classify each app into one of four tiers for policy purposes:

| Tier | Definition | Examples |
|---|---|---|
| **Approved** | Org-sanctioned, enterprise agreements in place, data protection terms signed | Microsoft Copilot for M365, GitHub Copilot (enterprise), approved vendor-specific AI |
| **Tolerated** | No formal approval but acceptable risk — monitor, no blocking | Perplexity (research), Claude.ai (general use, no IP submitted) |
| **Review needed** | High risk score, unclear data handling, significant user adoption | New tools with no compliance certs, consumer-tier only |
| **Block** | Unacceptable risk or explicitly prohibited | Tools with known data sharing to third parties, consumer-grade apps with no enterprise controls |

Mark each app's sanction status in CASB to match your tiers:
- Approved → **Sanctioned**
- Tolerated → **Unsanctioned** (monitored)
- Block → **Blocked** (enforced)

---

## Step 5 — Find Unsanctioned OAuth Authorisations

This is the highest-risk CASB finding for AI tools. An AI browser extension or app that a user has OAuth-authorised can access corporate cloud storage (Google Drive, OneDrive, SharePoint) continuously, reading files without any user action after initial authorisation.

### Finding OAuth Authorisations

1. **CASB → OAuth** (or **Cloud Apps → OAuth Authorisations**)
2. Filter by: App Category = AI
3. Review each OAuth authorisation:

| Column | What to check |
|---|---|
| Application | The AI tool that was authorised |
| Authorised by | The user who granted access |
| Permissions granted | What the AI app can do: read files, edit files, read email, etc. |
| Authorisation date | When this was granted |
| Last used | When the app last used these permissions |

### High-Risk OAuth Permission Patterns

Flag any AI app OAuth authorisation that includes:
- `Files.ReadWrite` / `Drive: Read and write` — AI can read and write all files
- `Mail.Read` / `Gmail.readonly` — AI can read all email
- `Contacts.Read` — AI can access contact lists
- `Sites.ReadWrite.All` — AI can access all SharePoint sites (M365)

These are disproportionate permissions for tools that should only need access to content the user explicitly shares.

### Revoking OAuth Tokens

For high-risk AI app OAuth authorisations:
1. Select the authorisation
2. **Actions → Revoke OAuth Token**
3. CASB will revoke the token; the AI app will lose access to the user's cloud storage
4. Notify the user via your IT ticketing system: explain why the token was revoked and what they should do instead (e.g. use the web UI without OAuth, or request the enterprise-tier app with appropriate data handling terms)

For ongoing OAuth governance, see [CASB OAuth Governance for AI Apps](../governance/casb-oauth-governance-for-ai-apps.md).

---

## Step 6 — Identify Top AI Users

1. **CASB → App Discovery → [AI App] → Users**
2. Sort by: usage volume or event count
3. Identify the top 10–20 users by AI tool usage

Cross-reference these users against:
- HR records: do they handle sensitive data in their role (finance, legal, HR, engineering)?
- TAP VAP list: are any of them already Very Attacked People?
- Existing DLP incidents: have any of them triggered DLP alerts in the last 90 days?

Users who are high AI tool users **and** have access to sensitive data are your highest-priority monitoring targets for the detection phase.

---

## Step 7 — Set Ongoing App Discovery Alerting

Configure CASB to alert you when new AI apps are discovered:

1. **CASB → Policies → New Policy** (or **App Discovery → Alerts**)
2. Configure:
   | Field | Value |
   |---|---|
   | Policy type | App Discovery |
   | Trigger | New application detected in category: AI |
   | Minimum user count | 3 (avoids single-user false positives) |
   | Action | Alert (notify security team) |
3. Alert delivery: email or SIEM/webhook

This means you learn about a new AI tool entering the environment within days of first use — before it becomes widespread.

---

## Output of This Guide

After completing this guide, you should have:

- [ ] A list of all AI apps in use (exported from CASB)
- [ ] Each app classified into Approved / Tolerated / Review / Block tiers
- [ ] All AI apps marked with correct sanction status in CASB
- [ ] A list of all AI OAuth authorisations, with high-risk ones revoked
- [ ] A list of top AI users cross-referenced against sensitive data access
- [ ] An ongoing discovery alert for new AI apps

This output feeds directly into the policy design guides:
- [Detecting Sensitive Data in AI Prompts](../detection/detecting-sensitive-data-in-ai-prompts.md)
- [Building GenAI DLP Rules and Policies](../detection/building-genai-dlp-rules-and-policies.md)

---

## DSPM Note

CASB discovers AI app usage at the network/OAuth layer. It does not tell you what corporate data is already exposed in cloud storage that AI tools (especially Microsoft Copilot for M365) can reach.

For assessing **data at rest exposure** — which files in SharePoint, OneDrive, and Exchange are accessible to Copilot, overshared, or contain sensitive data that Copilot could surface — see the [DSPM Positioning Note](../dspm-note.md).

---

## Related

- [GenAI Site Monitoring Guide](genai-site-monitoring-workbench.md) — Behavioural visibility once apps are identified.
- [CASB OAuth Governance for AI Apps](../governance/casb-oauth-governance-for-ai-apps.md) — Ongoing OAuth token management.
- [Building GenAI DLP Rules and Policies](../detection/building-genai-dlp-rules-and-policies.md) — Converting the app tier list into DLP policy.
