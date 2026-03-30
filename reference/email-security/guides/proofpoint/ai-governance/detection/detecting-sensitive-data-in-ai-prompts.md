# Detecting Sensitive Data in AI Prompts

## Overview

This is the core detection guide for AI governance. It covers how to configure the Proofpoint endpoint agent to capture what users are submitting to AI tools, build classifiers for the data types most at risk (PII, credentials, source code, intellectual property), and configure the actions — alert, block, or redact — for each scenario.

The problem this guide solves: a user copies a salary spreadsheet, a client contract, an API key, or source code into an AI prompt box. Without this detection in place, that event is invisible to your security tooling. With it, you see it, and optionally stop it.

---

## How Prompt Capture Works

The Proofpoint endpoint agent operates in the browser (via browser extension) and intercepts content before it leaves the device:

```
User types/pastes into AI prompt box
    ↓
Browser extension intercepts the form submission event (GenAI Prompt Submit trigger)
    ↓
Agent scans the content against configured classifiers
    ↓
Match found?
    → No: submission proceeds, event logged
    → Yes: action applied (alert / block / redact) + event logged to Workbench
```

**Browser extension vs agent realm:**
- The **browser extension** handles in-browser events (web-based AI tools: ChatGPT, Claude.ai, Gemini, etc.)
- The **agent realm** (desktop agent) handles native app events (desktop AI clients, API-based tools, IDE extensions like GitHub Copilot)

Both must be configured for complete coverage.

---

## Step 1 — Verify Browser Extension Deployment

1. **ICS Admin Console → Deployment → Browser Extension**
2. Confirm the extension is deployed to target device groups
3. Supported browsers: Chrome, Edge, Firefox (check current platform documentation for version requirements)
4. Confirm extension is set to **Enforced** (not Optional) — optional installs are frequently disabled by users

**Verify on an endpoint:**
- Chrome: `chrome://extensions/` → look for `Proofpoint Browser Extension` (or `Proofpoint DLP Agent`)
- The extension icon should appear in the browser toolbar
- Status should show as Active / Enabled

**If the extension is missing:** check your MDM deployment (Intune/GPO/JAMF). The extension must be deployed as a force-installed enterprise extension, not as optional. See your ICS deployment guide for the extension ID and deployment policy configuration.

---

## Step 2 — Enable the GenAI Prompt Submit Trigger

The GenAI Prompt Submit trigger is a specific event type in the Proofpoint agent that captures the content of AI prompt submissions. It must be explicitly enabled — it is not on by default.

1. **ICS Admin Console → Policy → Agent Policies → [your policy] → Triggers**
2. Enable: **GenAI Prompt Submit** (may also be labelled "AI Prompt Submit" or "Web Form Submit — AI Sites" depending on platform version)
3. Configure scope:
   | Setting | Recommendation |
   |---|---|
   | Target sites | AI site category (preferred) or explicit domain list |
   | Content capture | Enabled (required for classifier matching) |
   | Metadata only mode | Disabled for detection (metadata only cannot classify content) |
4. Apply policy to: all users (or staged group during initial rollout)
5. Save and push policy

**Capture scope consideration:** Content capture of AI prompts captures potentially sensitive employee data. Confirm this is covered by your acceptable use policy and any applicable privacy legislation (GDPR, Australian Privacy Act, etc.) before enabling in production.

---

## Step 3 — Configure Data Classifiers

Classifiers define what sensitive data patterns the agent is looking for. Configure a classifier for each data category relevant to your organisation.

### Classifier 1 — Personally Identifiable Information (PII)

**Target:** Names + identifiers in combination; health information; financial account numbers

| Classifier type | Pattern |
|---|---|
| Built-in classifier | `PII - Names and Identifiers` |
| Built-in classifier | `PII - Health Information` |
| Built-in classifier | `PII - Financial Accounts` |
| Regex (Australia) | TFN: `\b\d{3}[ -]?\d{3}[ -]?\d{3}\b` |
| Regex (generic) | SSN: `\b\d{3}-\d{2}-\d{4}\b` |
| Keyword list | Add jurisdiction-specific terms: "date of birth", "medicare number", "passport number" |

**Proximity rule for PII:** A single name in a prompt is not PII. A name + date of birth + address in the same submission is. Configure the classifier to require a minimum of 2 PII indicators within 200 characters to reduce false positives.

### Classifier 2 — Credentials and API Keys

**Target:** Passwords, API keys, tokens, SSH private keys

| Classifier type | Pattern |
|---|---|
| Regex | API key (generic high-entropy string): `[A-Za-z0-9+/]{32,}={0,2}` |
| Regex | AWS access key: `AKIA[0-9A-Z]{16}` |
| Regex | GitHub token: `ghp_[A-Za-z0-9]{36}` or `github_pat_[A-Za-z0-9_]{82}` |
| Regex | Generic secret: `(password\|passwd\|secret\|api_key\|apikey)\s*[:=]\s*\S+` |
| Regex | Private key header: `-----BEGIN (RSA\|EC\|OPENSSH) PRIVATE KEY-----` |
| Built-in classifier | `Credentials and Keys` (if available in your platform) |

**Credential classifiers should always block, not just alert.** A credential in an AI prompt is an immediate security event — the AI vendor's infrastructure now has your credential. Treat as a severity 1 incident.

### Classifier 3 — Source Code and Software IP

**Target:** Proprietary source code, configuration files, internal build scripts

| Classifier type | Pattern |
|---|---|
| File type classifier | `.py`, `.js`, `.ts`, `.go`, `.java`, `.cs`, `.cpp`, `.h` content fingerprints |
| Keyword list | Internal library names, internal domain names (`corp.local`, internal app names) |
| Regex | Internal package references: `import com.yourcompany.*`, `from yourcompany import` |
| Content fingerprint | Register known IP documents as source fingerprints (if Proofpoint supports document fingerprinting in your version) |

**Context matters for code:** A developer using GitHub Copilot is expected to involve code. A finance user submitting code to ChatGPT is unusual. Use user group conditions in rules to differentiate (see [Building GenAI DLP Rules and Policies](building-genai-dlp-rules-and-policies.md)).

### Classifier 4 — Intellectual Property and Confidential Business Information

**Target:** Contracts, strategy documents, M&A information, unreleased product information

| Classifier type | Pattern |
|---|---|
| Keyword list | `confidential`, `strictly confidential`, `attorney-client privilege`, `internal use only` |
| Keyword list | Deal names, project codenames, unreleased product names (maintain an internal list) |
| Document fingerprint | Register template documents (contracts, NDAs, pitch decks) for fingerprint matching |
| Metadata classifier | Files with sensitivity labels: `Confidential` or `Highly Confidential` (if M365 sensitivity labels are integrated with Proofpoint) |

### Classifier 5 — Health Information (if applicable)

For healthcare or organisations handling health data:

| Classifier type | Pattern |
|---|---|
| Built-in classifier | `PHI - Protected Health Information` |
| Built-in classifier | `Health Insurance Numbers` |
| Keyword list | Medical terminology, diagnosis codes, medication names (if context is appropriate) |

---

## Step 4 — Create Detection Rules

With classifiers defined, create rules that combine trigger + classifier + action.

### Rule Structure

Each rule defines:
1. **Trigger:** GenAI Prompt Submit (from Step 2)
2. **Condition:** classifier match (from Step 3)
3. **Action:** alert / block / redact / audit
4. **Scope:** which users, devices, and AI sites this applies to

### Recommended Rule Set

| Rule name | Trigger | Classifier | Action | Scope |
|---|---|---|---|---|
| `GenAI - Credentials Detected` | GenAI Prompt Submit | Credentials + API Keys | **Block** | All users, all AI sites |
| `GenAI - PII Detected - All Users` | GenAI Prompt Submit | PII (2+ indicators) | **Alert** (high severity) | All users |
| `GenAI - Source Code - Non-Dev Users` | GenAI Prompt Submit | Source Code | **Block** | Exclude developer group |
| `GenAI - Source Code - Dev Users` | GenAI Prompt Submit | Source Code | **Alert** (medium) | Developer group only |
| `GenAI - Confidential IP` | GenAI Prompt Submit | Confidential/IP keyword + document fingerprint | **Alert** (high severity) | All users |
| `GenAI - Large Submission` | GenAI Prompt Submit | Content length > 10,000 characters | **Alert** (low/informational) | All users |

---

## Step 5 — Choose Actions

### Alert

Logs the event to the Workbench alert queue. The submission proceeds — the user is not interrupted. Use for:
- Medium-risk classifiers where the pattern has significant false positive potential
- During initial rollout (audit mode before enforcing)
- Developer users submitting code (expected behaviour, but should be visible)

### Block

Prevents the submission. The user sees a block notification in the browser (customise the message to explain why and what to do — e.g. "Sensitive data detected. Remove confidential information and retry, or contact IT to request an exception."). Use for:
- Credentials and API keys — always block, no exceptions
- PII in high-volume submissions
- After audit mode confirms the rule has low false positives

**Block message best practice:** Include a specific explanation and a contact/exception path. Vague block messages generate IT helpdesk calls; clear messages reduce them.

### Redact

The submission proceeds but the sensitive pattern is replaced with a placeholder (e.g. `[PII REDACTED]`) before being sent to the AI service. The user may not notice this. Use for:
- Low-sensitivity PII in otherwise legitimate prompts (e.g. a user summarising meeting notes that happen to include names)
- Scenarios where you want protection without disrupting workflow

**Redact availability:** Check whether redact is available in your Proofpoint ICS version and for the GenAI Prompt Submit trigger specifically — not all action types are available for all trigger types.

### Audit / Log Only

Logs the event without alerting the security team. Useful for building baseline data before escalating to alert or block.

---

## Step 6 — Initial Rollout — Audit Mode First

For all new rules, start in audit mode before enforcing:

1. Create rules with action = **Audit / Log only**
2. Run for 14 days
3. Review the Workbench for false positives:
   - Are legitimate developer prompts triggering the source code classifier?
   - Are personal names in context (e.g. "write an email to John about...") triggering PII?
   - Are code comments triggering credential patterns?
4. Tune classifier thresholds and user group exclusions to reduce false positives to an acceptable rate
5. Move to Alert (14 more days), then Block for high-severity rules

**Target false positive rate before blocking:** < 5% of alerts should be false positives for any rule set to Block. Above that threshold, you will burn analyst time and generate user complaints.

---

## DSPM Note

These rules detect data being **submitted to AI tools** from endpoints. They do not address:
- Data that AI tools can **pull from cloud storage** (Copilot for M365 indexing SharePoint)
- **Historical AI training** on previously submitted data (vendor-side, not detectable via endpoint agent)

For cloud-resident sensitive data accessible to AI tools, see the [DSPM Positioning Note](../dspm-note.md).

---

## Related

- [Building GenAI DLP Rules and Policies](building-genai-dlp-rules-and-policies.md) — Policy design and tuning once classifiers are configured.
- [Controlling AI Site Access via Isolation Console](controlling-ai-site-access-via-isolation.md) — Restricting upload and clipboard paste before detection is needed.
- [Investigating a GenAI Data Loss Alert](../investigation/investigating-genai-data-loss-alert.md) — What to do when a rule fires.
- [Data Security Workbench — Detection Rules](../../data-security-workbench/detection-rules/README.md) — General detection rule reference.
