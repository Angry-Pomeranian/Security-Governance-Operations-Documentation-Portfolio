# Privileged Access Abuse Playbook

**Scenario:** A privileged account — administrator, service account, or Privileged Identity Management (PIM) eligible role — is used outside of approved parameters. Indicators include off-hours admin activity, PIM activations without a corresponding change ticket, bulk permission grants, or admin actions from an unrecognised device or location.

**Severity:** High–Critical
**Target containment time:** 45 minutes from detection

**ISO 27001:2022 Controls:** A.5.15 · A.5.18 · A.5.24 · A.5.25 · A.5.26 · A.5.27 · A.5.28 · A.8.2 · A.8.16
**CIA Impact:** Confidentiality — High | Integrity — Critical | Availability — High

---

## 1. Detection

### Alert Triggers

| Source | Indicator |
|---|---|
| Microsoft Entra ID PIM | `Privileged role activated outside approved hours` |
| Microsoft Entra ID PIM | `Role activation without justification or ticket number` |
| Microsoft Entra ID PIM | `Eligible role permanently assigned (approval bypassed)` |
| Microsoft Sentinel | `Global Administrator role assigned to new user` |
| Microsoft Sentinel | `Admin account sign-in from new country or anonymous IP` |
| Microsoft Sentinel | `Mass Conditional Access policy modification` |
| Microsoft Sentinel | `Service account authenticating interactively` |
| Microsoft Entra ID | `Risky sign-in — High risk — admin account` |
| CrowdStrike Falcon | `Admin credential use on non-PAW device` |
| User-reported | `Unexpected admin action performed — I didn't do this` |

### Key KQL — PIM Activation Outside Business Hours

```kql
AuditLogs
| where TimeGenerated > ago(7d)
| where Category == "RoleManagement"
| where OperationName == "Add eligible member to role"
    or OperationName == "Add member to role (PIM activation)"
| extend ActivationHour = hourofday(TimeGenerated)
| extend ActivationDay = dayofweek(TimeGenerated)
| where ActivationHour !between (7 .. 18) // Outside 7am–6pm
    or ActivationDay in (0, 6)             // Weekend (Sunday=0, Saturday=6)
| extend Actor = tostring(InitiatedBy.user.userPrincipalName)
| extend TargetRole = tostring(TargetResources[0].displayName)
| project TimeGenerated, Actor, TargetRole, ActivationHour, ActivationDay, ResultDescription
```

### Key KQL — New Global Administrator or Privileged Role Assignment

```kql
AuditLogs
| where TimeGenerated > ago(30d)
| where OperationName in (
    "Add member to role",
    "Add eligible member to role",
    "Add scoped member to role"
  )
| extend Actor = tostring(InitiatedBy.user.userPrincipalName)
| extend TargetUser = tostring(TargetResources[0].userPrincipalName)
| extend RoleName = tostring(TargetResources[1].displayName)
| where RoleName in (
    "Global Administrator", "Privileged Role Administrator",
    "Security Administrator", "Exchange Administrator",
    "User Administrator", "Application Administrator"
  )
| project TimeGenerated, Actor, TargetUser, RoleName
| order by TimeGenerated desc
```

### Key KQL — Admin Account Sign-In from Risky Location

```kql
SigninLogs
| where TimeGenerated > ago(24h)
| where UserType == "Member"
| where RiskLevelDuringSignIn in ("high", "medium")
| join kind=inner (
    AuditLogs
    | where OperationName contains "role"
    | extend ActorUPN = tostring(InitiatedBy.user.userPrincipalName)
    | project ActorUPN
    | distinct ActorUPN
) on $left.UserPrincipalName == $right.ActorUPN
| project TimeGenerated, UserPrincipalName, IPAddress, LocationDetails,
          RiskLevelDuringSignIn, ConditionalAccessStatus, DeviceDetail
```

### Key KQL — Service Account Interactive Sign-In

```kql
SigninLogs
| where TimeGenerated > ago(24h)
| where UserDisplayName startswith "svc-" // adapt to your naming convention
    or UserPrincipalName startswith "svc."
| where ClientAppUsed !in ("Exchange ActiveSync", "IMAP4", "POP3")
| where AppDisplayName !in ("Microsoft Azure Active Directory Connect")
| project TimeGenerated, UserPrincipalName, IPAddress, AppDisplayName,
          ClientAppUsed, DeviceDetail, LocationDetails
```

---

## 2. Triage

### Immediate Questions

1. Is this an account the user legitimately controls, or has the admin account itself been compromised?
2. What specific privileged actions were performed — policy changes, role assignments, data access?
3. Was there a corresponding change ticket or approved PIM justification?
4. What device was used? Is it a Privileged Access Workstation (PAW) or a standard device?
5. Has this admin account signed in from this IP or location before?
6. Are there any other unusual activities in the same time window — other admin accounts, service accounts?

### Log Sources to Review

| Source | What to look for |
|---|---|
| Entra ID Audit Logs | Role assignments, policy changes, user creation, password resets |
| Entra ID Sign-in Logs | Device, IP, MFA result, Conditional Access policy outcome |
| Entra ID PIM Logs | Activation reason, ticket number, approver |
| Microsoft 365 Unified Audit Log | SharePoint admin actions, Exchange rule creation, Teams changes |
| Azure Activity Log | Subscription-level changes, resource creation or deletion |
| CrowdStrike | Was the admin action performed from a device with an active detection? |

### Severity Classification

| Condition | Severity |
|---|---|
| Global Administrator account compromised or actions unaccounted for | Critical |
| Privileged role permanently assigned bypassing PIM approval | Critical |
| Admin used from non-PAW device with concurrent CrowdStrike alert | Critical |
| Conditional Access policies modified to weaken enforcement | Critical |
| PIM activation outside hours without ticket — no confirmed malicious action | High |
| Service account used interactively | High |
| Admin sign-in from new country — no confirmed action taken | High |
| PIM activation by authorised user — justification incomplete | Medium |

---

## 3. Containment

### Immediate Actions

```powershell
# Revoke all sessions for the compromised admin account
Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All"

$adminUpn = "admin.smith@corp.onmicrosoft.com"
$adminId = (Get-MgUser -Filter "userPrincipalName eq '$adminUpn'").Id

# Revoke all refresh tokens immediately
Invoke-MgInvalidateUserRefreshToken -UserId $adminId

# Disable account pending investigation
Update-MgUser -UserId $adminId -AccountEnabled:$false

Write-Host "Sessions revoked and account disabled for $adminUpn"
```

- [ ] Revoke all sessions and disable the account before any further investigation
- [ ] Identify and review all Conditional Access policy changes made in the incident window — revert any weakening changes
- [ ] Review all role assignments made since the first suspicious activity — revoke any that are unaccounted for
- [ ] If a service account: rotate the service account credential and review all applications using it
- [ ] Notify the legitimate account owner (if account misuse, not owner acting maliciously)

### Revert Unauthorised Policy Changes

```powershell
# List recent Conditional Access policy modifications (requires AuditLogs)
# Use Entra ID portal: Protection > Conditional Access > What If / Policy change log

# To list all CA policies and their current state:
Connect-MgGraph -Scopes "Policy.Read.All"
Get-MgIdentityConditionalAccessPolicy | Select-Object DisplayName, State, Id |
    Sort-Object DisplayName | Format-Table
```

---

## 4. Investigation

### Reconstruct the Admin Session

```kql
// All audit events by the suspect admin in the incident window
AuditLogs
| where TimeGenerated between (datetime(2026-03-15T00:00:00Z) .. datetime(2026-03-15T06:00:00Z))
| extend Actor = tostring(InitiatedBy.user.userPrincipalName)
| where Actor == "admin.smith@corp.onmicrosoft.com"
| project TimeGenerated, OperationName, Category, Result,
          TargetResources, Actor
| order by TimeGenerated asc
```

### Identify All Changes Made

Key audit operations to search for:

| Operation | Risk |
|---|---|
| `Update Conditional Access policy` | Could weaken or disable access controls |
| `Add member to role` | Privilege escalation — persistence |
| `Reset user password` | Account takeover of target user |
| `Update application` | Redirect URIs, permissions, secrets modified |
| `Consent to application` | OAuth app granted broad permissions |
| `Add service principal` | New app registration with access |
| `Delete user` | Destructive — evidence or account removal |
| `Set federation settings on domain` | Golden SAML attack setup |

### Microsoft 365 Unified Audit Log — Admin Actions

```powershell
# Search M365 unified audit log for admin actions
Connect-ExchangeOnline -UserPrincipalName security@corp.onmicrosoft.com

Search-UnifiedAuditLog `
    -StartDate (Get-Date).AddDays(-1) `
    -EndDate (Get-Date) `
    -UserIds "admin.smith@corp.onmicrosoft.com" `
    -ResultSize 500 |
    Select-Object CreationDate, UserIds, Operations, AuditData |
    Export-Csv -Path ".\admin-audit-export.csv" -NoTypeInformation
```

### PIM Activation Review

1. Navigate to **Entra ID > Identity Governance > Privileged Identity Management**
2. Select **Azure AD roles > My audit history** (or Audit history for admins)
3. Filter by the suspect account and time window
4. Review: activation reason, ticket number, approver, duration
5. Cross-reference ticket numbers against the change management system

---

## 5. Eradication and Recovery

### Remediation Checklist

- [ ] All unauthorised role assignments revoked
- [ ] All modified Conditional Access policies reviewed and reverted if unauthorised
- [ ] Compromised admin account credential reset, MFA device re-registered
- [ ] All active sessions confirmed terminated (verify via Entra ID > Sign-in logs — no active sessions)
- [ ] Service accounts reviewed — ensure no interactive sign-in capability remains
- [ ] PIM approval workflow reviewed — confirm all future activations require a ticket number
- [ ] PAW policy reviewed — confirm admin accounts are blocked from standard workstations via Conditional Access

### PIM Hardening (if process gaps identified)

- [ ] Require justification and ticket number on all PIM activations
- [ ] Set maximum activation duration to 4 hours (not 24)
- [ ] Enable PIM alert: `Roles are being activated too frequently`
- [ ] Enable PIM alert: `Roles are being assigned outside of PIM`
- [ ] Require MFA on activation for all privileged roles

---

## 6. Post-Incident

### Stakeholder Communication Template

> **Privileged Access Incident — [Date]**
>
> We identified [unauthorised use / suspicious activity] on a privileged account (`[account name]`) at [time].
>
> **Actions taken immediately:** The account was suspended and all active sessions were terminated. All changes made during the incident window have been reviewed. [Any unauthorised changes have been reversed.]
>
> **Current status:** The account remains suspended pending investigation. [Other affected users / systems] have been notified and their credentials reset.
>
> **What this means for ongoing operations:** [Describe any impact on services or workflows and the expected resolution timeline.]

### Evidence to Preserve

| Artefact | Retention | Location |
|---|---|---|
| Entra ID Audit Log export (CSV/JSON) | 7 years | Incident evidence store |
| PIM activation log export | 7 years | Incident evidence store |
| Conditional Access policy change history | 7 years | Incident evidence store |
| M365 Unified Audit Log export | 7 years | Incident evidence store |
| CrowdStrike event export for admin device | 7 years | Incident evidence store |

### ISMS Obligations (ISO 27001:2022)

| Obligation | Control | Action |
|---|---|---|
| Record incident in information security incident register | A.5.27 | Log within 24 hours; include all actions taken |
| Verify privileged access controls were operating as designed | A.8.2 | Confirm PIM, PAW policy, and Conditional Access for admins were configured correctly |
| Review whether access rights are still appropriate | A.5.18 | Conduct a spot review of all privileged role holders |
| Assess whether access control policy requires update | A.5.15 | Raise a corrective action if PIM gaps, PAW bypass, or policy weaknesses are confirmed |
| Preserve evidence with chain-of-custody documentation | A.5.28 | Document all audit log exports and when they were taken |
| Assess whether a personal data breach occurred | A.5.26 | Admin access to personal data repositories triggers Privacy Act assessment |
| Conduct lessons-learned and update controls | A.5.27 | Complete review within 5 business days of closure; update PIM or CA policies as required |
| Report to senior management if Critical | A.5.26 | Immediate verbal briefing; written summary within 24 hours |

### Lessons-Learned Review

- Was PIM enforced for the role that was abused — or was the role permanently assigned?
- Was the admin action performed from a PAW, or was the PAW Conditional Access policy bypassable?
- Did the sign-in from the unusual location trigger a Conditional Access block or just an alert?
- Was MFA enforced at the time of the admin sign-in — if not, why not?
- Was the service account configured with interactive sign-in capability — should it have been blocked?
- Would a Just-In-Time access model have limited the window of exposure?

---

## Related

- Account compromise → [account-compromise-playbook.md](account-compromise-playbook.md)
- Conditional Access policy documentation → `../reference/identity-access/policies/conditional-access/`
- PIM server access guide → `../reference/identity-access/guides/passwordless/servers/`
- Identity security architecture → `../architecture/identity-security-architecture.md`
- ASD Essential Eight — Restrict Administrative Privileges → `../compliance/asd-essential-eight/`
