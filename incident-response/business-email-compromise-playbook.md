# Business Email Compromise Playbook

**Scenario:** A corporate email account is used by a threat actor to commit financial fraud, redirect payments, create forwarding rules to exfiltrate data, or impersonate an executive. Detected via Proofpoint TAP alerts, anomalous mailbox audit events, or analyst/user reports of suspicious outgoing mail.

**Severity:** High–Critical
**Target containment time:** 30 minutes from detection

**ISO 27001:2022 Controls:** A.5.14 · A.5.24 · A.5.25 · A.5.26 · A.5.27 · A.5.28 · A.6.8 · A.8.12 · A.8.23
**CIA Impact:** Confidentiality — High | Integrity — High | Availability — Low

---

## 1. Detection

### Alert Triggers

| Source | Indicator |
|---|---|
| Proofpoint TAP | `BEC indicator — display name spoofing of executive` |
| Proofpoint TAP | `Outbound email with payment or wire transfer language` |
| Microsoft Sentinel | `Mailbox forwarding rule created to external address` |
| Microsoft Sentinel | `Mass outbound email from user account — abnormal volume` |
| Microsoft Entra ID | `Sign-in to OWA from new country + inbox rule created in same session` |
| Microsoft Defender | `Suspicious inbox rule created via PowerShell` |
| Microsoft Sentinel | `OAuth app with Mail.ReadWrite granted by user consent` |
| Finance / user-reported | `Received payment change request from executive — unverified` |
| Finance / user-reported | `Vendor notified that bank account details have changed` |

### Key KQL — Mailbox Forwarding Rule Created

```kql
CloudAppEvents
| where TimeGenerated > ago(7d)
| where ActionType in (
    "New-InboxRule", "Set-InboxRule",
    "UpdateInboxRules", "Set-Mailbox"
  )
| where RawEventData has_any ("ForwardTo", "RedirectTo", "ForwardAsAttachmentTo")
| extend Actor = tostring(AccountDisplayName)
| extend RuleDetails = tostring(RawEventData)
| project TimeGenerated, Actor, AccountObjectId, ActionType, RuleDetails, IPAddress
| order by TimeGenerated desc
```

### Key KQL — Outbound Mail Volume Spike

```kql
EmailEvents
| where TimeGenerated > ago(24h)
| where EmailDirection == "Outbound"
| summarize OutboundCount = count() by SenderFromAddress, bin(TimeGenerated, 1h)
| where OutboundCount > 50 // adjust threshold to baseline
| order by OutboundCount desc
```

### Key KQL — Sign-In to OWA Followed by Inbox Rule Creation

```kql
let OWALogins = SigninLogs
    | where TimeGenerated > ago(48h)
    | where AppDisplayName == "Office 365 Exchange Online"
    | where ClientAppUsed == "Browser"
    | where ResultType == 0
    | project LoginTime = TimeGenerated, UPN = UserPrincipalName,
              IPAddress, CountryOrRegion = tostring(LocationDetails.countryOrRegion);
CloudAppEvents
| where TimeGenerated > ago(48h)
| where ActionType in ("New-InboxRule", "Set-InboxRule")
| where RawEventData has_any ("ForwardTo", "RedirectTo")
| extend UPN = tostring(AccountDisplayName)
| join kind=inner OWALogins on UPN
| where TimeGenerated between (LoginTime .. (LoginTime + 1h))
| project TimeGenerated, UPN, IPAddress, CountryOrRegion, ActionType
```

### Key KQL — OAuth Application Consent Granting Mail Access

```kql
AuditLogs
| where TimeGenerated > ago(30d)
| where OperationName == "Consent to application"
| extend Actor = tostring(InitiatedBy.user.userPrincipalName)
| extend AppName = tostring(TargetResources[0].displayName)
| extend Permissions = tostring(TargetResources[0].modifiedProperties)
| where Permissions has_any ("Mail.ReadWrite", "Mail.Read", "MailboxSettings.ReadWrite")
| project TimeGenerated, Actor, AppName, Permissions
| order by TimeGenerated desc
```

---

## 2. Triage

### Immediate Questions

1. Has a forwarding or redirect rule been created — where is mail being sent?
2. Has the account sign-in originated from an unrecognised IP or country?
3. Was MFA enforced at sign-in? Was it satisfied by the legitimate user or bypassed?
4. Has the attacker sent emails impersonating the account owner to internal or external parties?
5. Has the Finance team been contacted — has any payment or banking change been requested?
6. Were any OAuth applications consented to in the same session?
7. Was the account used to access SharePoint, OneDrive, or Teams — not just email?

### Log Sources to Review

| Source | What to look for |
|---|---|
| Microsoft 365 Unified Audit Log | Inbox rules, mail read/send events, delegation changes |
| Entra ID Sign-in Logs | Login time, IP, MFA result, device, Conditional Access outcome |
| Proofpoint TAP | Outbound BEC indicators, phishing delivery records to internal users |
| Exchange Online Message Trace | All mail sent from the account in the incident window |
| CloudAppEvents (Defender) | App consent grants, OAuth token issuance |

### Severity Classification

| Condition | Severity |
|---|---|
| Fraudulent payment request sent — transaction potentially executed | Critical |
| Forwarding rule active — unknown volume of mail already exfiltrated | Critical |
| Executive account compromised — BEC targeting board or finance | Critical |
| OAuth app with Mail.ReadWrite consent granted to unknown app | High |
| Account accessed from anomalous location, no forwarding rule confirmed | High |
| Forwarding rule created but no mail yet forwarded | High |
| Suspicious outbound volume — no financial request confirmed | Medium |

---

## 3. Containment

### Email Account Containment

```powershell
# Requires Microsoft.Graph and ExchangeOnline modules
Connect-MgGraph -Scopes "User.ReadWrite.All"
Connect-ExchangeOnline -UserPrincipalName security@corp.onmicrosoft.com

$upn = "j.smith@corp.onmicrosoft.com"
$userId = (Get-MgUser -Filter "userPrincipalName eq '$upn'").Id

# Step 1: Revoke all active sessions immediately
Invoke-MgInvalidateUserRefreshToken -UserId $userId
Write-Host "Sessions revoked for $upn"

# Step 2: Disable account
Update-MgUser -UserId $userId -AccountEnabled:$false
Write-Host "Account disabled for $upn"

# Step 3: Remove all inbox rules
Get-InboxRule -Mailbox $upn | Remove-InboxRule -Confirm:$false
Write-Host "All inbox rules removed for $upn"

# Step 4: Disable external forwarding at the mailbox level
Set-Mailbox -Identity $upn -DeliverToMailboxAndForward $false -ForwardingAddress $null -ForwardingSmtpAddress $null
Write-Host "Forwarding disabled for $upn"
```

- [ ] Alert Finance and executive leadership immediately — do not wait for full investigation
- [ ] If a payment was requested: contact the relevant bank and request a recall or freeze
- [ ] Block any external email addresses identified in forwarding rules at Proofpoint or EOP
- [ ] Revoke all OAuth application consents granted during the incident window

```powershell
# Revoke an OAuth application consent
Connect-MgGraph -Scopes "Application.ReadWrite.All"
$servicePrincipalId = "<ObjectId of the app>"
Remove-MgServicePrincipalOAuth2PermissionGrant -ServicePrincipalId $servicePrincipalId
```

---

## 4. Investigation

### Mailbox Audit — Reconstruct What Was Accessed

```powershell
# Get mailbox audit log — what the attacker read, sent, or forwarded
Search-MailboxAuditLog `
    -Identity "j.smith@corp.onmicrosoft.com" `
    -StartDate (Get-Date).AddDays(-7) `
    -EndDate (Get-Date) `
    -LogonTypes Delegate, Admin, Owner `
    -Operations "SendAs", "SendOnBehalf", "MailItemsAccessed", "Create", "Update" `
    -ResultSize 1000 |
    Select-Object LastAccessed, LogonUserDisplayName, Operation, FolderPath, Subject |
    Export-Csv -Path ".\mailbox-audit-bec.csv" -NoTypeInformation
```

### Exchange Online Message Trace — Outbound Mail

```powershell
# Trace all mail sent from the account in the incident window
Get-MessageTrace `
    -SenderAddress "j.smith@corp.onmicrosoft.com" `
    -StartDate (Get-Date).AddDays(-7) `
    -EndDate (Get-Date) `
    -PageSize 1000 |
    Select-Object Received, SenderAddress, RecipientAddress, Subject, Status |
    Export-Csv -Path ".\message-trace-bec.csv" -NoTypeInformation
```

### Proofpoint TAP Investigation

In the Proofpoint TAP console:
- Navigate to **Threat Insight > People** — check if the compromised user is a Very Attacked Person (VAP)
- Navigate to **Threat Insight > Messages** — review inbound messages delivered to this user in the 7 days prior to compromise
- Look for the phishing email that likely preceded the BEC — extract sender, URL, or attachment IOCs
- Export the TAP forensics report for evidence

### Identify Scope of Mail Exfiltration

```kql
// Estimate how much mail was forwarded externally if a rule was active
CloudAppEvents
| where TimeGenerated > ago(7d)
| where ActionType == "MailItemsAccessed"
| where AccountDisplayName == "j.smith@corp.onmicrosoft.com"
| summarize AccessCount = count(), FirstAccess = min(TimeGenerated), LastAccess = max(TimeGenerated)
    by IPAddress, ApplicationId
| order by AccessCount desc
```

---

## 5. Eradication and Recovery

### Remediation Checklist

- [ ] All forwarding and inbox rules removed from the compromised mailbox
- [ ] Account credential reset — complex password, new MFA device registration
- [ ] All OAuth application consents revoked and reviewed
- [ ] External forwarding disabled globally at the tenant level (if not already):

```powershell
# Block all external auto-forwarding at the organisation level
Set-TransportRule -Name "Block External Auto-Forward" `
    -SentToScope NotInOrganization `
    -AutoForwardEnabled $false `
    -Enabled $true
```

- [ ] Finance team debriefed — any fraudulent payment requests documented and actioned
- [ ] All vendors or external parties who received suspicious mail from this account notified
- [ ] Proofpoint TAP report run on the preceding 30 days — check for any additional phishing that preceded BEC
- [ ] All emails sent from the compromised account during the incident window reviewed and recipients notified as required

### If a Fraudulent Transfer Occurred

- [ ] Contact the originating bank within 1–2 hours — SWIFT recall or Fedwire reversal window is time-critical
- [ ] Notify executive leadership and legal counsel
- [ ] Engage cyber insurance carrier if applicable
- [ ] Contact Australian Cyber Security Centre (ACSC) — BEC over $25,000 threshold requires reporting
- [ ] Preserve all evidence before any system remediation

---

## 6. Post-Incident

### Stakeholder Communication Template

> **Security Incident — Business Email Compromise: [User Name] — [Date]**
>
> We have detected and responded to a business email compromise affecting the account of [user name]. An unauthorised party accessed this account at approximately [time] and [created forwarding rules / sent emails impersonating the account holder].
>
> **Immediate actions taken:** The account was secured and all active sessions terminated. All mail forwarding rules have been removed. [Finance / external parties] have been notified.
>
> **What you may have received:** If you received an email from [user name] on [date] requesting [payment details / file access / credentials], please do not act on it. Contact [security team contact] to verify legitimacy of any requests.
>
> **What we need from you:** If you received or acted on a suspicious request from this account, please reply to this message immediately.

### Evidence to Preserve

| Artefact | Retention | Location |
|---|---|---|
| Mailbox audit log export (CSV) | 7 years | Incident evidence store |
| Message trace export (CSV) | 7 years | Incident evidence store |
| Inbox rules configuration at time of discovery | 7 years | Incident evidence store |
| Entra ID sign-in log export for incident window | 7 years | Incident evidence store |
| Proofpoint TAP forensics report | 7 years | Incident evidence store |
| OAuth consent records | 7 years | Incident evidence store |
| Financial transaction records (if applicable) | Per legal/finance retention | Finance records system |

### ISMS Obligations (ISO 27001:2022)

| Obligation | Control | Action |
|---|---|---|
| Record incident in information security incident register | A.5.27 | Log within 24 hours — include scope of mail exfiltration and financial impact |
| Report information security event to relevant stakeholders | A.6.8 | Notify Finance, Legal, executive leadership within 1 hour of BEC confirmation |
| Assess information transfer controls — were DLP or external forwarding controls in place? | A.5.14 | Document whether outbound filtering or transport rules were configured and whether they functioned |
| Assess DLP policy coverage | A.8.12 | Determine whether Proofpoint or Purview DLP would have detected the exfiltration path |
| Preserve evidence with chain-of-custody documentation | A.5.28 | Document all evidence collected, when, and by whom |
| Assess whether a personal data breach occurred | A.5.26 | If customer or employee PII was accessible in the forwarded mail, initiate Privacy Act breach assessment |
| Conduct lessons-learned | A.5.27 | Review within 5 business days; update email security controls and user awareness training |
| Assess whether phishing-resistant MFA would have prevented the initial access | A.5.26 | Document whether hardware key (FIDO2) or certificate-based auth was available |

### Lessons-Learned Review

- How did the attacker gain initial access — was this via a phishing email? Was it caught by Proofpoint before delivery?
- Was MFA enforced on the Outlook Web Access session — was it satisfied by the legitimate user or bypassed?
- Was external auto-forwarding blocked at the transport rule level before this incident?
- Were Conditional Access policies enforcing approved device or location requirements for OWA access?
- Did Finance have a verbal verification process for payment change requests — was it followed?
- Would phishing-resistant MFA (FIDO2 / passkey) have prevented the session hijack?

---

## Related

- Phishing investigation (likely precursor) → [phishing-investigation-playbook.md](phishing-investigation-playbook.md)
- Account compromise → [account-compromise-playbook.md](account-compromise-playbook.md)
- Data exfiltration → [data-exfiltration-response-playbook.md](data-exfiltration-response-playbook.md)
- Proofpoint TAP guides → `../reference/email-security/guides/proofpoint/`
- Proofpoint API reference → `../reference/email-security/api/proofpoint/`
- Conditional Access policies → `../reference/identity-access/policies/conditional-access/`
