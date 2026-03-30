# Entra ID – CA – PIM Server Access (Phishing-Resistant)

## Overview

**Platform:** Entra ID
**Profile Type:** Conditional Access Policy

**Description:**
This Conditional Access policy enforces **phishing-resistant MFA** for users accessing Azure management resources and activating PIM roles. It is the identity enforcement layer for the PIM passwordless server access workflow documented in the servers guide — ensuring that any user elevating via PIM is authenticated with a hardware-backed or device-bound credential before gaining server access.

The policy targets users who are eligible for PIM roles (local server admin group, privileged Azure roles) and requires they satisfy the **Phishing-resistant MFA** authentication strength — satisfied by Windows Hello for Business, FIDO2 security keys, or Microsoft Authenticator passkey. Passwords combined with push MFA do not satisfy this requirement.

---

## Assignments

### Included Users

| Target                              | Status | Notes                                                             |
| ----------------------------------- | ------ | ----------------------------------------------------------------- |
| grp-pim-eligible                    | Active | All users with eligible PIM role assignments                      |
| All users (option for broader scope) | Active | Alternatively, scope to all users for full Azure Management coverage |

### Excluded Groups

| Group                       | Status   | Reason                                                               |
| --------------------------- | -------- | -------------------------------------------------------------------- |
| grp-break-glass-accounts    | Excluded | Emergency access must never be blocked by CA — monitor separately    |
| grp-service-accounts        | Excluded | Non-interactive; use managed identities for Azure resource access    |

### Scope Tags

| Selected Tags |
| ------------- |
| Default       |

---

## Configuration Settings

### Cloud Apps

| Setting       | Value                                                        | Description                                                                                                                          |
| ------------- | ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------ |
| **Target apps** | Microsoft Azure Management                                  | Covers the Azure portal, Azure CLI, Azure PowerShell, and all ARM API calls. Scope narrows the blast radius vs All cloud apps.       |
|               | *(Optional: All cloud apps)*                                 | Broader scope — enforces phishing-resistant MFA for all Entra-connected apps. Combine with `phishing-resistant-mfa-enforcement` policy. |

---

### Conditions

| Condition               | Value                                           | Description                                                                                             |
| ----------------------- | ----------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| **Device platforms**    | Any                                             | Not scoped to a specific platform — admin connections may come from Windows, macOS, or Linux.           |
| **Client apps**         | Browser, Mobile apps and desktop clients        | Includes modern auth clients. Legacy auth clients should be blocked by a separate CA policy.            |
| **Sign-in risk**        | Not configured (or Low/Medium/High)             | Optionally require step-up to phishing-resistant MFA for elevated sign-in risk.                         |

---

### Grant Controls

| Setting                         | Value                    | Description                                                                                                                   |
| ------------------------------- | ------------------------ | ----------------------------------------------------------------------------------------------------------------------------- |
| **Require authentication strength** | Phishing-resistant MFA | Built-in Microsoft authentication strength. Requires: FIDO2 key, Windows Hello for Business, or certificate-based auth (CBA). |

---

### Session Controls

| Setting                           | Value       | Description                                                                                                                |
| --------------------------------- | ----------- | -------------------------------------------------------------------------------------------------------------------------- |
| **Sign-in frequency**             | 1 hour      | Re-authentication required every hour for Azure Management sessions. Limits the window of an undetected stolen session.    |
| **Persistent browser session**    | Never       | Prevents "stay signed in" for Azure Management. Each session requires fresh authentication.                                |

---

## What Satisfies Phishing-Resistant MFA

The Phishing-resistant MFA authentication strength built into Entra ID is satisfied by the following methods only:

| Method                                  | Satisfies? | Notes                                              |
| --------------------------------------- | ---------- | -------------------------------------------------- |
| FIDO2 security key                      | ✅ Yes     | Hardware-bound; highest assurance                  |
| Windows Hello for Business (Cloud Trust) | ✅ Yes    | TPM-bound; device-scoped credential                |
| Microsoft Authenticator (passkey mode)  | ✅ Yes     | Device-bound; requires Authenticator passkey setup |
| Certificate-based authentication (CBA)  | ✅ Yes     | Smart card / derived credential                    |
| Microsoft Authenticator (push MFA)      | ❌ No      | Push MFA is phishable (MFA fatigue attacks)        |
| Password + SMS OTP                      | ❌ No      | Both factors are remotely phishable                |
| Password + TOTP                         | ❌ No      | TOTP codes can be relayed in real-time phishing     |

---

## Integration with PIM Server Access Workflow

This CA policy is the enforcement gate that must be cleared before PIM activation provides server access:

```
User requests PIM role activation (Server-Admins-JIT)
    ↓
Entra ID evaluates CA policy for Microsoft Azure Management
    ↓
CA requires phishing-resistant MFA authentication strength
    ↓
User signs in with WHfB / FIDO2 key (satisfies requirement)
    ↓
PIM grants group membership for configured duration
    ↓
Azure Arc syncs group → local admin added on target server
    ↓
User RDPs to server using passwordless credential (no password prompt)
```

Without this CA policy, a user could activate a PIM role using a password + push MFA — both of which are phishable.

---

## Policy Rationale

- **PIM is only as strong as the authentication enforcing it:** PIM's value comes from time-limiting privilege. If privilege can be activated with a phishable credential, the security benefit is undermined.
- **Azure Management is a high-value target:** access to the Azure portal provides control over virtual machines, storage, networking, and identity configuration. Strong auth enforcement here protects cloud infrastructure.
- **Session frequency re-authentication** limits the value of a stolen session token — a 1-hour window reduces the damage window if a token is exfiltrated.
- **Break-glass exclusion is mandatory:** if break-glass accounts are locked out of Azure Management, emergency response capability is lost. They must be excluded and monitored separately via Sentinel.

These controls align with:

- Microsoft Secure Score — **Require MFA for Azure management**
- ASD Essential Eight — Privileged access (ML3), Multi-factor authentication (ML3)
- ISO 27001:2022 — A.8.2 Privileged access rights, A.5.15 Access control, A.5.28 Collection of evidence
- CIS Controls v8 — Control 6.4 (Require MFA for externally-exposed applications)

---

## Verification & Monitoring

1. **Entra ID Portal:**
   - `Protection → Conditional Access → Policies` — locate this policy
   - Verify **State** = On, **Target apps** = Microsoft Azure Management
   - Confirm **Grant** = Require authentication strength → Phishing-resistant MFA
   - Confirm **Session** → Sign-in frequency = 1 hour, Persistent browser = Never

2. **Test the Policy:**
   - Sign in to portal.azure.com with a user who has only password + push MFA registered
   - Attempt to navigate to Azure Management resources
   - Expected: access denied with a message indicating authentication strength not satisfied

3. **KQL — PIM activations and CA enforcement:**
   ```kql
   AuditLogs
   | where OperationName == "Add member to role in PIM completed (permanent)"
       or OperationName == "Add eligible member to role in PIM completed"
   | project TimeGenerated, InitiatedBy, TargetResources, ResultReason
   | order by TimeGenerated desc
   ```

   ```kql
   SigninLogs
   | where AppDisplayName == "Microsoft Azure Management"
   | where AuthenticationRequirement == "multiFactorAuthentication"
   | project TimeGenerated, UserPrincipalName, AuthenticationMethodsUsed, ConditionalAccessStatus
   ```

---

## Feedback Loop

1. **Assumptions:**
   - All PIM-eligible users have at least one phishing-resistant method registered (WHfB, FIDO2, or Authenticator passkey) before this policy is enabled.
   - Break-glass accounts are documented, enrolled with FIDO2 keys, and monitored via separate Sentinel alert rule.
   - Azure Arc servers have completed Hybrid Azure AD Join and group-to-local-admin mapping is in place.

2. **Potential Pitfalls:**
   - Enabling this policy before users have phishing-resistant credentials registered will block Azure Management access — run in **Report-only** mode first and review the CA What-If tool.
   - Legacy service accounts using Azure CLI with basic auth will be blocked — ensure all automation uses managed identities or service principals with certificate credentials.
   - Sign-in frequency of 1 hour may cause friction for users running long Azure portal sessions — consider 4 hours for non-admin users if PIM is scoped to admin roles only.

3. **Validation Steps:**
   - Use the **CA What-If tool** (`Conditional Access → What If`) to simulate sign-in for a target user and confirm the policy applies correctly.
   - Enable in **Report-only** first; review `CAReportOnlyLogs` in Log Analytics for at least 7 days before switching to **On**.
   - After enabling, confirm PIM activations in the audit log are authenticated with phishing-resistant methods.

---

## Related

- [PIM Passwordless Server Access Guide](../../../../guides/passwordless/servers/README.md) — Full configuration walkthrough for the PIM + WHfB server access workflow.
- [Windows Hello for Business Policy](../windows-hello/README.md) — Credential that satisfies this CA policy on Windows devices.
- [FIDO2 Security Key Policy](../fido2-security-key/README.md) — Hardware credential that satisfies this CA policy.
- [Phishing-Resistant MFA Enforcement](../phishing-resistant-mfa-enforcement/README.md) — Broader enforcement policy for all cloud apps (not just Azure Management).
- [Microsoft Authenticator Policy](../authentication-method-microsoft-authenticator/README.md) — Authenticator passkey mode also satisfies this policy.
