# Entra ID – AuthN – Temporary Access Pass

## Overview

**Platform:** Entra ID
**Profile Type:** Authentication Methods Policy

**Description:**
This policy configures the **Temporary Access Pass (TAP)** authentication method in Entra ID. TAP is a time-limited, admin-issued passcode that allows a user to sign in and register new authentication methods without requiring existing credentials. It is the recommended bootstrap mechanism for passwordless rollout — enabling a user to register Microsoft Authenticator, a FIDO2 security key, or Windows Hello for Business on day one, without a pre-existing password or MFA method.

TAPs are not intended for persistent authentication use. They are a short-lived, controlled bridge to get a user into a registered passwordless state.

---

## Assignments

### Included Groups

| Group                    | Status | Filter | Filter Mode |
| ------------------------ | ------ | ------ | ----------- |
| All users (or pilot group) | Active | None   | None        |

### Excluded Groups

| Group                       | Status  |
| --------------------------- | ------- |
| grp-break-glass-accounts    | Excluded |
| grp-service-accounts        | Excluded |

### Scope Tags

| Selected Tags |
| ------------- |
| Default       |

---

## Configuration Settings

### Enablement

| Setting | Value  | Description                                                                                           |
| ------- | ------ | ----------------------------------------------------------------------------------------------------- |
| **Enable** | Yes | Activates TAP as a usable authentication method across the tenant.                                    |
| **Target** | All users (or scoped group) | Scope to a pilot group initially; expand to all users after validating the onboarding workflow.       |

---

### Lifetime & Reuse

| Setting                        | Value              | Description                                                                                                                   |
| ------------------------------ | ------------------ | ----------------------------------------------------------------------------------------------------------------------------- |
| **Minimum lifetime (minutes)** | 10                 | Shortest period a TAP can be set to. Useful for high-assurance environments requiring very short windows.                     |
| **Maximum lifetime (minutes)** | 480                | Upper bound an admin can set when creating a TAP. 8 hours covers cross-timezone onboarding; reduce to 60–120 min if possible. |
| **Default lifetime (minutes)** | 60                 | What the portal uses by default when an admin creates a TAP without specifying duration. 60 minutes covers most registrations. |
| **Allow one-time use**         | Yes (Enabled)      | TAP is invalidated after its first successful use. Prevents reuse even if observed or intercepted during creation.            |

---

## When TAP Is — and Is Not — Used

| Scenario                     | Use TAP? | Notes                                                                               |
| ---------------------------- | -------- | ----------------------------------------------------------------------------------- |
| New employee onboarding      | ✅ Yes   | User has no existing MFA; TAP bootstraps Authenticator/FIDO2/WHfB registration     |
| Passwordless migration       | ✅ Yes   | Bootstrap passkey/WHfB for users previously on password + SMS                      |
| Account recovery             | ✅ Yes   | User lost their MFA device and has no backup method                                 |
| Admin-initiated re-enrolment | ✅ Yes   | Force re-registration after suspected credential compromise                         |
| Shared device provisioning   | ✅ Yes   | Initial access on a kiosk or shared workstation before WHfB setup                  |
| Ongoing daily sign-in        | ❌ No    | TAP is a bootstrap mechanism, not a long-term credential                            |
| Persistent admin access      | ❌ No    | Use FIDO2 key or WHfB for privileged access; TAP expires and provides no continuity |

---

## Policy Rationale

- **Passwordless requires a starting point:** users cannot enrol a FIDO2 key or WHfB credential without first authenticating. TAP breaks this chicken-and-egg dependency securely.
- **One-time use prevents replay:** a TAP used to register an Authenticator app is immediately invalidated — a threat actor who intercepts the passcode cannot reuse it.
- **Short lifetime limits exposure:** the default 60-minute window is sufficient for self-service registration at `mysecurityinfo` without leaving a long exposure window.
- **Exclusions protect emergency access:** break-glass accounts have dedicated emergency processes; adding them to TAP scope creates unnecessary risk.

These controls align with:

- Microsoft Secure Score — **Enable combined MFA and SSPR registration**
- ASD Essential Eight — Multi-factor authentication (ML2/ML3)
- ISO 27001:2022 — A.5.17 Authentication information, A.8.5 Secure authentication

---

## Verification & Monitoring

1. **Entra ID Portal:**
   - Navigate to `Protection → Authentication methods → Temporary Access Pass`
   - Verify **State** = Enabled and settings match this policy.
   - Check **Included/Excluded groups** match assignments above.

2. **Audit Log Monitoring:**
   - Entra sign-in logs: filter Authentication Method = `Temporary Access Pass`
   - KQL query in Sentinel:
     ```kql
     SigninLogs
     | where AuthenticationDetails has "Temporary Access Pass"
     | project TimeGenerated, UserPrincipalName, ResultType, ResultDescription, Location
     ```

3. **Per-User Verification:**
   - `Entra ID → Users → [user] → Authentication methods` — confirms TAP was issued and shows expiry time.
   - After user completes registration, TAP entry should disappear (one-time use) or show as expired.

---

## Feedback Loop

1. **Assumptions:**
   - Admins issuing TAPs have at minimum the Authentication Administrator role — they cannot issue TAPs for Global Admins without Global Admin role.
   - The onboarding workflow communicates the TAP to the user via a secure channel (IT help desk call, secure email, or identity provisioning tool) — never via plaintext IM or email alone.
   - TAP is not the only authentication method configured; users complete Authenticator/FIDO2/WHfB registration during the TAP session.

2. **Potential Pitfalls:**
   - A TAP issued with **multi-use** and **long lifetime** widens the interception window — default to one-time use and 60-minute lifetime unless there is a specific reason.
   - TAPs for Global Admin accounts require a Global Admin to issue — Authentication Administrators cannot issue them. Plan for this in break-glass scenarios.
   - If a user navigates away from `mysecurityinfo` before completing registration, the one-time TAP is consumed and they will need a new one issued.

3. **Validation Steps:**
   - Confirm TAP policy state via portal after changes.
   - Verify newly onboarded user appears in `SigninLogs` with Authentication Method = TAP, followed immediately by a registration event.
   - Review `AuditLogs` for `Create TemporaryAccessPass` operations and confirm issuer identity is an approved admin role.

---

## Related

- [TAP Deployment Guide](../../../../guides/passwordless/tap/README.md) — Step-by-step guide for issuing TAPs via portal and PowerShell.
- [Microsoft Authenticator Policy](../authentication-method-microsoft-authenticator/README.md) — Register Authenticator after TAP bootstrap.
- [FIDO2 Security Key Policy](../fido2-security-key/README.md) — Register a hardware key after TAP bootstrap.
- [Windows Hello for Business Policy](../windows-hello/README.md) — WHfB enrollment bootstrapped via TAP on first sign-in.
- [Phishing-Resistant MFA Enforcement](../phishing-resistant-mfa-enforcement/README.md) — CA policy that TAP-enrolled users must satisfy post-registration.
