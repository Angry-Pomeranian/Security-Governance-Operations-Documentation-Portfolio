# Phishing Investigation Playbook

**Scenario:** User-reported phishing, spear-phishing, credential harvesting pages, malicious attachments, or business email compromise (BEC) attempts identified via Proofpoint TAP or Microsoft Defender.

**Severity:** Medium–High (escalates to High if credential capture confirmed)
**Target triage time:** 2 hours from report

---

## 1. Detection

### Alert Triggers

| Source | Indicator |
|---|---|
| Proofpoint TAP | `Malicious URL click detected` |
| Proofpoint TAP | `Malicious attachment delivered` |
| Proofpoint TAP | `Very Attacked Person (VAP) targeted` |
| Microsoft Defender | `Phishing email detected and quarantined` |
| Microsoft Sentinel | `User clicked known phishing URL` |
| Microsoft Entra ID | `Sign-in from credential harvesting infrastructure` |
| User-reported | `Suspicious email / unexpected password reset request` |

### Key KQL — URL Click After Delivery

```kql
EmailUrlInfo
| join kind=inner (
    UrlClickEvents
    | where TimeGenerated > ago(24h)
    | where ActionType == "ClickAllowed"
) on Url
| project TimeGenerated, RecipientEmailAddress, Url, IPAddress, IsClickedThrough
| where IsClickedThrough == true
```

### Key KQL — Phishing Followed by Successful Sign-In

```kql
let PhishingClick = UrlClickEvents
    | where TimeGenerated > ago(24h)
    | where ActionType == "ClickAllowed"
    | project ClickTime = TimeGenerated, AccountUpn;
SigninLogs
| join kind=inner PhishingClick on $left.UserPrincipalName == $right.AccountUpn
| where TimeGenerated between (ClickTime .. (ClickTime + 1h))
| where ResultType == 0
| project TimeGenerated, UserPrincipalName, IPAddress, ClickTime
```

---

## 2. Triage

### Immediate Questions

1. Was the email delivered, or was it quarantined before delivery?
2. Did the user click any links or open any attachments?
3. Did the user enter credentials on a linked page?
4. Has MFA been challenged since the click? Was it successful?
5. Is this a targeted attack (named user/executive) or bulk phishing?
6. Have other users in the organisation received the same email?

### Scope — Same-Campaign Recipients

```kql
EmailEvents
| where TimeGenerated > ago(48h)
| where SenderFromAddress == "attacker@domain.tld"
    or Subject contains "Invoice #" // adapt to campaign
| summarize RecipientCount = count(), Recipients = make_set(RecipientEmailAddress)
```

### Severity Escalation Triggers

| Condition | Escalate to |
|---|---|
| User entered credentials | High — initiate account compromise playbook |
| Executive or finance team targeted (BEC) | High — notify management immediately |
| Malware executed on endpoint | High — initiate endpoint isolation |
| Multiple users across the organisation affected | High — treat as campaign |

---

## 3. Containment

### Email Containment

- [ ] Identify all mailboxes that received the phishing email
- [ ] Remove the email from all mailboxes using Microsoft Purview soft-delete:

```powershell
# Remove phishing email from all mailboxes
New-ComplianceSearch -Name "PhishingRemoval" -ExchangeLocation All `
    -ContentMatchQuery 'Subject:"[Phishing Subject]" AND From:"attacker@domain.tld"'
Start-ComplianceSearch -Identity "PhishingRemoval"
New-ComplianceSearchAction -SearchName "PhishingRemoval" -Purge -PurgeType SoftDelete
```

- [ ] Block the sender domain/IP in Proofpoint or Exchange Online Protection
- [ ] Submit the URL to Microsoft for analysis (report phishing)
- [ ] Block the phishing URL at Cisco Umbrella DNS layer

### If Credential Capture Confirmed

- [ ] Immediately initiate the [Account Compromise Playbook](account-compromise-playbook.md)
- [ ] Revoke sessions and reset password before continuing this investigation

### Endpoint Containment (if Attachment Executed)

- [ ] Network-contain the affected endpoint in CrowdStrike Falcon
- [ ] Preserve memory and process telemetry before any remediation

---

## 4. Investigation

### Email Header Analysis

Key headers to extract and review:

| Header | Purpose |
|---|---|
| `Return-Path` | Actual sending address (may differ from From:) |
| `Received` chain | Mail routing path — identify origin IP |
| `X-Originating-IP` | Original sender IP |
| `Authentication-Results` | SPF, DKIM, DMARC pass/fail |
| `X-MS-Exchange-Organization-SCL` | Microsoft spam confidence level |

### Phishing URL Analysis

- Screenshot the phishing page (do not submit credentials)
- Extract page source for indicators of compromise (IOCs)
- Check hosting infrastructure: IP, registrar, creation date, hosting provider
- Query VirusTotal and URLVoid for reputation
- Check if the URL is a legitimate service being abused (Dropbox, Google Docs, SharePoint link)

### Attachment Analysis

If a malicious attachment was opened:

| Analysis step | Tool/approach |
|---|---|
| Hash the file (MD5, SHA256) | Compare against VirusTotal |
| Static analysis | File type, embedded macros, embedded URLs |
| Sandbox detonation | Observe behaviour in isolated environment |
| CrowdStrike telemetry | What processes did the attachment spawn? |

### Proofpoint TAP Forensics

In Proofpoint TAP console:
- Review the Threat Detail for the message
- Extract all URLs, attachment hashes, and threat classifications
- Check if the sender is a known threat actor or campaign
- Export the TAP forensics report for documentation

---

## 5. Eradication and Recovery

### Remediation Checklist

- [ ] Phishing email removed from all affected mailboxes
- [ ] Sender blocked at email gateway and DNS layer
- [ ] Phishing URL blocked at proxy and DNS layer
- [ ] Any malicious attachments quarantined or deleted from endpoints
- [ ] Affected user accounts secured (if credentials entered — see account compromise playbook)
- [ ] User briefed on what happened and what was done

### If BEC Attempted

- [ ] Review outgoing email from affected account for the past 7 days
- [ ] Check for inbox rules forwarding mail to external addresses
- [ ] Notify Finance team — verify no fraudulent payment requests were sent or approved
- [ ] If fraudulent transfer occurred — notify management immediately, engage legal/finance

---

## 6. Post-Incident

### User Communication Template

> Hi [Name],
>
> We've investigated the suspicious email you reported. [The email was / contained] a phishing attempt designed to [steal your credentials / install malware / impersonate a colleague].
>
> **What we've done:** The email has been removed from all mailboxes. The sender and associated links have been blocked.
>
> **What you need to do:** [No action required — your account is safe. / Please change your password now using [link] and re-enrol your MFA device.]
>
> Thank you for reporting this — your quick action helped protect the organisation.

### Indicators of Compromise to Share

Document IOCs for threat intelligence sharing:

| IOC Type | Value |
|---|---|
| Sender address | `attacker@domain.tld` |
| Sender IP | `x.x.x.x` |
| Phishing URL | `https://...` |
| Attachment hash (SHA256) | `abc123...` |
| Malware family | If identified |

### Documentation Requirements

- [ ] Email headers and metadata preserved
- [ ] List of all recipients and whether they clicked/opened
- [ ] Credential capture confirmed or ruled out
- [ ] IOC list compiled and shared with threat intelligence platform
- [ ] User notification sent
- [ ] Recommendations for awareness training or policy improvement

### Lessons-Learned Review

- Did DMARC, SPF, and DKIM fail — and if so, why was the email delivered?
- Did Proofpoint TAP detect the threat before or after delivery?
- Was the phishing URL pre-detonated by sandboxing at delivery time?
- Would phishing-resistant MFA (FIDO2/passkey) have prevented credential use?
- Should this user be targeted for additional security awareness training?

---

## Related

- Account compromise → [account-compromise-playbook.md](account-compromise-playbook.md)
- Proofpoint TAP reference → `../reference/email-security/api/proofpoint/`
- Email security guides → `../reference/email-security/guides/proofpoint/`
