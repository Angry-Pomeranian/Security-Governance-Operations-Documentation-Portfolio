# Building GenAI DLP Rules and Policies

## Overview

Configuring classifiers and triggers (covered in [Detecting Sensitive Data in AI Prompts](detecting-sensitive-data-in-ai-prompts.md)) is the technical foundation. This guide covers the policy design layer: how to structure rules that are surgical rather than blunt, differentiate by user group and AI tool risk tier, minimise false positives, and avoid blocking legitimate productivity use of AI tools.

The goal is a policy set that catches the genuine risk — a finance user pasting a payroll export into ChatGPT, a developer accidentally including an API key in a GitHub Copilot prompt — without triggering constantly on normal AI use.

---

## Policy Design Principles

**Principle 1 — Differentiate by user group, not just content.**
A developer submitting code to GitHub Copilot is different from a finance user submitting code to ChatGPT. The classifier hit is the same; the risk is not. Use user group conditions to apply different actions to the same classifier match.

**Principle 2 — Differentiate by AI tool risk tier.**
A submission to a sanctioned enterprise AI tool (Microsoft Copilot for M365 with data protection terms) is different from the same submission to a consumer-grade tool with unknown data handling. Use your CASB app tier list (from the [Shadow AI Discovery Guide](../visibility/shadow-ai-discovery-casb.md)) to drive different policy responses.

**Principle 3 — Block only what you are confident about.**
Block rules that have a high false positive rate damage trust in the security program and generate helpdesk calls. Alert on uncertain cases; block only high-confidence, high-severity matches.

**Principle 4 — Provide a path around the block.**
Every block should include a message that explains what happened and what the user can do: submit an exception request, use a different tool, remove the sensitive content. A dead block with no explanation generates confusion and shadow workarounds.

**Principle 5 — Escalate gradually.**
New rules should go through: Audit → Alert → Block. Skipping straight to Block on a new classifier is how you generate a wave of false positive blocks on day one.

---

## User Group Architecture

Design your user groups to match your policy differentiation needs. In Proofpoint ICS, user groups can be based on:
- Active Directory groups (via directory sync)
- CASB user attributes
- Manual user lists

Recommended groups for GenAI DLP:

| Group name | Members | Policy intent |
|---|---|---|
| `genai-approved-users` | Users with formal AI tool approval (enterprise Copilot, GitHub Copilot enterprise) | Relaxed policy on approved AI tools; normal policy on unsanctioned tools |
| `genai-dev-users` | Software engineers, data scientists | Allow code submission to approved tools; alert (not block) on other tools |
| `genai-sensitive-role-users` | Finance, Legal, HR, Executives | Stricter policy — alert at lower thresholds; additional categories (financial data, legal docs) |
| `genai-high-risk-users` | Users who have previously triggered DLP alerts | Elevated monitoring; step-up to Isolation (see [Adaptive AI Access Controls](../governance/adaptive-ai-access-controls.md)) |
| `genai-all-users` | Everyone (default) | Baseline policy covering credentials and large submissions |

---

## AI Tool Risk Tier Policy Mapping

From your CASB app tier classification, define policy actions per tier:

| App tier | Example apps | Policy action |
|---|---|---|
| **Approved** (enterprise, data processing terms signed) | Microsoft Copilot for M365, GitHub Copilot Enterprise | Monitor (audit log); block credentials and PHI only |
| **Tolerated** (acceptable risk, consumer tier) | ChatGPT free, Claude.ai, Perplexity | Alert on PII/IP; block credentials; warn on large content |
| **Review** (unknown data handling) | New tools, niche AI apps | Alert on all classifier matches; block PII and credentials |
| **Blocked** (policy prohibited) | Tools explicitly prohibited by policy | Block at network/DNS layer (Umbrella/CASB app block) before DLP is needed |

---

## Rule Design — The Matrix Approach

Design your rule matrix before configuring in the platform. Each cell is a policy decision:

### Credentials Rule (applies to all users, all AI tools)

| | Approved AI tools | Tolerated AI tools | Review tools |
|---|---|---|---|
| All users | **Block** | **Block** | **Block** |

Rationale: There is no legitimate reason to submit credentials to any AI tool. Block universally.

### PII Rule

| | Approved AI tools | Tolerated AI tools | Review tools |
|---|---|---|---|
| General users | Alert (medium) | Alert (high) | Block |
| Sensitive role users (HR/Finance/Legal) | Alert (high) | Block | Block |
| Executive users | Alert (high) | Block | Block |

Rationale: PII submitted to approved enterprise tools may have appropriate data handling. The same PII submitted to a consumer tool is a privacy incident.

### Source Code Rule

| | Approved AI tools | Tolerated AI tools | Review tools |
|---|---|---|---|
| Dev users | Audit/log | Alert (low) | Alert (medium) |
| Non-dev users | Alert (medium) | Alert (high) | Block |

Rationale: Developers using approved AI coding tools is expected. Developers using unapproved tools with proprietary code needs visibility. Non-developers submitting source code to any tool is unusual.

### Confidential IP / Document Fingerprint Rule

| | Approved AI tools | Tolerated AI tools | Review tools |
|---|---|---|---|
| All users | Alert (high) | Block | Block |

Rationale: Confidential documents should not leave the organisation via any AI tool without explicit approval, even enterprise ones.

### Large Content Submission (>10,000 characters)

| | All AI tools |
|---|---|
| All users | Alert (low/informational) |

Rationale: Volume alone is not a policy violation, but bulk submissions are a signal worth monitoring. Used in combination with user risk scoring.

---

## Configuring Rules in the Platform

### Rule Configuration Template

For each rule in the matrix above:

1. **ICS Admin Console → Policy → DLP Rules → New Rule**
2. **Trigger tab:**
   - Select: `GenAI Prompt Submit`
   - Site scope: AI tool risk tier (use CASB app category or explicit domain list)
3. **Conditions tab:**
   - Add classifier(s) for this rule
   - Set match threshold: exact match / N instances / content score above X
4. **User Scope tab:**
   - Apply to user group: [from your group architecture above]
   - Exclude: [groups that should not be caught by this rule]
5. **Actions tab:**
   - Select action: Audit / Alert / Block / Redact
   - Severity: Low / Medium / High / Critical
   - Alert notification: security team email / SIEM webhook
   - Block message: customise user-facing text
6. **Rule name:** Use a consistent naming scheme: `[Category] - [Classifier] - [User Group] - [Action]`
   - Example: `GenAI - PII - SensitiveRoles - Block`
7. Save

### Rule Ordering

Rules are evaluated in priority order. If multiple rules match a single event, the highest-priority rule's action applies.

**Recommended ordering:**
1. Credentials rules (Block) — always evaluate first
2. PHI/Health Information rules (Block)
3. High-severity PII rules for sensitive role users (Block)
4. Standard PII rules (Alert)
5. Confidential IP rules (Alert/Block)
6. Source code rules — dev exception first, then general
7. Large content / informational rules (Audit)

---

## Reducing False Positives

### Proximity and Co-occurrence Rules

Single-pattern matches generate more false positives than co-occurrence matches. Configure classifiers to require multiple indicators:
- PII: require Name + at least one identifier (DOB, TFN, account number) within 200 characters
- Credentials: require a credential prefix keyword (`api_key:`, `password=`) adjacent to the high-entropy string — reduces false positives from random base64 strings

### User Group Exclusions

Developer users intentionally work with code and test data that matches many classifiers. Rather than disabling classifiers for developers, apply exclusion groups:
- Exclude `genai-dev-users` from source code Block rules (they get Alert instead)
- Exclude `genai-approved-users` from the most restrictive rules on approved AI tools

### Keyword Allowlists

If specific legitimate business terms are triggering classifiers (e.g. an internal product name that matches a keyword in the IP classifier), add them to a classifier allowlist to suppress that match.

### Time-limited exclusions for testing

When a team has a legitimate business need to submit content that would normally trigger a rule (e.g. QA team testing data pipelines with real data, with proper controls), create a temporary time-bound exclusion:
- User group: specific users, time-limited (1 week)
- Document the exception in your DLP exception log
- Review and expire the exception on schedule

---

## Measuring Rule Performance

After rules are in production for 30 days, review:

| Metric | How to measure | Target |
|---|---|---|
| Alert volume per rule | Workbench → Alerts → filter by rule name | Stable or decreasing after tuning |
| False positive rate | Analyst verdict from alert reviews: closed as FP / total alerts | < 10% for Alert rules; < 5% for Block rules |
| True positive rate | Confirmed real violations / total alerts | Track over time — should improve with tuning |
| User escalation rate (block complaints) | IT helpdesk tickets referencing DLP block | < 2% of block events generate a ticket |
| Rules never firing | Workbench → Alerts → sort by zero events | Review and remove or recalibrate |

---

## Exception Management Process

Users or teams will request exceptions to DLP rules. Have a process before you start blocking:

1. **Request:** User/manager submits exception request via IT helpdesk ticket
2. **Review:** Security team reviews:
   - Is the request legitimate? (business justification)
   - Is there a lower-risk alternative? (use approved AI tool instead)
   - What is the data involved? (sensitivity classification)
3. **Approve with controls:** If approved, implement as a time-limited exclusion (max 30 days), require manager sign-off for sensitive data categories
4. **Deny with guidance:** If denied, explain why and offer alternatives
5. **Audit:** Log all exceptions in a DLP exception register; review quarterly

---

## Related

- [Detecting Sensitive Data in AI Prompts](detecting-sensitive-data-in-ai-prompts.md) — Classifier and trigger configuration.
- [Shadow AI Discovery Guide (CASB)](../visibility/shadow-ai-discovery-casb.md) — App tier classification that feeds into rule design.
- [Controlling AI Site Access via Isolation Console](controlling-ai-site-access-via-isolation.md) — Network-level controls that complement DLP rules.
- [Adaptive AI Access Controls](../governance/adaptive-ai-access-controls.md) — Dynamic policy tightening for high-risk users.
