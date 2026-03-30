# Data Exfiltration Response Playbook

**Scenario:** Suspected or confirmed unauthorised transfer of organisational data — triggered by DLP policy alerts, anomalous upload volumes, cloud storage alerts, or post-compromise exfiltration as part of a ransomware or APT operation.

**Severity:** High–Critical
**Target containment time:** 1 hour from confirmed detection

---

## 1. Detection

### Alert Triggers

| Source | Indicator |
|---|---|
| Proofpoint Data Security Workbench | `DLP policy violation — sensitive data in outbound email` |
| Microsoft Purview DLP | `Credit card / PII / confidential label detected in upload` |
| Microsoft Sentinel | `Anomalous volume of data uploaded to external cloud storage` |
| Microsoft Sentinel | `Mass download from SharePoint followed by external sharing` |
| CrowdStrike Falcon | `Sensitive file staging in temp directory before upload` |
| Microsoft Defender for Cloud Apps | `Impossible travel + large download session` |
| Microsoft Defender for Cloud Apps | `OAuth app exfiltrating data via Graph API` |
| User-reported | `Colleague behaviour — unexplained large file downloads` |

### Key KQL — Anomalous SharePoint Download Volume

```kql
OfficeActivity
| where TimeGenerated > ago(24h)
| where Operation in ("FileDownloaded", "FileAccessed")
| summarize DownloadCount = count(), BytesTotal = sum(OfficeObjectId)
    by UserId, bin(TimeGenerated, 1h)
| where DownloadCount > 500
| order by DownloadCount desc
```

### Key KQL — External Sharing Events

```kql
OfficeActivity
| where TimeGenerated > ago(7d)
| where Operation in ("SharingInvitationCreated", "AnonymousLinkCreated")
| where TargetUserOrGroupType == "Guest" or TargetUserOrGroupName has_any ("gmail.com", "hotmail.com", "protonmail.com")
| project TimeGenerated, UserId, Operation, ItemType, SourceFileName, TargetUserOrGroupName
```

### Key KQL — Large Email Attachment Sent Externally

```kql
EmailEvents
| where TimeGenerated > ago(24h)
| where EmailDirection == "Outbound"
| where RecipientEmailAddress !endswith "@yourcompany.com"
| where AttachmentCount > 0
| where tolong(parse_json(EmailDetails).TotalSize) > 10485760  // 10MB
| project TimeGenerated, SenderFromAddress, RecipientEmailAddress, Subject, AttachmentCount
```

---

## 2. Triage

### Immediate Questions

1. What data was accessed or transferred? (Classification level, volume, file types)
2. Who is the subject — insider threat or external attacker using compromised credentials?
3. What destination was the data sent to? (Personal email, cloud storage, USB, C2 server?)
4. Is this an isolated event or part of a pattern over time?
5. Is the account still active and is exfiltration ongoing?

### Data Classification Assessment

| Data type | Regulatory implication |
|---|---|
| Personal information (names, DOB, addresses) | Australian Privacy Act — Notifiable Data Breaches |
| Health information | Privacy Act — sensitive information, heightened protections |
| Financial data (card numbers, account details) | PCI-DSS, APRA CPS 234 (financial sector) |
| Credentials or secrets | Immediate account compromise risk |
| Commercially sensitive / IP | Legal/contractual obligations |
| Government-classified | Mandatory reporting obligations |

### Determine Transfer Method

| Method | Detection approach |
|---|---|
| Email attachment | Exchange audit logs, Proofpoint DLP |
| Cloud upload (OneDrive, Dropbox, Google Drive) | Microsoft Defender for Cloud Apps |
| USB device | CrowdStrike Falcon device control logs |
| Web upload | Proxy/CASB logs, CrowdStrike network telemetry |
| C2 channel (post-compromise) | CrowdStrike Falcon, Sentinel network analytics |
| Print/screenshot | More difficult — look for DLP endpoint print policy hits |

---

## 3. Containment

### Immediate Actions

- [ ] If exfiltration is active — terminate the session: revoke tokens, block the destination IP/domain
- [ ] If insider threat — do not alert the subject; coordinate with HR and Legal before any action
- [ ] If compromised account — initiate [Account Compromise Playbook](account-compromise-playbook.md) simultaneously
- [ ] Block the destination (cloud storage domain, external email) at proxy and DNS layer
- [ ] Preserve all log data — do not delete or alter evidence

### If USB / Removable Media

- [ ] CrowdStrike Falcon — isolate the endpoint
- [ ] Request physical recovery of the USB device if possible (coordinate with HR/Legal)
- [ ] Forensic image of the endpoint before any remediation

### If Ongoing — Prevent Further Transfer

- [ ] Apply DLP block policy via Microsoft Purview for the affected user
- [ ] Restrict the user's ability to share externally in SharePoint
- [ ] Disable personal cloud storage access via Conditional Access app restriction

---

## 4. Investigation

### Evidence to Collect

| Evidence | Source | Notes |
|---|---|---|
| Full audit log for the user (90 days) | Microsoft Purview Audit | Export immediately — log retention limits apply |
| DLP policy match details | Proofpoint DSW / Purview DLP | Includes matched content type and rule |
| File inventory accessed/downloaded | SharePoint audit | Identify exactly what was taken |
| Network traffic logs | Proxy/CASB/firewall | Volume, destination, protocol |
| Endpoint telemetry | CrowdStrike Falcon | Process that initiated transfer |
| Browser history (if insider) | CrowdStrike RTR | Corroborate upload activity |
| Physical access logs | If USB or printing involved | Building security records |

### Reconstruct the Exfiltration Timeline

```kql
OfficeActivity
| where UserId == "user@domain.com"
| where TimeGenerated between (datetime(2025-01-01) .. datetime(2025-01-31))
| where Operation in (
    "FileDownloaded", "FileAccessed", "FileCopied",
    "SharingInvitationCreated", "AnonymousLinkCreated",
    "FileUploaded", "FolderMoved"
  )
| order by TimeGenerated asc
| project TimeGenerated, Operation, SourceFileName, SourceRelativeUrl
```

### Quantify What Was Taken

Document for each exfiltrated item:
- File name and path
- Data classification (if labelled)
- File size
- Whether it contains personal information, credentials, or IP
- Destination it was sent to

---

## 5. Eradication and Recovery

### Data Containment at Destination

- [ ] If sent to personal email — request deletion (insider) or assess recoverability
- [ ] If uploaded to cloud storage — request takedown via legal letter if necessary
- [ ] If posted publicly — engage legal team; document and preserve the exposure
- [ ] Notify affected customers/individuals if their personal data was included

### Account and System Remediation

- [ ] Reset compromised account credentials
- [ ] Revoke all active sessions and OAuth tokens
- [ ] Remove any persistence (if external attacker)
- [ ] Re-apply DLP controls and verify they are functioning
- [ ] Review and tighten sharing permissions that allowed the transfer

### Regulatory Notification Assessment

| Trigger | Action |
|---|---|
| Personal data of Australian individuals exfiltrated | Assess Notifiable Data Breaches scheme — notify OAIC within 30 days if likely to result in serious harm |
| Credit card data included | Notify relevant card schemes; PCI-DSS breach reporting obligations apply |
| Government data | Notify relevant government agency per contract/data sharing agreement |
| Health data | Privacy Act sensitive data — heightened notification consideration |

---

## 6. Post-Incident

### Customer Communication Template

> **Summary:** A data security incident was identified on [date] involving [description — e.g., unauthorised access to and transfer of files from the SharePoint environment]. The transfer occurred between [start] and [end date/time].
>
> **Data involved:** [Description — e.g., approximately X files containing [data type]. Personal data of [X] individuals may have been included.]
>
> **Containment actions:** Access revoked, transfer method blocked, affected data inventoried.
>
> **Regulatory status:** [Notifiable Data Breaches assessment underway / OAIC notification submitted / No notification required.]
>
> **Recommendations:** [Enhanced DLP policies / Conditional Access restrictions on external sharing / Insider threat monitoring controls]

### Documentation Requirements

- [ ] Full timeline of access, download, and transfer events
- [ ] Inventory of all files/data accessed or exfiltrated
- [ ] Identity of the actor (insider / external attacker / compromised account)
- [ ] Transfer method and destination documented
- [ ] Volume and classification of data affected
- [ ] Regulatory notification obligations assessed and actioned
- [ ] Evidence preserved with chain of custody

### Lessons-Learned Review

- Were DLP policies configured to detect this data type and transfer method?
- Were data sensitivity labels applied to the exfiltrated files?
- Did CASB/proxy controls provide visibility into the destination?
- Was this an insider threat that could have been detected earlier through behavioural analytics?
- Were Conditional Access policies restricting unmanaged device access to sensitive data?

---

## Related

- Account compromise → [account-compromise-playbook.md](account-compromise-playbook.md)
- Ransomware response → [ransomware-response-playbook.md](ransomware-response-playbook.md) (double extortion)
- Proofpoint Data Security Workbench → `../reference/email-security/guides/proofpoint/data-security-workbench/`
- ASD Essential Eight — Regular Backups → `../compliance/asd-essential-eight/`
