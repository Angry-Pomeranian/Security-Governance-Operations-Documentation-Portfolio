# Entra ID – CA – Phishing-Resistant MFA (All Apps)

## Overview

**Platform:** Entra ID
**Profile Type:** Conditional Access Policy

**Description:**
This Conditional Access policy enforces **phishing-resistant MFA** for all users across all cloud apps. It is the top-level enforcement layer that ties all passwordless authentication method deployments together — once users have registered a phishing-resistant credential (WHfB, FIDO2 key, or Authenticator passkey), this policy ensures they must use it.

Unlike the PIM-scoped policy (`pim-server-access`), this policy applies broadly and gradually — starting in **Report-only** mode, moving to a pilot group, then expanding to all users as passwordless adoption matures. Users who do not yet have a phishing-resistant method registered are blocked from being in scope until registration is complete.

---

## Assignments

### Included Users

| Target                             | Status | Notes                                                                    |
| ---------------------------------- | ------ | ------------------------------------------------------------------------ |
| grp-passwordless-enforced (pilot)  | Active | Phase 1: users who have completed passwordless enrollment                |
| All users (Phase 3)                | Active | Final state — requires >90% passwordless registration across tenant      |

### Excluded Groups

| Group                         | Status   | Reason                                                                     |
| ----------------------------- | -------- | -------------------------------------------------------------------------- |
| grp-break-glass-accounts      | Excluded | Emergency access must never be blocked — monitored separately              |
| grp-service-accounts          | Excluded | Non-interactive; use managed identities or certificate-based credentials   |
| grp-passwordless-not-enrolled | Excluded | Phase 1/2: users not yet enrolled are excluded until registration complete |

### Scope Tags

| Selected Tags |
| ------------- |
| Default       |

---

## Configuration Settings

### Cloud Apps

| Setting         | Value          | Description                                                                                                           |
| --------------- | -------------- | --------------------------------------------------------------------------------------------------------------------- |
| **Target apps** | All cloud apps | Covers all Entra ID–integrated applications. Ensures phishing-resistant auth is required everywhere, not just Azure. |

---

### Conditions

| Condition            | Value                                    | Description                                                                                                     |
| -------------------- | ---------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| **Device platforms** | Any                                      | Applies across Windows, macOS, iOS, Android, and Linux.                                                         |
| **Client apps**      | Browser + Mobile apps + Desktop clients  | Modern auth clients. Legacy auth clients (basic auth) should be blocked separately.                             |
| **Sign-in risk**     | Low, Medium, High (or not configured)    | Apply to all risk levels. Optionally add step-up for High risk (require fresh phishing-resistant sign-in).       |

---

### Grant Controls

| Setting                             | Value                    | Description                                                                                                                                     |
| ----------------------------------- | ------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| **Require authentication strength** | Phishing-resistant MFA   | Built-in Microsoft authentication strength. Satisfied by: FIDO2 security key, Windows Hello for Business, Authenticator passkey, CBA only.     |

---

### Session Controls

| Setting | Value | Description |
| ------- | ----- | ----------- |
| Not configured initially | — | Session controls can be layered in later (e.g. sign-in frequency for specific high-value apps via separate policy). |

---

## What Satisfies Phishing-Resistant MFA

| Method                                   | Satisfies? | Notes                                                   |
| ---------------------------------------- | ---------- | ------------------------------------------------------- |
| FIDO2 security key                       | ✅ Yes     | Hardware-bound; strongest available option              |
| Windows Hello for Business               | ✅ Yes     | TPM-bound; device-scoped                                |
| Microsoft Authenticator (passkey mode)   | ✅ Yes     | Device-bound; passkey registered in Authenticator app   |
| Certificate-based authentication (CBA)   | ✅ Yes     | Smart card / PIV credential                             |
| Microsoft Authenticator (push MFA)       | ❌ No      | Push MFA is susceptible to MFA fatigue attacks          |
| Password + SMS OTP                       | ❌ No      | Both factors are phishable                              |
| Password + TOTP (Google Authenticator)   | ❌ No      | TOTP can be relayed in real-time phishing               |
| Password only                            | ❌ No      | Passwords are phishable and reusable                    |

---

## Rollout Strategy

This policy must be deployed gradually. Enabling it across all users before registration is complete will cause sign-in failures.

| Phase | Scope | Mode | Prerequisites |
|---|---|---|---|
| **0 — Baseline** | All users | Report-only | Enable and observe without enforcement. Review CA What-If and sign-in logs. |
| **1 — Pilot** | grp-passwordless-enforced | Enabled | Pilot group has 100% phishing-resistant methods registered |
| **2 — Expansion** | Departments via nested groups | Enabled | Each department completes registration campaign before being added to scope |
| **3 — Full** | All users | Enabled | >90% registration coverage; grp-passwordless-not-enrolled group is empty |

**Registration campaign:** Use the Entra ID **Authentication methods registration campaign** (`Protection → Authentication methods → Registration campaign`) to prompt users to register a phishing-resistant method before enforcement.

---

## Policy Rationale

- **Password-based MFA is not enough:** push MFA, SMS OTP, and TOTP codes can be relayed by a phishing proxy in real time. Phishing-resistant credentials are immune to this attack class by design.
- **This policy is the outcome of all other passwordless investments:** TAP lets users enrol, Authenticator and FIDO2 policies configure what methods are available, WHfB Intune profiles set device credentials — this policy is the enforcement that makes those registrations meaningful.
- **Gradual rollout prevents access disruption:** removing password-based auth for users before they have an alternative enrolled locks them out. The staged approach, combined with the `grp-passwordless-not-enrolled` exclusion, prevents this.
- **Break-glass exclusion is non-negotiable:** break-glass accounts exist precisely for scenarios where normal authentication infrastructure fails. They must be excluded from all CA policies and independently secured.

These controls align with:

- Microsoft Secure Score — **Enable phishing-resistant MFA** / **Require MFA for all users**
- ASD Essential Eight — Multi-factor authentication (ML3: phishing-resistant for all users)
- NIST SP 800-63B — AAL3 authentication assurance
- ISO 27001:2022 — A.5.15 Access control, A.5.17 Authentication information, A.8.5 Secure authentication

---

## Verification & Monitoring

1. **Entra ID Portal:**
   - `Protection → Conditional Access → Policies` — confirm policy state (report-only or enabled).
   - `Protection → Authentication methods → User registration details` — confirm % of users with phishing-resistant methods before advancing phases.

2. **Report-Only Analysis (Phase 0):**
   ```kql
   AADNonInteractiveUserSignInLogs
   | where ConditionalAccessStatus == "reportOnly"
   | where CAReportOnlyPolicies has "[policy-id]"
   | summarize count() by UserPrincipalName, AuthenticationRequirement
   ```

3. **Sign-in authentication method distribution:**
   ```kql
   SigninLogs
   | where TimeGenerated > ago(7d)
   | extend Method = tostring(AuthenticationDetails[0].authenticationMethod)
   | summarize Count = count() by Method
   | order by Count desc
   ```

4. **Users blocked by policy (post-enablement):**
   ```kql
   SigninLogs
   | where ResultType == 53003
   | where ConditionalAccessStatus == "failure"
   | project TimeGenerated, UserPrincipalName, AppDisplayName, FailureReason
   ```

---

## Feedback Loop

1. **Assumptions:**
   - A registration campaign is running before or in parallel with Phase 1 enforcement.
   - `grp-passwordless-not-enrolled` is maintained (manually or via dynamic group query on registered method) and shrinks over time.
   - IT helpdesk has a process for users who are blocked (issue TAP → complete registration → remove from exclusion group).

2. **Potential Pitfalls:**
   - Moving directly to All users without completing registration will cause widespread sign-in failures — follow the phase model.
   - Users on devices that don't support WHfB (TPM not present, non-Windows) will need FIDO2 keys or Authenticator passkey as an alternative.
   - Shared/kiosk devices may need special handling — consider using FIDO2 keys for shared workstation sign-in.

3. **Validation Steps:**
   - Operate in Report-only for minimum 7 days; review logs for users who would be blocked.
   - Use the **CA What-If** tool to simulate sign-ins for pilot users and confirm expected outcomes.
   - After enabling for pilot, confirm pilot users can sign in successfully with phishing-resistant credentials.
   - Monitor helpdesk tickets for authentication failures during each phase rollout.

---

## Related

- [PIM Server Access Policy](../pim-server-access/README.md) — Specific enforcement for Azure Management and PIM-eligible users.
- [Windows Hello for Business Policy](../windows-hello/README.md) — Credential that satisfies this enforcement on Windows devices.
- [FIDO2 Security Key Policy](../fido2-security-key/README.md) — Hardware credential that satisfies this policy.
- [Microsoft Authenticator Policy](../authentication-method-microsoft-authenticator/README.md) — Authenticator passkey mode satisfies this policy.
- [TAP Authentication Method Policy](../authentication-method-tap/README.md) — Bootstrap credential used to enrol phishing-resistant methods before enforcement.
- [MFA Deployment Guide](../../../../guides/mfa/README.md) — Initial MFA rollout guide; this policy is the maturation step post-MFA adoption.
