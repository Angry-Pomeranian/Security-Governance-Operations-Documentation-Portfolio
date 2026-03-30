# Investigating a GenAI Data Loss Alert

## Overview

This guide covers how to work a GenAI DLP alert from initial notification through to a final verdict. It describes how to read the user activity timeline in the Data Security Workbench, correlate events across DLP, CASB, and Isolation, and determine whether the event warrants escalation or closure.

The investigation process for a GenAI alert differs from a standard email DLP or file transfer alert in one important way: the data has potentially left the organisation to a third-party AI vendor's infrastructure, not just moved to an external email recipient or USB drive. The remediation options are more limited after the fact, which makes rapid triage and accurate verdict important.

---

## Alert Triage — First 15 Minutes

### Step 1 — Read the Alert Summary

When an alert arrives (email notification, SIEM ticket, or Workbench alert queue), the summary should include:

| Field | What to look for |
|---|---|
| Rule name | Which classifier fired — credentials? PII? IP? Large content? |
| Severity | Critical / High / Medium / Low |
| User | Who triggered the alert |
| Device | Which device |
| AI tool | Which AI service (URL) |
| Timestamp | When the event occurred |
| Content snippet | If content capture is enabled: a preview of the matched content |
| Classifier match | What matched (e.g. "3 PII indicators", "API key pattern", "document fingerprint: contract-template") |

**Immediate triage decision (< 5 minutes):**

| Rule fired | Preliminary verdict | Initial action |
|---|---|---|
| Credentials detected | Treat as critical — potential credential exposure | Open immediate investigation, notify security lead |
| PII (health/financial) | High priority — potential privacy incident | Begin investigation within 1 hour |
| PII (general/low volume) | Medium priority | Investigate within 4 hours |
| Confidential IP / document fingerprint | High priority | Begin investigation within 2 hours |
| Large content submission only | Low — investigate but not urgent | Investigate within 24 hours |
| Source code (non-dev user) | Medium priority | Investigate within 4 hours |

---

## Step 2 — Open the User Activity Timeline

1. **Data Security Workbench → Alerts → [Alert ID]**
2. Click **View User Activity** or **Open Timeline**
3. Set the time range: 2 hours before and after the alert event

The timeline shows all events the agent captured for that user during the period — not just the alert-triggering event.

**What to look for in the timeline:**

| Event type | Significance |
|---|---|
| `file_open` before the prompt submit | Did the user open a file shortly before pasting? This confirms the data origin |
| `clipboard_copy` on corporate app → `clipboard_paste` on AI site | Confirms the copy-paste flow: which application was the source? |
| Multiple `genai_prompt_submit` events in rapid succession | Suggests systematic extraction, not a one-off mistake |
| `file_download` from AI site after submission | User downloaded AI-generated output — the AI processed the data and returned something |
| `web_browse` to AI tool followed by long session | Context for the scope of the AI session |

---

## Step 3 — Identify the Data and Its Source

From the timeline, determine:

**What data was submitted:**
- Review the captured content snippet (if available) or the classifier match details
- Identify the sensitivity level: is this a single name, or a full spreadsheet of employee records?
- Identify the data type: is this PII, credentials, source code, a document, or something else?

**Where the data came from:**
- Look for `file_open` or `clipboard_copy` events in the timeline
- The source application (Excel, Word, VS Code, email client) tells you the data origin
- If the source is SharePoint/OneDrive: note the file name and path for later reference in DSPM

**Which AI tool received it:**
- Confirm the URL from the alert
- Check the CASB app tier for this tool: is it Approved, Tolerated, or Review?
- Tolerated/Review tier tools receiving sensitive data is a higher-severity finding than Approved enterprise tools

---

## Step 4 — Cross-Correlate with CASB

1. **CASB → Activity** (or **Cloud Apps → Activity Search**)
2. Filter by: user, date range matching the alert
3. Look for:
   - OAuth tokens granted to the AI tool — did this user previously grant the AI tool access to their corporate cloud storage?
   - Download activity from SharePoint/OneDrive shortly before the AI prompt event — did the user download a corporate file specifically to use with the AI tool?
   - Other AI tools accessed in the same session — was this an isolated event or part of a broader pattern?

**Significant CASB finding:** If the user has an OAuth authorisation for the AI tool that triggered the DLP alert, the scope of exposure is potentially much larger than the single prompt submission. The AI tool may have been reading corporate files continuously. Escalate severity and revoke the OAuth token immediately.

---

## Step 5 — Cross-Correlate with Isolation

If the user was routed through Isolation for this AI site:

1. **Isolation Console → Session Activity**
2. Filter by: user, AI site domain, date range
3. Review:
   - Were clipboard paste or upload attempts blocked by Isolation before this event? (If yes: the user attempted to submit data and was blocked multiple times before finding a way around Isolation, or Isolation was not active for this specific session)
   - Were there prior sessions on the same AI site? (Pattern or one-off?)
   - What was the session duration? (Long sessions suggest active use)

**If Isolation was active but the event still fired:** The DLP rule captured content via a different path (e.g. manual typing, a browser with the extension but not routed through Isolation, a native AI desktop client). Review whether Isolation policy was correctly applied to this user/device.

---

## Step 6 — Assess User Context

Before reaching a verdict, gather context about the user:

| Context check | How to check | Significance |
|---|---|---|
| User's role | HR system / directory | Finance/Legal/HR users submitting role-specific data is different from IT staff |
| Previous DLP incidents | Workbench → User history | First event vs repeat offender |
| TAP VAP status | TAP dashboard | Is this user actively targeted? Higher risk context |
| Access to the type of data submitted | Data catalog / permissions review | Should this user even have access to this data? |
| AI tool approval status | CASB sanctioned app list | Did they use an approved tool or circumvent controls? |

**Key question:** Is this most likely an accident (copy-pasted the wrong content), expedient but careless (knowingly used AI to process sensitive data for work reasons), or potentially malicious (exfiltrating data via AI to circumvent DLP on email/USB)?

---

## Step 7 — Verdict and Action

### Verdict: False Positive

**Criteria:**
- The classifier fired on content that is not actually sensitive in context
- Example: "John Smith" triggered a PII classifier but the content was a sales email template about a fictional character, not a real person's data

**Action:**
1. Close the alert as False Positive in the Workbench
2. Document the false positive for classifier tuning
3. If this is a repeating pattern: adjust the classifier threshold or add a keyword allowlist entry — see [Building GenAI DLP Rules and Policies](../detection/building-genai-dlp-rules-and-policies.md)

### Verdict: Policy Violation — Accidental

**Criteria:**
- Real sensitive data was submitted to an AI tool
- Context suggests the user did not intend to violate policy (unaware, in a hurry, misjudged what was sensitive)
- First occurrence for this user
- Data submitted to a tolerated tool (not an explicitly prohibited one)

**Action:**
1. Mark alert as Confirmed in Workbench
2. Notify the user's manager — brief, factual, no accusatory language
3. Arrange targeted security awareness training for the user on AI data handling
4. If the AI tool involved is in the Tolerated tier: consider whether to move it to Review or Block
5. If the data type is consistently triggering accidental violations: consider a user-facing warning (not block) that triggers before submission to create friction without hard blocking

### Verdict: Policy Violation — Intentional or Repeat

**Criteria:**
- User has prior DLP incidents
- Pattern of use suggests deliberate circumvention (multiple attempts blocked by Isolation before successful submission via alternate method)
- Data is clearly sensitive and the user's role means they should know it is sensitive
- Data submitted to a Review or Blocked tier AI tool

**Action:**
1. Mark alert as Confirmed / Escalated in Workbench
2. Notify security lead and HR
3. Preserve evidence: export the timeline, alert details, and CASB correlation to your case management system
4. Add user to `genai-high-risk-users` group → triggers Tier 3 read-only Isolation
5. Revoke any OAuth tokens granted to AI tools for this user
6. Follow your organisation's disciplinary process

### Verdict: Critical — Credentials Exposed

**Criteria:**
- Alert rule: Credentials Detected
- A real credential (API key, password, SSH key) was confirmed in the submission

**Action:**
1. Treat as an active security incident — open an incident ticket
2. Rotate the exposed credential immediately — do not wait for investigation to complete
3. Check if the credential was already used maliciously: review service logs for unexpected access since the timestamp of the AI submission
4. Notify the system owner of the affected credential
5. Complete investigation steps above for user context
6. Escalate to CISO/security lead

---

## Evidence Preservation

For any Confirmed verdict, preserve:

- [ ] Alert ID and full alert details (screenshot or export)
- [ ] Workbench user activity timeline export (CSV)
- [ ] CASB correlation findings
- [ ] Isolation session log (if applicable)
- [ ] User's organisational context (role, access level, prior incidents)
- [ ] Action taken and timestamp

Store in your case management system. For Critical or Intentional findings, follow your legal hold and evidence handling procedures — do not modify or delete Workbench records.

---

## Related

- [Detecting Sensitive Data in AI Prompts](../detection/detecting-sensitive-data-in-ai-prompts.md) — How the detection rules that generate these alerts are configured.
- [Building GenAI DLP Rules and Policies](../detection/building-genai-dlp-rules-and-policies.md) — Using false positive findings to tune rules.
- [Adaptive AI Access Controls](../governance/adaptive-ai-access-controls.md) — Step-up isolation triggered by confirmed incidents.
- [Data Security Workbench — Alert Triage Runbook](../../data-security-workbench/alerts/alert-triage-runbook.md) — General alert triage procedures.
