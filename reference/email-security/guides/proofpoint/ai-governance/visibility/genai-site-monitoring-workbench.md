# GenAI Site Monitoring Guide — Data Security Workbench

## Overview

Once you know which AI tools are in use (from CASB discovery), the next step is understanding what users are actually doing on those sites: how often they are visiting, what data they are submitting, and which users represent the highest risk. The Data Security Workbench gives you this visibility through web activity events captured by the Proofpoint browser extension and endpoint agent.

This guide covers how to build and use Workbench explorations to monitor GenAI site activity, identify high-risk behaviour patterns, and produce the baseline that your detection rules will eventually be tuned against.

**Prerequisite:** The Proofpoint browser extension or endpoint agent must be deployed to the devices you want to monitor. Without an agent, the Workbench has no visibility into web content (only network-level data, which CASB covers). See your Proofpoint ICS deployment documentation for agent rollout.

---

## What the Agent Captures on GenAI Sites

When a user visits a GenAI site with the Proofpoint endpoint agent active, the agent captures:

| Event type | What it records |
|---|---|
| `web_browse` | URL visited, timestamp, user, device |
| `web_upload` | Content uploaded via form submission or file drag-and-drop |
| `clipboard_paste` | Content pasted into a web form (including AI prompt boxes) |
| `genai_prompt_submit` | Content of a prompt submitted to a GenAI service (when the GenAI trigger is enabled — see [Detecting Sensitive Data in AI Prompts](../detection/detecting-sensitive-data-in-ai-prompts.md)) |
| `file_download` | Files downloaded from the AI service |

The `clipboard_paste` and `genai_prompt_submit` events are the most relevant for AI governance — they capture what the user actually sent to the AI tool.

---

## Step 1 — Build a GenAI Site Browsing Exploration

Start with broad browsing visibility — who is visiting AI sites.

1. **Data Security Workbench → Explorations → New Exploration**
2. Configure:
   | Field | Value |
   |---|---|
   | Name | `GenAI - Site Browsing Activity` |
   | Event types | `web_browse` |
   | Time range | Last 30 days |
3. Add filter:
   | Filter field | Operator | Value |
   |---|---|---|
   | URL / Site Category | contains any | `openai.com`, `chat.openai.com`, `claude.ai`, `gemini.google.com`, `perplexity.ai`, `copilot.microsoft.com`, `bard.google.com`, `huggingface.co`, `poe.com`, `character.ai` |

   **Better approach if website categorisation is configured:**
   - Use **Site Category = Artificial Intelligence** rather than explicit domain lists — this picks up new AI tools automatically without updating the exploration filter
   - See the Data Security Workbench [Website Categorisation](../../data-security-workbench/website-categorization/README.md) documentation for category setup

4. **Group by:** User
5. **Sort by:** Event count (descending)
6. Save the exploration

**Output:** A ranked list of users by volume of GenAI site browsing over the past 30 days.

---

## Step 2 — Build a GenAI Data Submission Exploration

Browsing volume is less important than data submission volume — a user who visits ChatGPT once and pastes a contract is more concerning than someone who visits it 50 times for general queries.

1. **Explorations → New Exploration**
2. Configure:
   | Field | Value |
   |---|---|
   | Name | `GenAI - Data Submission Activity` |
   | Event types | `web_upload`, `clipboard_paste` (select both) |
   | Time range | Last 30 days |
3. Add filter: URL / Site Category contains AI site domains (same as Step 1)
4. **Group by:** User
5. Add secondary grouping: Event type (to split web_upload vs clipboard_paste)
6. Save

**Output:** Users ranked by volume of content submitted to AI sites. Users at the top of this list are the ones submitting data — not just browsing.

---

## Step 3 — Identify Specific Content Being Submitted

Drill into specific high-volume users to understand what they are submitting.

1. From the Step 2 exploration results, click a specific user → **Drill down to events**
2. Expand individual clipboard_paste or web_upload events:
   - The event detail shows the captured content (or a snippet if content capture is enabled)
   - URL confirms which AI service received the submission
   - Timestamp and device show context
3. Look for patterns:
   - Is the user pasting code snippets? (developer using AI coding assistant)
   - Is the user pasting document text? (possible IP submission)
   - Is the user pasting structured data? (possible PII/credentials)
   - Is the content very short (general questions) or very long (pasting entire documents)?

**Content capture and privacy:** Whether the Workbench captures the actual content of clipboard pastes depends on your organisation's agent configuration and local privacy laws. In some configurations, only metadata (content length, classification signals) is captured rather than full content. Confirm your configuration with your Proofpoint deployment settings.

---

## Step 4 — Build a High-Risk Behaviour Pattern Exploration

Certain behaviour patterns are higher risk than general AI browsing. Build explorations targeting these specifically.

### Pattern A — Large Document Submissions

Large content volumes to AI sites suggest users are uploading documents or pasting extensive text:

1. **New Exploration**
2. Event types: `web_upload`, `clipboard_paste`
3. Filter: URL in AI site category AND content size > [threshold — e.g. 5,000 characters]
4. Group by: User
5. Name: `GenAI - Large Content Submissions`

### Pattern B — File Downloads from AI Sites

Users downloading outputs from AI sites (generated documents, code, images) may be bringing AI-generated content into corporate workflows:

1. **New Exploration**
2. Event type: `file_download`
3. Filter: URL in AI site category
4. Group by: User, file type
5. Name: `GenAI - Downloads from AI Sites`

### Pattern C — After-Hours AI Usage

Unusual after-hours activity on AI sites may indicate bulk data extraction:

1. **New Exploration**
2. Event types: `clipboard_paste`, `web_upload`
3. Filter: AI site category AND time-of-day outside business hours (if Workbench supports time filters — otherwise post-process the export)
4. Group by: User, hour of day
5. Name: `GenAI - After-Hours AI Activity`

### Pattern D — AI Usage by High-Risk Role Users

Cross-filter AI activity against users in sensitive roles (finance, legal, HR, executives):

1. **New Exploration**
2. Event types: all
3. Filter: AI site category AND user group = [create an HR/Finance/Legal user group in Workbench]
4. Group by: User
5. Name: `GenAI - Activity by Sensitive Role Users`

---

## Step 5 — Set a Monitoring Baseline

Run the explorations from Steps 1–4 for the past 30 days and record:

| Metric | Value | Notes |
|---|---|---|
| Total users browsing AI sites | | Baseline count |
| Total users submitting data to AI sites | | Subset of above |
| Average submissions per user per week | | Used for anomaly detection |
| Top 10 users by submission volume | | Priority monitoring targets |
| Most-used AI tools by submission volume | | Informs which apps to prioritise in policy |
| Large content submissions (>5KB) per week | | High-risk baseline |

Document this baseline. When you configure detection rules (next phase), you will use this to set appropriate thresholds that catch genuine risk without generating excessive false positives.

---

## Step 6 — Schedule Recurring Explorations

Configure the key explorations to run automatically:

1. **Exploration → Schedule**
2. Frequency: weekly
3. Delivery: email to security team (or SIEM webhook if configured)
4. Include: Top 20 users by data submission volume, any new users appearing in the high-risk list

This gives you a weekly visibility pulse without requiring manual investigation unless something anomalous appears.

---

## DSPM Note

The Workbench shows **what users are submitting to AI tools**. It does not show **what data AI tools can access at rest** in your cloud storage. Microsoft Copilot for M365, in particular, has access to everything in SharePoint, OneDrive, and Exchange that the user can access — without any submission action.

For mapping what data Copilot can reach and finding overexposed sensitive files before AI can surface them, see the [DSPM Positioning Note](../dspm-note.md).

---

## Related

- [Shadow AI Discovery Guide (CASB)](shadow-ai-discovery-casb.md) — Identifying which AI tools are in use before configuring monitoring.
- [Detecting Sensitive Data in AI Prompts](../detection/detecting-sensitive-data-in-ai-prompts.md) — Converting Workbench activity into detection rules.
- [Investigating a GenAI Data Loss Alert](../investigation/investigating-genai-data-loss-alert.md) — Using Workbench explorations during active alert investigation.
- [Data Security Workbench — Explorations](../../data-security-workbench/explorations/README.md) — General exploration creation reference.
