# Controlling AI Site Access via Isolation Console

## Overview

The Proofpoint Isolation Console provides a layer of control that sits between DLP detection and outright blocking. Rather than choosing between "allow users to access AI sites freely" and "block AI sites entirely," Isolation lets you apply targeted restrictions: allow browsing but prevent uploads, disable clipboard paste, or render the session in a remote browser where no local data can leak.

This guide covers how to configure Isolation for AI sites, apply a tiered access model based on user risk, integrate with TAP's threat intelligence to automatically step up controls for at-risk users, and understand what each isolation mode prevents.

---

## How Proofpoint Isolation Works

Proofpoint Isolation (also referred to as Browser Isolation or Secure Browsing) routes web sessions through a remote Proofpoint-managed browser rather than the user's local browser. The user sees the rendered page; the actual web execution happens in Proofpoint's infrastructure.

**What isolation controls:**

| Control | Description |
|---|---|
| **Upload restriction** | Prevents file uploads to the isolated site |
| **Download restriction** | Prevents file downloads from the isolated site |
| **Clipboard restriction** | Prevents copy-paste between the isolated session and the local clipboard |
| **Print restriction** | Prevents printing from the isolated session |
| **Read-only mode** | Combines upload + clipboard restriction — browsing only |
| **Full isolation** | Maximum restrictions: read-only + download blocked + no local data interaction |
| **Unrestricted isolated** | Site runs in isolated browser for telemetry/logging, but no behavioural restrictions |

**What isolation does not control:**
- Users manually retyping content (cannot prevent a user from looking at a file and re-typing it)
- AI tools that operate as local desktop applications (outside browser scope)
- Content a user accesses from AI tool outputs (that data is already on the AI platform)

---

## Tiered Access Model

Design your AI site access policy as a three-tier model:

| Tier | Who | AI sites covered | Isolation mode |
|---|---|---|---|
| **Tier 1 — Full access** | Users with approved, sanctioned AI tool access; enterprise AI tools (Copilot for M365) | Approved AI tools | No isolation (native browser, monitored by endpoint agent) |
| **Tier 2 — Restricted access** | General staff; tolerated-tier AI tools | Consumer/unsanctioned AI tools | Isolated with clipboard + upload restrictions |
| **Tier 3 — Read-only** | High-risk users; users who have triggered DLP alerts; users explicitly assigned by policy | Any AI site | Full isolation — read-only, no upload, no clipboard |

**Tier 0 — Blocked:** AI tools classified as Blocked in CASB are blocked at the DNS/network layer (Umbrella or CASB app block). They never reach Isolation.

---

## Step 1 — Configure AI Site Categories for Isolation

Isolation policies target web categories or explicit URL lists.

1. **Isolation Console → Policies → Categories**
2. If an AI site category is available: assign it to the Isolation policy scope
3. If not: create a custom URL list:
   ```
   chat.openai.com
   chatgpt.com
   claude.ai
   gemini.google.com
   bard.google.com
   perplexity.ai
   poe.com
   character.ai
   huggingface.co/chat
   you.com
   copilot.microsoft.com/chat (consumer, not M365 enterprise)
   ```
   Maintain this list and update when new AI tools gain user adoption (use CASB discovery alerts to identify new tools).

---

## Step 2 — Create Isolation Policies

### Policy A — Tier 2: Clipboard + Upload Restriction for General Staff

1. **Isolation Console → Policies → New Policy**
2. Configure:
   | Field | Value |
   |---|---|
   | Policy name | `AI Sites - Restricted Access - General Staff` |
   | Target sites | AI site category or URL list |
   | User scope | All users (excluding Tier 1 approved group) |
   | Isolation mode | Isolated |
   | Upload files | **Blocked** |
   | Clipboard paste | **Blocked** |
   | Clipboard copy | Allowed (users can copy AI outputs) |
   | Downloads | Allowed (with logging) |
   | Print | Allowed |
3. **User-facing message (optional):** "You are accessing this AI tool in a restricted mode. File uploads and paste from clipboard are disabled. Contact IT to request expanded access."
4. Save

### Policy B — Tier 3: Read-Only for High-Risk Users

1. **Isolation Console → Policies → New Policy**
2. Configure:
   | Field | Value |
   |---|---|
   | Policy name | `AI Sites - Read Only - High Risk Users` |
   | Target sites | All AI sites (including approved tools) |
   | User scope | `genai-high-risk-users` group |
   | Isolation mode | Fully isolated |
   | Upload files | **Blocked** |
   | Clipboard paste | **Blocked** |
   | Clipboard copy | **Blocked** |
   | Downloads | **Blocked** |
   | Print | **Blocked** |
3. Save

### Policy C — Unrestricted Isolated for Approved Users (Logging Only)

For approved enterprise AI tools, you may want Isolation telemetry without restricting behaviour:

1. **Isolation Console → Policies → New Policy**
2. Configure:
   | Field | Value |
   |---|---|
   | Policy name | `AI Sites - Approved Tools - Monitored` |
   | Target sites | Approved AI tool list only (Copilot for M365, GitHub Copilot enterprise) |
   | User scope | `genai-approved-users` group |
   | Isolation mode | Isolated (for telemetry) |
   | All restrictions | **Allowed** |
3. This generates Isolation session logs that can be reviewed in investigation, without restricting the user experience.

---

## Step 3 — Policy Ordering

Isolation policies are evaluated in priority order — highest priority wins.

Recommended order:
1. `AI Sites - Read Only - High Risk Users` (most restrictive first)
2. `AI Sites - Approved Tools - Monitored` (specific approved tool exception before general restriction)
3. `AI Sites - Restricted Access - General Staff` (baseline for everyone else)

---

## Step 4 — TAP Integration: Route High-Risk Users into Isolation

TAP's Very Attacked People (VAP) data identifies users who are disproportionately targeted by threat actors. Users who are being actively targeted are higher risk on AI tools too — a VAP who is targeted by spear phishing is also more likely to have their credentials harvested, making their AI sessions higher risk.

### Configure TAP → Isolation Integration

1. **TAP → Threat Response → Isolation Routing Policy**
2. Configure:
   | Field | Value |
   |---|---|
   | Source | TAP VAP list (updated automatically) |
   | Trigger | User appears in top N VAPs (configure N: typically 10–25 most attacked users) |
   | Action | Apply isolation policy: `AI Sites - Read Only - High Risk Users` |
   | Duration | 30 days (review period) |
3. Save

This means VAPs automatically get read-only AI site access while they are on the VAP list — no manual intervention required.

### Alternative: Risk Score Threshold

If TAP provides a user risk score (some configurations):
- Trigger isolation step-up when risk score > threshold (e.g. > 70)
- Automatically revert to standard policy when score drops

---

## Step 5 — DLP Alert → Isolation Step-Up

When a user triggers a DLP alert for GenAI data submission, automatically escalate their isolation level:

**Manual process (if automation is not configured):**
1. Alert fires in Workbench
2. Analyst reviews alert
3. If confirmed or escalated: analyst manually moves user to `genai-high-risk-users` group
4. Group membership triggers Tier 3 read-only isolation policy

**Automated process (if Workbench → SOAR integration is configured):**
1. Alert fires (high severity GenAI rule)
2. SOAR playbook triggers:
   - Add user to `genai-high-risk-users` group via API
   - Notify manager via email
   - Create investigation ticket
3. Isolation policy automatically applies at next session

Document the criteria for automatic vs manual step-up:
| DLP alert severity | Step-up action |
|---|---|
| Critical (credentials detected) | Automatic step-up + immediate manager notification |
| High (PII/confidential IP) | Manual step-up after analyst review (within 4 hours) |
| Medium (source code, large content) | No step-up unless pattern repeats |
| Low/informational | No step-up |

---

## Step 6 — Reviewing Isolation Session Logs

Isolated session activity is logged and available for investigation:

1. **Isolation Console → Reporting → Session Activity**
2. Filter by: user, AI site, date range
3. Review:
   - Session duration and pages visited
   - Upload attempts (blocked events)
   - Clipboard paste attempts (blocked events)
   - Download events

Use isolation session logs during alert investigation to correlate with Workbench events — see [Investigating a GenAI Data Loss Alert](../investigation/investigating-genai-data-loss-alert.md).

---

## What Isolation Covers vs What It Does Not

| Scenario | Does Isolation prevent it? |
|---|---|
| User pastes API key into ChatGPT | Yes — clipboard paste blocked (Tier 2/3) |
| User uploads a confidential PDF to an AI tool | Yes — file upload blocked (Tier 2/3) |
| User manually types PII into an AI prompt | No — cannot prevent manual typing |
| User takes a photo of their screen with a phone | No |
| User accesses AI tools via a personal device | No — Isolation only covers managed devices |
| AI tool's desktop application (not browser-based) | No — browser isolation does not cover native apps |
| Copilot for M365 reading SharePoint files | No — this is data at rest; DSPM is the right tool |

---

## DSPM Note

Isolation controls data flowing **into** AI tools via browser actions. Microsoft Copilot for M365 accesses data differently — it reads from SharePoint, OneDrive, and Exchange without requiring the user to paste anything. Isolation cannot restrict this access pattern.

For controlling what Copilot for M365 can access, the control surface is data classification and permissions in SharePoint/OneDrive (reducing oversharing) and Copilot access scoping. See the [DSPM Positioning Note](../dspm-note.md) for how Proofpoint DSPM maps this exposure.

---

## Related

- [Detecting Sensitive Data in AI Prompts](detecting-sensitive-data-in-ai-prompts.md) — DLP layer that complements Isolation controls.
- [Adaptive AI Access Controls](../governance/adaptive-ai-access-controls.md) — Dynamic escalation using TAP VAP and DLP trigger data.
- [Shadow AI Discovery Guide (CASB)](../visibility/shadow-ai-discovery-casb.md) — Identifying which AI sites to target in Isolation policy.
