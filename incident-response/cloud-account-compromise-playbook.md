# Cloud Account Compromise Playbook

**Scenario:** Unauthorised access to cloud infrastructure accounts — including AWS root account usage, IAM credential abuse, access key theft, or suspicious API activity correlated with GuardDuty findings and CloudTrail telemetry in Microsoft Sentinel.

**Severity:** High–Critical
**Target containment time:** 1 hour from detection

**ISO 27001:2022 Controls:** A.5.23 · A.5.24 · A.5.25 · A.5.26 · A.5.27 · A.5.28 · A.8.15 · A.8.16
**CIA Impact:** Confidentiality — High | Integrity — High | Availability — High

---

## 1. Detection

### Alert Triggers

| Source | Indicator |
|---|---|
| AWS GuardDuty | `UnauthorizedAccess:IAMUser/ConsoleLoginSuccess.B` |
| AWS GuardDuty | `Policy:IAMUser/RootCredentialUsage` |
| AWS GuardDuty | `Recon:IAMUser/UserPermissions` |
| AWS GuardDuty | `CredentialAccess:IAMUser/AnomalousBehavior` |
| Microsoft Sentinel | GuardDuty finding ingested via Sentinel AWS connector |
| Microsoft Sentinel | `Root account login detected` (CloudTrail analytics rule) |
| Microsoft Sentinel | CloudTrail IAM policy change outside change window |
| AWS CloudTrail | Console login from new IP, country, or user-agent |
| AWS CloudTrail | `CreateAccessKey`, `AttachUserPolicy`, `CreateUser` outside of approved change process |

### Key KQL — Root Account Usage

```kql
AWSCloudTrail
| where TimeGenerated > ago(24h)
| where UserIdentityType == "Root"
| where EventName != "GetSessionToken"
| project TimeGenerated, EventName, SourceIpAddress, UserAgent, AWSRegion, ErrorCode
| order by TimeGenerated desc
```

### Key KQL — IAM Privilege Escalation

```kql
AWSCloudTrail
| where TimeGenerated > ago(24h)
| where EventName in (
    "AttachUserPolicy", "AttachRolePolicy", "AttachGroupPolicy",
    "PutUserPolicy", "PutRolePolicy", "CreateAccessKey",
    "CreateUser", "AddUserToGroup", "UpdateAssumeRolePolicy"
  )
| project TimeGenerated, EventName, UserIdentityArn, SourceIpAddress, RequestParameters, AWSRegion
| order by TimeGenerated desc
```

### Key KQL — GuardDuty Findings via Sentinel

```kql
AWSGuardDuty
| where TimeGenerated > ago(48h)
| where Severity >= 7
| project TimeGenerated, FindingType, Severity, AccountId, Region,
          UserIdentityArn = tostring(ServiceAction.awsApiCallAction.remoteIpDetails),
          Description
| order by Severity desc, TimeGenerated desc
```

### Key KQL — Cross-Source: CloudTrail + Entra ID Sign-In Correlation

```kql
// Detect same user logging into AWS and Entra ID from different countries within 1 hour
let AWSLogins = AWSCloudTrail
    | where TimeGenerated > ago(2h)
    | where EventName == "ConsoleLogin"
    | where isnotempty(SourceIpAddress)
    | project AWSLoginTime = TimeGenerated, UserIdentityArn, AwsIP = SourceIpAddress;
SigninLogs
| where TimeGenerated > ago(2h)
| where ResultType == 0
| extend CorpUser = split(UserPrincipalName, "@")[0]
| join kind=inner AWSLogins on $left.CorpUser == $right.UserIdentityArn
| where IPAddress != AwsIP
| project TimeGenerated, UserPrincipalName, AzureIP = IPAddress, AWSLoginTime, AwsIP
```

---

## 2. Triage

### Immediate Questions

1. Was this a root account login or an IAM user/role?
2. What region and service were accessed?
3. Was MFA enforced at login — was it bypassed or not configured?
4. Were any new IAM users, access keys, or roles created?
5. Were any S3 bucket policies, security group rules, or network ACLs changed?
6. Is the source IP a known corporate IP, VPN exit node, or unrecognised?
7. Is this a service account or a human account?

### Log Sources to Review

| Source | What to look for |
|---|---|
| AWS CloudTrail | Event history for the account — IAM changes, resource creation, data access |
| AWS GuardDuty | Active findings — severity 7+ require immediate triage |
| AWS S3 Access Logs | Unusual GET/LIST/PUT — bulk object access or exfiltration |
| VPC Flow Logs | Outbound traffic spikes, unusual destination IPs or ports |
| Microsoft Sentinel | Correlated findings from the AWS connector and Entra ID |
| AWS Config | Infrastructure state changes — security groups, bucket policies |

### Severity Classification

| Condition | Severity |
|---|---|
| Root account login, MFA not enforced | Critical |
| New IAM admin user or access key created | Critical |
| GuardDuty finding Severity 8–10 | Critical |
| S3 bucket policy changed to public or cross-account | Critical |
| IAM policy change during off-hours or from unknown IP | High |
| GuardDuty finding Severity 5–7, no confirmed malicious action | High |
| Recon activity (permission enumeration) only | Medium |

---

## 3. Containment

### Immediate Actions — AWS Console or CLI

```bash
# Deactivate compromised access key immediately
aws iam update-access-key \
  --access-key-id AKIAIOSFODNN7EXAMPLE \
  --status Inactive \
  --user-name compromised-user

# Attach an explicit deny-all policy to the compromised IAM user
aws iam put-user-policy \
  --user-name compromised-user \
  --policy-name EmergencyDenyAll \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [{"Effect": "Deny", "Action": "*", "Resource": "*"}]
  }'

# Revoke all active console sessions for the user
aws iam delete-login-profile --user-name compromised-user

# If root account was used — rotate root MFA and access keys immediately
# Root access keys should not exist — delete them:
aws iam delete-access-key --access-key-id <root-key-id>
```

- [ ] Identify all access keys for the compromised identity and deactivate all
- [ ] Revoke all active sessions (AWS IAM → Security credentials → Revoke sessions)
- [ ] If root account: enable MFA immediately if not already enforced
- [ ] Isolate any EC2 instances or Lambda functions spawned by the compromised identity
- [ ] Notify cloud infrastructure owner and escalate to management

### If New Resources Were Created

- [ ] Document all resources created during the compromise window
- [ ] Do not delete resources until forensic snapshot is taken — preserve evidence
- [ ] Terminate or snapshot EC2 instances for forensic analysis
- [ ] Tag all suspect resources with `incident-hold` to prevent accidental deletion

---

## 4. Investigation

### CloudTrail Forensic Review

Reconstruct the full attacker session:

```bash
# Pull all API calls made by the compromised identity in the incident window
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=Username,AttributeValue=compromised-user \
  --start-time 2026-03-01T00:00:00Z \
  --end-time 2026-03-01T06:00:00Z \
  --output json > cloudtrail-incident-events.json
```

Key events to search in CloudTrail:

| Event | Significance |
|---|---|
| `ConsoleLogin` | Initial access — note IP, MFA result, user-agent |
| `GetCallerIdentity` | Attacker confirming their own permissions |
| `ListBuckets`, `ListObjects` | Reconnaissance of S3 |
| `GetObject` | Data accessed or exfiltrated |
| `CreateUser`, `CreateAccessKey` | Persistence — new credentials created |
| `AttachUserPolicy` / `PutRolePolicy` | Privilege escalation |
| `RunInstances` | Compute resources provisioned (cryptomining, C2) |
| `ModifyInstanceAttribute` | Security group or network changes |

### GuardDuty Deep-Dive

- Navigate to GuardDuty → Findings — filter by the affected account and time window
- Review the full finding detail: affected resource ARN, API call, IP address, user agent
- Export finding to JSON for evidence preservation
- Check if findings are part of a sequence (recon → access → exfiltration)

### VPC Flow Log Analysis (Sentinel)

```kql
AWSVPCFlow
| where TimeGenerated > ago(4h)
| where Action == "ACCEPT"
| where DestinationPort !in (443, 80, 22, 3389)
| summarize BytesSent = sum(Bytes), ConnectionCount = count()
    by SrcAddr, DstAddr, DestinationPort
| where BytesSent > 10000000 // > 10MB — potential exfiltration
| order by BytesSent desc
```

---

## 5. Eradication and Recovery

### Remediation Checklist

- [ ] All compromised credentials deactivated and rotated
- [ ] All new IAM users, roles, access keys, and policies created by attacker deleted
- [ ] All attacker-created resources terminated or quarantined
- [ ] Root account MFA enforced and root access keys confirmed absent
- [ ] AWS Config rules re-evaluated — confirm baseline state
- [ ] S3 bucket policies reviewed and confirmed non-public
- [ ] Security groups and network ACLs reviewed for attacker modifications
- [ ] CloudTrail logging verified as continuous and tamper-evident
- [ ] GuardDuty findings marked as resolved after remediation confirmed

### Post-Compromise Hardening

- [ ] Enable AWS IAM Access Analyzer — flag overly permissive policies
- [ ] Enable AWS Security Hub — centralise findings in Sentinel via connector
- [ ] Enforce MFA for all IAM users via a Service Control Policy (SCP) if using AWS Organisations
- [ ] Remove any unused access keys older than 90 days
- [ ] Enable CloudTrail log file validation to detect tampering

```bash
# Verify CloudTrail log file validation is enabled
aws cloudtrail get-trail --name corp-cloudtrail-main \
  --query 'Trail.LogFileValidationEnabled'
```

---

## 6. Post-Incident

### Stakeholder Communication Template

> **Cloud Security Incident — [Date]**
>
> We identified and contained unauthorised access to our AWS environment. [The root account / IAM user `[name]`] was accessed from an unrecognised IP address at [time].
>
> **Impact:** [Describe what was accessed or changed. If no data exfiltration confirmed, state this explicitly.]
>
> **Actions taken:** Credentials were immediately deactivated. [Any created resources / policy changes] have been reversed. A full audit of the account is underway.
>
> **Next steps:** [MFA enforcement / access key rotation / additional monitoring] will be completed by [date].

### Evidence to Preserve

| Artefact | Retention | Location |
|---|---|---|
| CloudTrail event export (JSON) | 7 years | Incident evidence store |
| GuardDuty finding exports | 7 years | Incident evidence store |
| VPC Flow Log extracts | 7 years | Incident evidence store |
| Sentinel KQL query results | 7 years | Incident evidence store |
| EC2 instance snapshots (if created) | Until investigation closed | AWS Snapshot store |

### ISMS Obligations (ISO 27001:2022)

| Obligation | Control | Action |
|---|---|---|
| Record incident in information security incident register | A.5.27 | Log within 24 hours of detection |
| Assess whether cloud service provider obligations were triggered | A.5.23 | Review AWS Shared Responsibility Model and AWS BAA if applicable |
| Preserve and document evidence chain of custody | A.5.28 | Complete evidence log before any remediation |
| Assess whether a personal data breach occurred | A.5.26 | If PII was in scope, initiate Privacy Act assessment |
| Conduct lessons-learned review | A.5.27 | Schedule within 5 business days of incident closure |
| Assess whether existing controls require update | A.5.27 | Raise corrective action if IAM policy, MFA, or monitoring gaps identified |
| Report to senior management if Critical | A.5.26 | Immediate verbal notification; written summary within 24 hours |

### Lessons-Learned Review

- Was root account MFA enforced at the time of the incident?
- Were access keys older than 90 days present — why were they not rotated?
- Did GuardDuty generate a finding before or after containment — was detection timely?
- Was the Sentinel AWS connector ingesting CloudTrail events in real time?
- Would a Service Control Policy (SCP) have prevented the attacker's privilege escalation?
- Is there a break-glass procedure for root account access — was it followed?

---

## Related

- Account compromise (identity layer) → [account-compromise-playbook.md](account-compromise-playbook.md)
- Data exfiltration response → [data-exfiltration-response-playbook.md](data-exfiltration-response-playbook.md)
- AWS Sentinel connector reference → `../reference/sentinel/manual/aws/`
- AWS CloudTrail troubleshooting → `../reference/sentinel/manual/aws/cloudtrail/`
- AWS telemetry architecture → `../projects/cloud-security/aws-telemetry-onboarding-for-siem.md`
