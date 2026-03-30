# Adaptive AI Access Controls — TAP + Isolation Integration

## Overview

Static DLP rules and Isolation policies treat all users the same. The adaptive approach uses Proofpoint's TAP threat intelligence and incident history to dynamically tighten AI site controls for users whose risk profile warrants it — without manually intervening for each user.

This guide covers how to use TAP's Very Attacked People (VAP) data and user risk signals to automatically step up Isolation controls for at-risk users, and how to configure policy escalation that triggers when a user has already demonstrated risky AI behaviour.

**Why this matters:** A user who is actively being targeted by spear phishing, or who has already triggered a GenAI DLP alert, is a materially higher risk on AI tools than the general population. Applying the same AI access policy to everyone ignores this signal.

---

## Signal Sources

The adaptive controls in this guide draw on two signal types:

| Signal | Source | What it indicates |
|---|---|---|
| Very Attacked People (VAP) status | TAP → VAP list (updated daily) | User is disproportionately targeted by threat actors — elevated external threat |
| User risk score | TAP → User Risk Dashboard | Composite score based on attack targeting, credential exposures, and vulnerability |
| Prior GenAI DLP alert (confirmed) | Workbench → Alert history | User has previously submitted sensitive data to an AI tool |
| Repeat DLP alerts | Workbench → User activity history | Pattern of behaviour, not a one-off event |
| OAuth token granted to AI app | CASB → OAuth | User has given an AI tool persistent access to corporate data |

---

## Step 1 — Define Risk Tiers for Adaptive Controls

Create three user risk tiers that drive Isolation policy:

| Risk tier | Criteria | Isolation policy |
|---|---|---|
| **Standard** | No TAP signals; no prior GenAI DLP incidents | Tier 2: clipboard + upload restricted (for unsanctioned AI tools) |
| **Elevated** | TAP user risk score > 50 OR 1 confirmed GenAI DLP alert in last 90 days OR active OAuth token to an AI app | Tier 2.5: as Standard + read-only on Review-tier AI tools |
| **High** | Top 25 VAPs OR TAP user risk score > 75 OR 2+ confirmed GenAI DLP alerts in last 90 days | Tier 3: read-only on all AI sites including approved tools |

---

## Step 2 — Configure TAP VAP Integration with Isolation

### In TAP

1. **TAP → Dashboard → Top VAPs** — confirm the VAP list is populated and updating
2. Note the TAP integration API endpoint and credentials (Admin → API Access)

### In ICS Isolation

1. **Isolation Console → Policies → User Risk Integration → Configure TAP**
2. Connect to TAP API:
   | Field | Value |
   |---|---|
   | TAP API URL | `https://tap-api-v2.proofpoint.com/v2/` |
   | API key / credentials | From TAP Admin → API Access |
   | Sync frequency | Daily (VAP list updates daily) |
3. Configure VAP-triggered policy:
   | Setting | Value |
   |---|---|
   | Trigger | User in Top N VAPs |
   | N | 25 (adjust based on org size) |
   | Apply isolation policy | `AI Sites - Read Only - High Risk Users` (Tier 3) |
   | Duration | Rolling — policy applies while user is on VAP list; reverts to Standard when removed |
4. Save and test: add a test user to the VAP list manually → confirm Tier 3 Isolation applies at next session

### Verify Integration

1. Identify a user currently on the VAP list
2. Check their Isolation policy in **Isolation Console → Users → [user]**
3. Confirm the policy shows `AI Sites - Read Only - High Risk Users` (not the standard Tier 2 policy)

---

## Step 3 — Configure DLP Alert → Isolation Step-Up

When a Workbench alert is confirmed as a policy violation, automatically or manually escalate the user's Isolation tier.

### Manual Step-Up Process

1. Analyst confirms alert in Workbench
2. Analyst adds user to `genai-high-risk-users` Active Directory or ICS group
3. Isolation policy order ensures `AI Sites - Read Only - High Risk Users` takes precedence for this group
4. Duration: 90 days (review at end of period)

Document in the alert closure notes: "User added to `genai-high-risk-users` group. Isolation stepped up to Tier 3. Review date: [90 days from now]."

### Automated Step-Up (If SOAR Integration Is Available)

If Proofpoint is connected to a SOAR platform (Splunk SOAR, Microsoft Sentinel with playbooks, Cortex XSOAR):

**Trigger:** Workbench alert status changes to "Confirmed" for a GenAI rule with severity = High or Critical

**Playbook actions:**
1. Query Workbench API for user identifier from the alert
2. Add user to `genai-high-risk-users` group via AD Graph API or ICS API
3. Create a JIRA/ServiceNow ticket with the user, alert ID, and 90-day review date
4. Send notification email to user's manager: "Your team member [User] has had their AI tool access temporarily restricted following a data security review. Contact the security team for details."
5. Schedule a follow-up task in 90 days to review group membership

### Escalation Thresholds

Not every alert should trigger step-up. Apply escalation based on severity:

| Alert severity | Action |
|---|---|
| Critical (credentials) | Immediate Tier 3 step-up + incident ticket + manager notification |
| High (PII, confidential IP) | Tier 3 step-up after analyst confirmation (within 4 hours) + manager notification |
| Medium (source code, large content) | No automatic step-up; flag for 90-day monitoring review |
| Low/informational | No step-up; included in monthly reporting only |

---

## Step 4 — Configure User Risk Score Threshold

If TAP provides a user risk score (0–100) rather than just a VAP list:

1. **Isolation Console → Policies → User Risk Integration → Risk Score**
2. Configure thresholds:
   | Risk score range | Isolation policy |
   |---|---|
   | 0–49 | Standard (Tier 2) |
   | 50–74 | Elevated (Tier 2.5) |
   | 75–100 | High (Tier 3) |
3. Score updates: configure sync frequency (daily recommended)
4. Risk score sources (TAP aggregates): attack targeting frequency, exposed credential hits, known phishing click history

---

## Step 5 — CASB OAuth Signal Integration

Users who have granted AI apps OAuth access to corporate cloud storage represent a persistent, ongoing risk — not just a one-time event. Use the OAuth signal to flag these users:

1. **CASB → OAuth → filter: AI apps, permissions: ReadWrite/Mail.Read**
2. For each high-risk OAuth authorisation found:
   - Revoke the token (immediate remediation)
   - Add the user to the `genai-elevated-users` group (Tier 2.5)
   - Flag for follow-up: did the user re-grant the token after revocation?
3. Configure a CASB alert for new OAuth grants to AI apps:
   - **CASB → Policies → OAuth Policy** → trigger on new authorisation to AI app category with sensitive permissions
   - Action: alert security team + optionally auto-revoke

---

## Step 6 — User Communication for Step-Up Controls

Adaptive controls can feel arbitrary to users if not communicated. Have a communication template ready:

**Template for Isolation step-up:**

> Subject: Temporary restriction on AI tool access
>
> Your access to AI tools has been temporarily restricted to read-only mode as a precautionary measure following a review of our data security monitoring.
>
> What this means: You can still visit AI tool websites but cannot paste content or upload files during this period.
>
> Duration: This restriction is currently in place for 90 days.
>
> Questions: Contact [IT security contact] to discuss this restriction or to request a review.

**Important:** Do not include the specific alert details in the user communication — that is for the manager and HR process, not direct user notification.

---

## Step 7 — Monthly Adaptive Controls Review

At each monthly review:

1. **Workbench → User Activity** → check `genai-high-risk-users` group members:
   - Are any members due for review (90-day mark reached)?
   - Have any members been reassigned, left the organisation, or had their role change?
2. **TAP → VAP list** → check whether any users dropped off the VAP list
   - If a user is no longer on the VAP list AND has had no GenAI incidents since step-up: consider returning to Standard tier
3. **CASB → OAuth** → check for newly re-granted tokens for users who were previously revoked
4. Update group membership based on review findings — document changes in your security log

---

## Revocation and Return to Standard Policy

Criteria for removing a user from the High-risk tier:

| Criteria | Required |
|---|---|
| 90 days with no further GenAI DLP alerts | Yes |
| Completion of targeted security awareness training | Recommended |
| Manager acknowledgement | Yes (for Intentional violation cases) |
| No outstanding OAuth tokens to AI apps | Yes |
| No longer on TAP VAP list (if that triggered the step-up) | Yes (if VAP was the primary trigger) |

---

## DSPM Note

Adaptive AI access controls address behaviour-based risk: the user is the variable. DSPM addresses a different dimension: the data itself is the risk, regardless of user behaviour.

If Microsoft Copilot for M365 is in scope, a low-risk user can still inadvertently expose sensitive data if that data is overshared in SharePoint and Copilot surfaces it in a response. The control there is data permissions and classification, not user-level Isolation policy.

See [DSPM Positioning Note](../dspm-note.md) for how these layers complement each other.

---

## Related

- [Controlling AI Site Access via Isolation Console](../detection/controlling-ai-site-access-via-isolation.md) — Static Isolation policy configuration.
- [Investigating a GenAI Data Loss Alert](../investigation/investigating-genai-data-loss-alert.md) — The investigation process that generates step-up triggers.
- [CASB OAuth Governance for AI Apps](casb-oauth-governance-for-ai-apps.md) — OAuth token management that feeds risk signals.
