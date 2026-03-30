# Account Compromise Response Playbook

**Scenario:** Unauthorised access to a user or service account — including credential theft, business email compromise (BEC), session hijacking, or insider misuse.

**Severity:** High
**Target containment time:** 1 hour from confirmed detection

---

## 1. Detection

### Alert Triggers

| Source | Indicator |
|---|---|
| Microsoft Sentinel | `Successful sign-in from impossible travel location` |
| Microsoft Sentinel | `Sign-in from anonymous IP or Tor exit node` |
| Microsoft Sentinel | `Brute force success following multiple failed sign-ins` |
| Microsoft Entra ID Protection | Risk event: `unfamiliar sign-in properties`, `leaked credentials` |
| Proofpoint TAP | `BEC indicator — display name spoofing` |
| CrowdStrike Falcon | `Credential access — LSASS read` |
| User-reported | `I didn't send that email` / `account locked out unexpectedly` |

### Key KQL — Sentinel Sign-in Anomaly Detection

```kql
SigninLogs
| where TimeGenerated > ago(24h)
| where ResultType == 0
| extend Country = tostring(LocationDetails.countryOrRegion)
| summarize SigninCount = count(), Countries = make_set(Country) by UserPrincipalName
| where array_length(Countries) > 1
| order by SigninCount desc
```

### Key KQL — Multiple Failed Followed by Success

```kql
SigninLogs
| where TimeGenerated > ago(1h)
| summarize
    Failures = countif(ResultType != 0),
    Successes = countif(ResultType == 0)
    by UserPrincipalName, bin(TimeGenerated, 10m)
| where Failures > 5 and Successes > 0
```

---

## 2. Triage

### Immediate Questions

1. Is this a valid user or a service account?
2. When did the last known-good sign-in occur? From where?
3. Has MFA been challenged? Was it bypassed (MFA fatigue, SIM swap)?
4. Is there mailbox forwarding configured? Has mail been exported?
5. Are any admin roles assigned to the account?

### Log Sources to Review

| Source | What to look for |
|---|---|
| Microsoft Entra sign-in logs | IP, device, MFA status, conditional access result |
| Unified Audit Log (M365) | Mailbox rule changes, forwarding, external sharing |
| Azure Activity Log | Role assignments, resource modifications |
| CrowdStrike | Process execution on the user's endpoint at sign-in time |

### Severity Classification

| Condition | Severity |
|---|---|
| Standard user, no admin roles, no mail export | Medium |
| Admin account or service account compromised | High |
| Lateral movement detected or data exfiltrated | Critical |
| BEC — fraudulent financial transaction initiated | Critical |

---

## 3. Containment

### Immediate Actions (within 15 minutes of confirmation)

- [ ] Revoke all active sessions: Entra ID > User > Revoke sessions
- [ ] Reset the user's password (do not notify attacker by using predictable reset)
- [ ] Disable the account if admin compromise is confirmed
- [ ] Block the source IP(s) in Conditional Access or firewall
- [ ] Temporarily remove admin roles from the compromised account
- [ ] Alert the account owner via out-of-band channel (phone, not email)

### If BEC is Confirmed

- [ ] Notify Finance/AP team immediately — confirm no pending wire transfers
- [ ] Search for inbox rules forwarding mail externally:

```kql
OfficeActivity
| where Operation in ("New-InboxRule", "Set-InboxRule")
| where Parameters has "ForwardTo" or Parameters has "RedirectTo"
| where TimeGenerated > ago(7d)
```

- [ ] Remove forwarding rules and external delegates

---

## 4. Investigation

### Evidence to Collect

| Evidence | Source | Retention note |
|---|---|---|
| Full sign-in log export (30 days) | Entra ID | Export before log rollover |
| Unified Audit Log export | M365 Compliance Centre | Preserve before purge |
| Inbox rules at time of compromise | Exchange Online | Document before removal |
| Conditional Access evaluation logs | Entra ID | Captures bypass details |
| Endpoint telemetry | CrowdStrike Falcon | Timeline of local process execution |

### Determine Attacker Dwell Time

```kql
SigninLogs
| where UserPrincipalName == "user@domain.com"
| where ResultType == 0
| order by TimeGenerated asc
| project TimeGenerated, IPAddress, Location, DeviceDetail, AuthenticationDetails
```

### Look for Persistence Mechanisms

- New MFA methods registered by attacker
- New OAuth app consented by the account
- Guest accounts added to the tenant
- Conditional Access exclusions modified

```kql
AuditLogs
| where TimeGenerated > ago(30d)
| where OperationName in (
    "Update user",
    "Add member to role",
    "Consent to application",
    "Add registered owner to device"
  )
| where InitiatedBy.user.userPrincipalName == "user@domain.com"
```

---

## 5. Eradication and Recovery

### Remediation Steps

- [ ] Re-enable account with new password (16+ character, unique)
- [ ] Re-enroll MFA using a verified, user-controlled method
- [ ] Audit and remove any OAuth applications consented during the compromise window
- [ ] Review and remove inbox rules added during compromise window
- [ ] Re-evaluate Conditional Access policies — confirm account is no longer excluded
- [ ] Rotate any service credentials or API keys the account had access to
- [ ] Confirm no new admin accounts were created during dwell time

### Verification Before Return to Operations

- Sign-in from known device using new credentials
- MFA challenge succeeds on user-controlled device
- No forwarding rules active
- Entra ID risk score cleared or dismissed with justification

---

## 6. Post-Incident

### Customer Communication Template

> **Summary:** An unauthorised sign-in to [user]'s account was detected on [date] from [location/IP]. The account was secured within [X] minutes of detection. Investigation confirmed [scope of access]. No evidence of [data exfiltration / lateral movement] was found. [OR: The following data/systems were accessed: …]
>
> **Actions taken:** Session revocation, password reset, MFA re-enrolment, inbox rule removal.
>
> **Recommendations:** [Enforce phishing-resistant MFA / Review Conditional Access exclusions / Security awareness training]

### Documentation Requirements

- [ ] Incident timeline (first alert → containment → resolution)
- [ ] Root cause (credential phishing, password spray, insider, etc.)
- [ ] Accounts and systems affected
- [ ] Actions taken with timestamps
- [ ] Evidence preserved and chain of custody
- [ ] Recommendations delivered to customer

### Lessons-Learned Review

- Was MFA phishing-resistant (FIDO2/passkey) or vulnerable to AiTM?
- Did Conditional Access policy prevent or allow the initial access?
- How did the attacker obtain credentials? (Phishing, breach db, spray?)
- What detection latency existed between compromise and alert?

---

## Related

- Phishing investigation → [phishing-investigation-playbook.md](phishing-investigation-playbook.md)
- Data exfiltration → [data-exfiltration-response-playbook.md](data-exfiltration-response-playbook.md)
- Identity and MFA controls → `../reference/identity-access/`
