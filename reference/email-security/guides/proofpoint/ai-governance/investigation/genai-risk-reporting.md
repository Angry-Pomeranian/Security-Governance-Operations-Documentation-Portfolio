# GenAI Risk Reporting for Management and Clients

## Overview

This guide covers how to build and present GenAI risk reporting from Proofpoint ICS data. The goal is to produce reporting that translates Workbench, CASB, and Isolation data into metrics management and clients can understand and act on — not just "here are the alert counts."

Good GenAI risk reporting answers three questions:
1. What is the scope of AI tool usage in the organisation?
2. What data is at risk based on what users are doing?
3. Is the risk increasing, decreasing, or flat?

---

## The Core Report — Monthly GenAI Risk Summary

This is the reporting format for a monthly management review or client report. Sections are ordered from high-level (for non-technical stakeholders) to detailed (for security and IT teams).

---

### Section 1 — Executive Summary

One paragraph, three numbers, one headline finding:

> "In [Month], Proofpoint detected [X] users accessing GenAI tools across [Y] distinct applications. [Z] data submission events were logged, of which [N] triggered DLP alerts. The most significant finding was [headline: e.g., 'credential material detected in 3 AI prompt submissions' / 'a finance team member submitted 14 months of payroll data to an unsanctioned AI tool' / 'shadow AI app adoption increased 40% month-over-month']. [One sentence on what was done about it.]"

Keep this to four sentences maximum. Executives do not read longer summaries.

---

### Section 2 — AI App Landscape (from CASB)

**Source:** CASB → App Discovery → AI category → export

| Metric | This month | Last month | Trend |
|---|---|---|---|
| Total AI apps in use | | | ↑ / ↓ / → |
| Sanctioned (approved) apps | | | |
| Tolerated (unsanctioned, monitored) apps | | | |
| Review (high risk) apps | | | |
| Blocked apps | | | |
| New AI apps discovered this month | | | |
| OAuth authorisations to AI apps (active) | | | |
| OAuth revocations this month | | | |

**Chart:** Stacked bar chart showing the app tier distribution over the last 6 months. Increasing shadow AI count is a lead indicator of future risk.

**New apps this month:** List any new AI apps that appeared in the environment this month (from the CASB discovery alert). Include app name, user count, risk score, and whether it has been classified.

---

### Section 3 — User Activity on AI Sites (from Workbench)

**Source:** Workbench → Explorations → GenAI Site Browsing Activity + GenAI Data Submission Activity

| Metric | This month | Last month | Trend |
|---|---|---|---|
| Users browsing AI sites | | | |
| Users submitting data to AI sites | | | |
| Total data submission events | | | |
| Average submissions per active user | | | |
| Large content submissions (>5KB) | | | |

**Top users by submission volume:**

| Rank | User | Department | Submission count | AI tools used | Risk level |
|---|---|---|---|---|---|
| 1 | | | | | |
| 2 | | | | | |
| ... | | | | | |

**Note on this table:** In client-facing reports, anonymise user names unless the client has explicitly requested named user data and this is covered by your engagement terms and privacy obligations.

---

### Section 4 — DLP Alerts (from Workbench Alert Queue)

**Source:** Workbench → Alerts → filter by GenAI rules → export

| Metric | This month | Last month | Trend |
|---|---|---|---|
| Total GenAI DLP alerts | | | |
| Critical severity | | | |
| High severity | | | |
| Medium severity | | | |
| Low/informational | | | |
| Confirmed violations | | | |
| False positives | | | |
| False positive rate | | | |
| Alerts escalated to incident | | | |

**Alerts by rule/classifier:**

| Rule | Alert count | Confirmed | FP | Action taken |
|---|---|---|---|---|
| Credentials Detected | | | | |
| PII — Sensitive Roles | | | | |
| PII — General | | | | |
| Source Code — Non-Dev | | | | |
| Confidential IP | | | | |
| Large Content | | | | |

**Notable incidents this month:** A brief description of any confirmed violations or escalated incidents. Keep descriptions factual and limited to the security finding, not HR outcomes.

---

### Section 5 — Data Categories at Risk

This section answers "what kind of data is being submitted to AI tools?" — the question that resonates most with legal, compliance, and privacy teams.

**Source:** Workbench alert data + classifier match breakdown

| Data category | Submission events detected | Confirmed exposure | AI tools involved |
|---|---|---|---|
| PII (names, identifiers) | | | |
| Financial data | | | |
| Health information | | | |
| Credentials / API keys | | | |
| Source code | | | |
| Confidential documents (fingerprint match) | | | |
| Large unclassified content | | | |

**Chart:** Pie chart or bar chart showing proportion of data category hits. This visualises risk concentration.

---

### Section 6 — Isolation Activity (from Isolation Console)

**Source:** Isolation Console → Reporting → Session Activity

| Metric | This month | Last month |
|---|---|---|
| Users routed through Isolation to AI sites | | |
| Upload attempts blocked by Isolation | | |
| Clipboard paste attempts blocked by Isolation | | |
| High-risk users in Tier 3 read-only | | |
| TAP VAP users with step-up isolation | | |

**Isolation effectiveness:** Blocked upload + blocked paste events are Isolation stopping potential data loss events before they reach the DLP layer. Report this as "events prevented."

---

### Section 7 — Trend Analysis (Rolling 3-Month View)

Three months of data is the minimum for meaningful trend analysis. Present as line charts:

1. **AI app count by tier** (month-over-month): Is shadow AI growing?
2. **Data submission volume** (month-over-month): Are users submitting more data to AI tools?
3. **DLP alert volume by severity** (month-over-month): Is detection finding more, or is the program under-detecting?
4. **Confirmed violations vs false positives** (month-over-month): Is rule tuning improving precision?

---

### Section 8 — Recommendations

End the report with 3–5 concrete, prioritised recommendations based on this month's data. Examples:

> 1. **Move [App X] from Tolerated to Review tier.** Usage has grown to 45 users this month and the vendor has not responded to our data handling questionnaire. Recommend applying Isolation upload restrictions while assessment is completed.
>
> 2. **Enable Block action on the Large Content Submission rule.** The false positive rate is now 4% (down from 18% in Month 1) and the rule is generating high-confidence true positives. Recommend escalating from Alert to Block with a user-facing message.
>
> 3. **Revoke 7 outstanding OAuth tokens granted to [AI App Y].** Identified in CASB audit this month. These tokens grant read access to user OneDrive. No business justification has been established.
>
> 4. **Enrol 3 repeat DLP users in targeted AI security awareness training.** Two users have triggered GenAI DLP alerts in consecutive months.

---

## Building the Report — Data Export Workflow

Run this workflow monthly to collect the data for the report template above.

### 1. CASB Data

```
CASB → App Discovery → filter: AI category → Export CSV
CASB → OAuth → filter: AI apps → Export CSV
```
Open exports in Excel/Sheets. Summarise totals and identify new apps since last month.

### 2. Workbench Data Submissions

```
Workbench → Explorations → GenAI Site Browsing Activity → Run for last 30 days → Export
Workbench → Explorations → GenAI Data Submission Activity → Run for last 30 days → Export
```
These should be the saved explorations from the [GenAI Site Monitoring Guide](../visibility/genai-site-monitoring-workbench.md).

### 3. Workbench Alert Data

```
Workbench → Alerts → filter: Rule category = GenAI, date range = last 30 days → Export
```
Review verdict column: sort by Confirmed vs FP vs Open.

### 4. Isolation Data

```
Isolation Console → Reporting → Session Activity → filter: AI sites, last 30 days → Export
```

### 5. Compile

Populate the report template. Calculate trend figures against the previous month's export.

**Time to compile (once the data pulls are automated):** 30–60 minutes per client.

---

## Client-Facing Report Adjustments

When presenting to clients rather than internal management:

| Adjustment | Reason |
|---|---|
| Anonymise or aggregate user names | Privacy; clients may not have authorised named user reporting in your engagement terms |
| Focus on risk metrics, not technical metrics | "3 credential exposures this month" lands harder than "Credentials classifier triggered 3 times" |
| Include a "what we did about it" column | Clients want to see that alerts lead to action, not just logging |
| Add a competitor/industry benchmark note if available | "Your shadow AI app count is [X]; industry average for orgs your size is [Y]" contextualises the finding |
| Include a programme health indicator | Green / Amber / Red rating based on: detection coverage, false positive rate, outstanding remediation items |

---

## DSPM Note

This report covers data flowing **to** AI tools from endpoints and browsers. It does not report on:
- What sensitive data is at rest in cloud storage that AI tools can access without user action (Copilot for M365)
- Overexposed files that are accessible to broader audiences than intended

A complete AI risk report should include a DSPM component covering cloud data exposure. See the [DSPM Positioning Note](../dspm-note.md) for what to include and how to present it alongside this Workbench/CASB data.

---

## Related

- [GenAI Site Monitoring Guide](../visibility/genai-site-monitoring-workbench.md) — Workbench explorations that generate the source data for Section 3.
- [Shadow AI Discovery Guide (CASB)](../visibility/shadow-ai-discovery-casb.md) — CASB app discovery that generates Section 2 data.
- [Investigating a GenAI Data Loss Alert](investigating-genai-data-loss-alert.md) — The investigation process behind the Section 4 alert data.
