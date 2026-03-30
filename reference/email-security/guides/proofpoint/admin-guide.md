# Proofpoint — Administrator Guide

## Overview

This guide covers the configuration, tuning, and operational procedures for Proofpoint Essentials and Proofpoint Enterprise (POD/hosted) environments. It addresses the most common administrative pain points: email authentication setup, false positive management, URL Defense, phishing simulation allowlisting, Microsoft 365 integration, and TRAP automated remediation.

**Products covered:**

| Product | Coverage |
|---|---|
| Proofpoint Essentials | SMB/mid-market hosted platform |
| Proofpoint Enterprise (POD) | Tenant-hosted enterprise deployment |
| TAP (Targeted Attack Protection) | URL Defense, Attachment Defense, TRAP |
| Proofpoint Encryption | Secure message delivery |

---

## 1. Email Authentication — SPF, DKIM, DMARC

Email authentication is the most frequently misconfigured area when onboarding Proofpoint. Proofpoint does not automatically pass or fail messages based solely on DMARC — it uses its own reputation and policy engine in addition to authentication results.

### 1.1 SPF

Proofpoint delivers mail from its own IP ranges. Your SPF record must authorise Proofpoint's sending infrastructure.

**Required SPF include:**
```
include:pphosted.com
```

**Example SPF record for a domain routing outbound mail through Proofpoint:**
```
v=spf1 include:spf.protection.outlook.com include:pphosted.com -all
```

**Important SPF caution — the 10-lookup limit:**
SPF evaluation fails if the DNS lookup chain exceeds 10 lookups. If you have multiple `include:` statements, use a tool such as MXToolbox SPF checker to verify your lookup count. Exceeding the limit causes SPF to return `PermError`, which Proofpoint may treat as a soft fail.

**SPF for inbound (Proofpoint as MX gateway):**
If Proofpoint is your MX gateway, inbound SPF checks are performed by Proofpoint against the sending server's IP. No changes to your SPF record are needed for inbound processing.

---

### 1.2 DKIM

**Proofpoint DKIM signing (outbound):**
Proofpoint can sign outbound mail with DKIM on behalf of your domain.

1. In Proofpoint Admin Console: **Email Protection → Email Authentication → DKIM Signing**
2. Create a new signing key for your domain
3. Proofpoint generates a selector and public key
4. Publish the CNAME or TXT record in your DNS:
   ```
   proofpoint._domainkey.yourdomain.com  CNAME  proofpoint._domainkey.pphosted.com
   ```
   (CNAME is preferred — allows Proofpoint to rotate keys without DNS changes)
5. Click **Verify** in the Proofpoint console to confirm DNS propagation

**Common DKIM issue — dual signing:**
If Microsoft 365 is also signing outbound mail with DKIM before it reaches Proofpoint, messages may arrive at the recipient with two DKIM signatures. This is acceptable — verifiers check the most recent valid signature. Ensure the Proofpoint signature is not breaking the M365 DKIM-Signature header by confirming Proofpoint signs after M365.

**DKIM verification (inbound):**
Proofpoint verifies DKIM signatures on inbound mail as part of its reputation scoring. DKIM failures do not automatically reject mail — they are factored into the sender score alongside SPF and DMARC results.

---

### 1.3 DMARC

**Publishing a DMARC record:**
```
v=DMARC1; p=reject; rua=mailto:dmarc-reports@yourdomain.com; ruf=mailto:dmarc-forensic@yourdomain.com; pct=100
```

| Tag | Value | Notes |
|---|---|---|
| `p` | `none` → `quarantine` → `reject` | Start with `none` for monitoring; move to `reject` after 30 days of clean reports |
| `rua` | Aggregate report address | Receives daily XML aggregate reports from other mail providers |
| `ruf` | Forensic report address | Receives per-message forensic reports (not all providers send these) |
| `pct` | 1–100 | Percentage of messages subject to policy; use 10–50% during rollout |

**Proofpoint-specific DMARC behaviour:**
Proofpoint does **not** automatically enforce the sending domain's DMARC policy in all configurations. By default, Proofpoint's policy engine uses DMARC as one signal among many. To enforce strict DMARC:

1. In Proofpoint Admin Console: **Email Protection → Email Authentication → DMARC**
2. Enable **Honor DMARC policy**
3. Set action per policy level:
   | DMARC policy | Proofpoint action |
   |---|---|
   | `p=none` | No action (passthrough) |
   | `p=quarantine` | Quarantine the message |
   | `p=reject` | Reject or quarantine (configurable) |
4. Enable **Reject messages that fail DMARC with p=reject**

**Common trap:** If you enable "Honor DMARC policy" before your own SPF and DKIM are correctly configured, you may start rejecting your own legitimate outbound mail when it loops back through third-party services (mailing lists, CRMs). Validate your SPF/DKIM alignment on all sending sources before enabling.

---

### 1.4 Anti-Spoofing Policy

Proofpoint's anti-spoofing (impersonation protection) is separate from DMARC enforcement and is configured under TAP or Email Protection policies.

**Configure domain-based anti-spoofing:**
1. **Email Protection → Policies → Anti-Spoofing**
2. Add your primary domain and any domains you own to the protected list
3. Action for spoofed messages: **Quarantine** (recommended) or **Discard**
4. Enable **Header From** checking — this catches cases where the envelope sender passes SPF but the visible From header is spoofed

**Lookalike domain protection (TAP):**
1. **TAP → Dashboard → Domain Discovery**
2. Review lookalike domains detected by Proofpoint
3. Add domains to your block list or configure alerts

**Safe sender list conflict:**
If a spoofed message arrives from a domain that is on a user's personal safe sender list, the anti-spoofing policy may be bypassed. Enforce that admin-managed block lists take precedence over user-level lists:
- **Email Protection → End User Settings → Allow personal safe sender lists to override policy** → Disable for high-risk scenarios

---

## 2. False Positive Management

### 2.1 Message Trace

To investigate a message that was blocked or quarantined:
1. **Email Protection → Message Trace**
2. Search by: From address, To address, Subject (partial), Message ID, or time range
3. The trace shows each processing stage: received, policy matches, disposition (delivered, quarantined, discarded)
4. Click any message to view the full processing log and reason codes

### 2.2 Organisation-Level Allow Lists

For persistent false positives from a specific sender (e.g. a vendor, payroll provider, or partner):

**Add a sender to the organisation safe sender list:**
1. **Email Protection → Spam → Allowed Senders**
2. Add the address (`vendor@supplier.com`) or domain (`@supplier.com`)
3. Select **Bypass spam scanning** and optionally **Bypass URL Defense** (for trusted internal-like partners only — use with caution)

**Add an IP address to the connection-level allow list:**
For senders whose mail is blocked at connection (before content inspection):
1. **Email Protection → Connection → Allowed Senders (IP)**
2. Enter the sending server's IP or CIDR range
3. This bypasses connection-level blocking but not content inspection unless configured

**Best practice for vendor allow lists:**
- Allow at the sender address level, not the domain level, wherever possible
- Document each entry: date added, reason, approving admin, review date
- Review and prune the list quarterly — stale entries are a risk

### 2.3 Bulk Mail (Graymail) Tuning

Bulk mail is a common source of false positives for mailing lists and notification systems.

1. **Email Protection → Spam → Bulk Mail**
2. Adjust bulk mail sensitivity per policy (Low/Medium/High)
3. For specific senders whose bulk mail is wanted: add to the organisation allowed senders list and check **Bypass bulk mail classification**

---

## 3. TAP — Targeted Attack Protection Setup and Tuning

### 3.1 URL Defense Configuration

URL Defense rewrites inbound URLs and scans at click time. Key configuration options:

**Enable URL Defense:**
1. **TAP → URL Defense → Configuration**
2. Enable rewriting for: **HTML links**, **Plain text links**, **Links in attachments** (optional — increases processing time)
3. Set time-of-click action: **Block** (recommended) or **Warn and allow** (lower friction for end users)

**URL categories to block vs warn:**
| Category | Recommended action |
|---|---|
| Malware | Block |
| Phishing | Block |
| Credential phishing | Block |
| Newly registered domains (< 30 days) | Block or Warn |
| URL shorteners | Warn (expand and re-check) |
| Known safe categories (news, government) | Allow passthrough |

**Configuring URL exceptions (bypass URL Defense):**
For internal tools, SaaS platforms, or URLs that are causing rewrite-related breakage (e.g. authentication callbacks that fail when rewritten):
1. **TAP → URL Defense → Exceptions**
2. Add the URL pattern or domain
3. Options: bypass rewriting entirely, or rewrite but skip click-time blocking

**Common rewrite breakage scenarios:**
| Scenario | Fix |
|---|---|
| OAuth/SSO callback URLs fail after rewrite | Add the callback URL pattern to URL Defense exceptions |
| DocuSign or Adobe Sign links break | Add `*.docusign.net`, `*.docusign.com`, `*.adobesign.com` to exceptions |
| Internal help desk/ticketing system links loop | Add internal domain to exceptions |
| Email verification links expire because rewrite delays click | Review link expiry with the sending vendor; exception may be appropriate |

### 3.2 Attachment Defense (Sandboxing)

**Enable Attachment Defense:**
1. **TAP → Attachment Defense → Configuration**
2. Enable sandboxing for suspicious attachments
3. Default action while sandboxing is in progress: **Deliver with replacement attachment** (replaces attachment with a placeholder; original delivered after analysis) or **Hold message** (delay delivery)

**Time-out behaviour:** If sandbox analysis exceeds the timeout (typically 5–10 minutes), the default action applies. Configure this based on your organisation's risk tolerance vs delivery latency requirements.

**File types to sandbox:**
Office documents (`.docx`, `.xlsx`, `.pptx`), PDFs, executables (`.exe`, `.msi`), scripts (`.js`, `.vbs`), archives (`.zip`, `.rar`, `.7z` — contents are extracted and scanned).

---

## 4. Phishing Simulation Allowlisting

Phishing simulation platforms (KnowBe4, Proofpoint Security Awareness Training, Cofense, Terranova, Gophish) send test phishing emails. Without allowlisting, Proofpoint blocks or quarantines these, which skews your simulation results.

### 4.1 Allowlisting KnowBe4

**KnowBe4 requires allowlisting at three layers:**

**Layer 1 — IP allow list (connection level):**
Add KnowBe4's sending IP ranges to the Proofpoint IP allow list. Current KnowBe4 IPs:
```
192.168.1.0/24  ← example only; obtain current list from KnowBe4 support
149.20.54.0/24
206.71.56.0/24
```
> Always verify current IP ranges with KnowBe4 — they change periodically. KnowBe4 publishes their current IP list at: https://support.knowbe4.com/hc/en-us/articles/204780688

1. **Email Protection → Connection → Allowed Senders (IP)**: Add all KnowBe4 IP ranges

**Layer 2 — Sender domain allow (content level):**
1. **Email Protection → Spam → Allowed Senders**: Add KnowBe4 sending domains
   - `@knowbe4.com`
   - `@knb4.com` (short domain used in some campaigns)
   - Any custom domain configured in KnowBe4 for your tenant

**Layer 3 — TAP bypass:**
Phishing simulation links must not be blocked by URL Defense. Add simulation domains to URL Defense exceptions:
1. **TAP → URL Defense → Exceptions**: Add KnowBe4 click-tracking domains
   - `*.knowbe4.com`
   - `*.knb4.com`
   - Any custom landing page domains configured in your KnowBe4 account

**Validation after allowlisting:**
1. Send a KnowBe4 test campaign to a test mailbox
2. Confirm the message delivers to the inbox (not quarantine)
3. Confirm clicking the phishing link in the test message reaches the KnowBe4 landing page (not a Proofpoint block page)
4. Confirm the click registers in KnowBe4 analytics

### 4.2 Allowlisting Proofpoint Security Awareness Training (SAT)

If using Proofpoint SAT alongside Proofpoint email filtering (both Proofpoint products), the allowlisting is done through internal policy tagging rather than IP-based:
1. **Proofpoint SAT → Simulations → Campaign Settings**
2. Enable **Exclude from Email Filtering** — this tags outbound simulation emails at the platform level, bypassing your Proofpoint email gateway

### 4.3 Allowlisting Other Platforms

For any simulation platform, obtain:
- Sending IP ranges (for connection-level allowlisting)
- Sending domains (for content-level allowlisting)
- Click-tracking domains (for URL Defense exceptions)

Apply all three layers. Missing even one layer will cause incomplete delivery or broken click tracking.

---

## 5. Microsoft 365 Integration

### 5.1 Architecture

Proofpoint sits in front of M365 as an inbound MX gateway. The recommended architecture:

```
Internet → Proofpoint (MX) → Microsoft 365 (SMTP relay)
```

M365 must be configured to accept mail only from Proofpoint's IP ranges to prevent bypass.

### 5.2 MX Record Configuration

Set your MX record to point to Proofpoint:
```
yourdomain.com  MX  10  yourdomain.pphosted.com
```

The Proofpoint hostname is provided in your Proofpoint Admin Console under **Setup → Domains**.

### 5.3 M365 Inbound Connector (Restrict to Proofpoint IPs)

Create a connector in Exchange Admin Center (EAC) to reject mail not originating from Proofpoint:

1. **EAC → Mail Flow → Connectors → New → From: Partner → To: Office 365**
2. Name: `Inbound from Proofpoint`
3. **Security restrictions:** Require that the sender domain matches a specific domain (optional) AND/OR restrict to specific IP ranges (Proofpoint's IP ranges — obtain from Proofpoint Admin Console → Setup → IPs)
4. Enable: **Reject email messages if they are not sent over TLS**

**Why this matters:** Without IP restriction on the M365 inbound connector, attackers can bypass Proofpoint by sending mail directly to `yourdomain.mail.protection.outlook.com` (the default M365 MX record, which is publicly resolvable).

Verify the M365 default MX is not publicly advertised — the only published MX should be the Proofpoint one.

### 5.4 Outbound Mail Flow (M365 → Proofpoint → Internet)

For Proofpoint to scan and sign outbound mail:

1. Create a **Send Connector** in Exchange / an **Outbound Connector** in EAC:
   - Route all outbound mail to the Proofpoint smart host: `{tenant}.pphosted.com`
   - Require TLS
2. In Proofpoint: configure the relay host to accept mail from your M365 IP ranges (or use authenticated SMTP relay)

### 5.5 Proofpoint TAP and Microsoft Defender Alignment

If both Proofpoint TAP and Microsoft Defender for Office 365 (MDO) are active, configure them to avoid dual scanning conflicts:

- **Disable MDO Safe Links** for messages already processed by Proofpoint URL Defense — dual rewriting breaks links
- **Disable MDO Safe Attachments** for messages already sandboxed by Proofpoint Attachment Defense — dual sandboxing increases latency and may cause false positives
- Configure MDO as a secondary layer only if Proofpoint is the primary gateway

**M365 Enhanced Filtering (Skip Listing):**
Enable Enhanced Filtering for Connectors in EAC so M365 sees the true sender IP (not Proofpoint's relay IP) for SPF/DKIM/DMARC evaluation:
1. **EAC → Mail Flow → Connectors → [Inbound from Proofpoint] → Edit → Enhanced Filtering**
2. Enable and enter Proofpoint's relay IP ranges to skip

---

## 6. TRAP — Threat Response Auto-Pull

TRAP (Threat Response Auto-Pull) automatically removes malicious messages from user inboxes after they have been delivered — triggered by a TAP threat verdict that arrives after delivery, a reported phishing submission, or an admin-initiated campaign pull.

### 6.1 Prerequisites

- Proofpoint TAP licence with TRAP enabled
- Microsoft 365 with Exchange Web Services (EWS) or Microsoft Graph API access
- Service account with Mail.ReadWrite permissions (Graph) or impersonation rights (EWS)

### 6.2 Connect TRAP to Microsoft 365

**Using Microsoft Graph API (recommended for M365):**
1. Register an Azure AD application for TRAP:
   - **Azure AD → App Registrations → New registration**
   - Name: `Proofpoint TRAP`
   - Redirect URI: None (service-to-service)
2. Assign API permissions:
   - `Mail.ReadWrite` (Application permission — requires admin consent)
3. Grant admin consent
4. Copy the **Application (client) ID** and **Directory (tenant) ID**
5. Create a **client secret** (or certificate — preferred)
6. In Proofpoint Admin Console: **TRAP → Sources → Microsoft Graph → Configure**
   - Enter tenant ID, application ID, client secret
   - Test connection

### 6.3 TRAP Workflow

```
TAP verdict update (post-delivery) / User reports phishing
    ↓
TRAP identifies all mailboxes that received the same message
    ↓
TRAP moves matching messages to Deleted Items (or Hard Delete, if configured)
    ↓
TRAP sends notification to admin: [N] messages pulled, list of affected users
    ↓
Admin reviews pull report in TRAP console
```

### 6.4 TRAP Configuration Options

| Setting | Options | Recommendation |
|---|---|---|
| Pull action | Move to Deleted Items / Move to custom folder / Permanently delete | Move to Deleted Items (recoverable; allows false positive review) |
| Scope | Current message only / All messages in same campaign | All messages in campaign (more effective containment) |
| Trigger | TAP verdict only / User reports only / Both | Both |
| Notification | Admin email / Slack webhook / None | Admin email + Slack |
| Auto-pull on PhishAlarm report | Enable / Disable | Enable — immediately removes confirmed phish from all inboxes |

### 6.5 TRAP False Positive Recovery

If TRAP pulls a legitimate message:
1. **TRAP → Activity Log → find the pull event**
2. Identify the message ID and affected users
3. Recover messages from Deleted Items in M365 EAC (if pull action = Move to Deleted Items):
   - **EAC → Recipients → Mailboxes → [user] → Manage email apps → Deleted Items** or use PowerShell
4. Document the false positive and review the TAP verdict that triggered the pull

---

## 7. Quarantine Administration

### 7.1 Admin Quarantine Search

1. **Email Protection → Quarantine**
2. Search filters: From, To, Subject, Message-ID, Reason, Date range
3. Actions: Release, Release and mark as not spam, Discard, Report as false positive

### 7.2 Bulk Quarantine Actions

For large-scale releases (e.g. after a policy change incorrectly quarantined a batch of messages):
1. Search with broad filter (e.g. From domain + date range)
2. Select all results
3. **Bulk release** — Proofpoint delivers all selected messages

### 7.3 Quarantine Retention

Default quarantine retention is 14 days — messages are automatically deleted after this period. To adjust:
- **Email Protection → Spam → Quarantine Settings → Retention period**

### 7.4 Digest Configuration

| Setting | Location | Notes |
|---|---|---|
| Digest frequency | Email Protection → End User Settings → Digest Schedule | Daily/twice daily/weekly |
| Digest sender address | Email Protection → End User Settings → Digest From Address | Set to a recognisable domain to reduce users marking digest as spam |
| Included categories | Email Protection → End User Settings → Digest Content | Include: spam, bulk; Exclude: phishing, malware (admin review required) |
| Allow user opt-out | Email Protection → End User Settings | Allow / Deny |

---

## Related

- [End User Guide](end-user-guide.md) — User-facing procedures for URL Defence, quarantine, and phishing reporting.
- [MSP Guide](msp-guide.md) — Client onboarding, health checks, and tenant management.
- [Proofpoint TAP API Pipeline](../../api/proofpoint/README.md) — Ingest TAP threat events into Microsoft Sentinel.
- [Data Security Workbench](data-security-workbench/README.md) — ITM/DLP event schema and administration.
- [BEC Incident Response Playbook](../../../../../incident-response/business-email-compromise-playbook.md) — Response procedures for BEC and phishing incidents.
