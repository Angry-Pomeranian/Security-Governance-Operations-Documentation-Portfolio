# Proofpoint — End User Guide

## Overview

This guide answers the most common questions from end users about Proofpoint email security features. Proofpoint sits between the internet and your mailbox — it scans every inbound and outbound message, rewrites URLs, and holds suspicious mail in quarantine before it reaches you.

---

## 1. URL Rewriting — Why Do Links Look Different?

### What you will see

When Proofpoint is active, every URL in inbound email is rewritten to route through Proofpoint's URL Defense service before reaching the destination. A rewritten URL looks like this:

```
https://urldefense.com/v3/__https://example.com/report.pdf__;!!A1234==!xyz
```

The original destination (`example.com/report.pdf`) is encoded inside the link. Proofpoint decodes it, checks the destination in real time, and either passes you through or blocks the page.

### Why this happens

Proofpoint rewrites URLs to:
- Check links at click time, not just at delivery time (phishing sites often go live hours after the email is sent)
- Block links that have turned malicious since the message arrived
- Log click events for security investigation

### What to do when a legitimate link is blocked

1. Check the block page — it will display the original URL and a reason code
2. If you believe the link is safe, contact your IT/security team and provide the original URL shown on the block page
3. Do not try to work around the block by copying the destination URL manually — report it so it can be reviewed and allowlisted correctly

### Links that do not get rewritten

- Links in outbound mail (sent from your mailbox)
- Links in emails that bypass the Proofpoint gateway (internal mail on some configurations)
- Links in calendar invites (configuration-dependent)

---

## 2. Quarantine Digest — What Is It and What Do I Do With It?

### What the digest is

The quarantine digest is an automated email summarising messages that Proofpoint held before delivery. It arrives on a schedule set by your administrator (typically once or twice daily).

Example digest format:

| From | Subject | Received | Reason |
|---|---|---|---|
| vendor@supplier.com | Invoice #4821 | Mon 14:32 | Bulk mail |
| noreply@newsletter.com | Weekly update | Mon 09:10 | Spam |

### Your options for each message

| Action | What it does |
|---|---|
| **Release** | Delivers the message to your inbox now |
| **Release and Allow Sender** | Delivers the message and adds the sender to your safe sender list |
| **Delete** | Permanently removes the message from quarantine |
| **Block Sender** | Deletes the message and blocks future mail from that address |

### When to release vs escalate

- **Release:** You recognise the sender and expected the message (e.g. a newsletter you subscribed to, a vendor invoice)
- **Escalate to IT:** The quarantine reason shows "Malware", "Phishing", or "Virus" — do not release these yourself; contact your IT/security team

### Logging in to quarantine directly

You can access your quarantine without waiting for the digest:
1. Go to the Proofpoint End User Digest portal (URL provided by your administrator — typically `https://enduser.proofpoint.com` or an internal URL)
2. Sign in with your corporate email address
3. Review and action quarantined messages

### If you stopped receiving digests

- Check your Junk/Spam folder in Outlook — the digest may have been misidentified
- Confirm the sender address with your IT team (usually `noreply@{tenantname}.pphosted.com`)
- Confirm your mailbox is in scope for the quarantine digest policy

---

## 3. Safe Senders and Blocked Senders

### Adding a safe sender (allow sender)

Adding a sender to your safe sender list tells Proofpoint to deliver future mail from that address without quarantining it.

**From the quarantine digest:**
- Click **Release and Allow Sender** next to any message from the sender you want to allow

**From the End User portal:**
1. Sign in to the Proofpoint End User portal
2. Go to **Settings → Blocked/Allowed Senders**
3. Click **Add** under the Allowed Senders section
4. Enter the email address or domain (e.g. `vendor@supplier.com` or `@supplier.com` for the whole domain)

**Note:** Your administrator may restrict what can be added to personal safe sender lists. Organisation-level allowlisting for vendors affecting multiple users must be done by an administrator.

### Adding a blocked sender

1. Sign in to the Proofpoint End User portal
2. Go to **Settings → Blocked/Allowed Senders**
3. Click **Add** under the Blocked Senders section
4. Enter the email address or domain

**Note:** Blocking a sender at the user level quarantines future mail from that address. It does not delete mail already in your inbox.

---

## 4. False Positives — Legitimate Mail Getting Blocked

### What is a false positive?

A false positive is a legitimate email that Proofpoint incorrectly identifies as spam, phishing, or malicious and blocks or quarantines.

### Common causes

| Cause | Description |
|---|---|
| New sender domain | Domain has no reputation history (common with new vendors or name-changed companies) |
| Bulk mail classification | Marketing or notification emails from a recognised sender are classified as bulk |
| URL in message body | A legitimate link inside the email resolves to a hosting provider flagged as suspicious |
| SPF/DKIM/DMARC failure | The sender's mail authentication is misconfigured, making the email look spoofed |
| Image-heavy or unusual formatting | HTML-heavy messages match spam patterns |

### What to do

1. **For personal allowlisting:** Release from quarantine and use **Release and Allow Sender**
2. **For persistent false positives from an important vendor:** Contact your IT/security team with:
   - The sender's email address and domain
   - The subject line and approximate delivery time
   - The quarantine reason shown in the digest
3. **For a message that was blocked outright (never appeared in quarantine):** Your administrator can search the Proofpoint message trace log — provide the sender, approximate time, and subject

---

## 5. Reporting a Phishing Email

### Why reporting matters

Reporting phishing emails helps your security team track active campaigns targeting your organisation, update blocklists, and protect other users.

### How to report

**If Proofpoint PhishAlarm is installed (Outlook button):**
1. Open the suspicious email in Outlook (do not click any links)
2. Click the **PhishAlarm** or **Report Phishing** button in the Outlook ribbon
3. A confirmation dialog will appear — click **Report**
4. The email is forwarded to your security team and deleted from your inbox

**If PhishAlarm is not installed:**
1. Do not click any links or attachments in the suspicious email
2. Forward the email as an attachment (not inline) to your IT/security team's designated phishing report address
3. Delete the original email after forwarding

### What happens after you report

1. Your security team reviews the submission
2. If confirmed malicious: the sender/URL/attachment is blocklisted, and TRAP (Threat Response Auto-Pull) may automatically remove the same message from other users' inboxes
3. You may receive confirmation that the report was reviewed (depends on your team's process)

### How to tell if an email is suspicious

| Warning sign | Example |
|---|---|
| Urgent or threatening language | "Your account will be closed in 24 hours" |
| Unexpected attachment from a known sender | Invoice PDF when you weren't expecting one |
| Link hover shows a different domain than the visible text | Text shows `bank.com`, link goes to `bank-login.malicious.com` |
| Request for credentials or sensitive information | "Please confirm your password to verify your account" |
| Sender address does not match the display name | Display: "Microsoft Support", actual address: `support@random-domain.net` |

---

## 6. Sending Encrypted Email

### When to use encryption

Encrypt emails when sending:
- Personal information (tax file numbers, health information, dates of birth)
- Financial data (bank account numbers, payment card data)
- Confidential business documents (contracts, HR matters)
- Anything labelled "Confidential" or "Restricted" under your organisation's classification policy

### How to send an encrypted message

**Option A — Subject line trigger (if configured):**
Add `[ENCRYPT]` or `[SECURE]` to the subject line of your email (exact keyword depends on your organisation's Proofpoint configuration):

```
Subject: [ENCRYPT] Invoice #8821 — Q4 2025
```

Proofpoint will automatically encrypt the message before delivery.

**Option B — Microsoft 365 sensitivity labels (if configured with Proofpoint):**
1. In Outlook, compose your message
2. Click **Sensitivity** in the ribbon
3. Select the appropriate label (e.g. "Confidential", "Highly Confidential")
4. Send as normal — Proofpoint and Microsoft 365 encryption work together

**Option C — Proofpoint Encryption portal:**
Your recipient receives a notification email with a link to the Proofpoint Secure Reader portal. They create a free account (or log in) to read the message. No email client configuration is required on their end.

### What the recipient sees

The recipient receives a notification:
```
You have received a secure message from [Your Name].
To read this message, click the link below:
[View Secure Message]
```

They are prompted to create a Proofpoint account (email address + password) to read the message.

### Limitations

- Encrypted messages cannot be forwarded by the recipient to an unencrypted address
- Attachments inside encrypted messages are also encrypted
- Message expiry can be configured by your administrator (e.g. 30 days)

---

## Related

- [Admin Guide](admin-guide.md) — Administrator configuration for all features described in this guide.
- [Proofpoint TAP API Pipeline](../../api/proofpoint/README.md) — Backend threat event ingestion into Sentinel.
- [BEC Incident Response Playbook](../../../../../incident-response/business-email-compromise-playbook.md) — Response procedures when a phishing email leads to account compromise.
