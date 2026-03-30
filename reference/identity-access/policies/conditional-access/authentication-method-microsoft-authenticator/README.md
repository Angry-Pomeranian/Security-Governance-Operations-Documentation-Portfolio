# Entra ID – AuthN – Microsoft Authenticator

## Overview

**Platform:** Entra ID
**Profile Type:** Authentication Methods Policy

**Description:**
This policy configures the **Microsoft Authenticator** authentication method in Entra ID, enabling both phishing-resistant passwordless phone sign-in and MFA push notifications. When configured for passwordless mode, users approve sign-ins via a number match prompt in the app rather than entering a password — eliminating the credential as an attack surface.

This policy covers three configuration layers: enabling the method and scoping it to users, setting the authentication mode (push MFA vs full passwordless), and hardening push notifications against MFA fatigue attacks via number matching and contextual alerts.

---

## Assignments

### Included Groups

| Group                   | Status | Filter | Filter Mode |
| ----------------------- | ------ | ------ | ----------- |
| grp-authenticator-pilot | Active | None   | None        |

> Expand to All Users after pilot validation. Scope by department group to manage registration campaign cadence.

### Excluded Groups

| Group                    | Status   |
| ------------------------ | -------- |
| grp-break-glass-accounts | Excluded |
| grp-service-accounts     | Excluded |

### Scope Tags

| Selected Tags |
| ------------- |
| Default       |

---

## Configuration Settings

### Enablement & Target

| Setting             | Value                   | Description                                                                                                                 |
| ------------------- | ----------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| **Enable**          | Yes                     | Activates Microsoft Authenticator as a usable authentication method.                                                       |
| **Target**          | Pilot group → All users | Start with a defined pilot group to validate number matching experience before broad rollout.                               |
| **Authentication mode** | Any (rollout phase) → Passwordless | `Any` = push MFA and passwordless phone sign-in both allowed. `Passwordless` = phone sign-in only, no password fallback. |

---

### Security Features (Push Notification Hardening)

| Setting                              | Value   | Description                                                                                                                                                                                   |
| ------------------------------------ | ------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Require number matching**          | Enabled | User must enter the two-digit number displayed on the sign-in screen into the Authenticator app prompt. Prevents blind-approve MFA fatigue attacks. **Cannot be disabled as of Sept 2023.** |
| **Show application name in push**    | Enabled | Displays the name of the app requesting authentication (e.g. "Microsoft Azure Portal"). Helps users detect unexpected or suspicious sign-in prompts.                                         |
| **Show geographic location in push** | Enabled | Displays the approximate sign-in location in the push notification. Users can identify sign-ins from unfamiliar countries or regions.                                                        |

---

### Advanced (Optional)

| Setting                            | Value    | Description                                                                                                        |
| ---------------------------------- | -------- | ------------------------------------------------------------------------------------------------------------------ |
| **FIPS 140-2 compliant mode**      | Optional | Enforces FIPS-validated cryptographic modules on Authenticator. Required for government and regulated environments. |

---

## Mode Progression

Authenticator authentication mode should be tightened over time as passwordless adoption matures:

| Phase | Mode | Who Can Use | Notes |
|---|---|---|---|
| 1 — Rollout | Any | Pilot group | Allows both push MFA and passwordless; users can choose |
| 2 — Expansion | Any | All users | Number matching enforced; Authenticator push replaces SMS |
| 3 — Tighten | Passwordless | All users | Disables password fallback for users in passwordless scope |

---

## Policy Rationale

- **Number matching is mandatory** — Microsoft enforced number matching for all tenants from September 2023. This setting confirms it is intentionally configured, not inherited by default without awareness.
- **Contextual push information** reduces fatigue-driven approvals: when users see an unknown app name or an unexpected location, they are more likely to deny the push and report it.
- **Passwordless mode progression** is gradual to avoid disruption. Users who forget their Authenticator app still have a fallback (`Any` mode) during migration; once all users have enrolled a backup method, `Passwordless` can be enforced.
- **Service accounts excluded** — non-interactive accounts should not have Authenticator registered; they should use certificate-based authentication or managed identities.

These controls align with:

- Microsoft Secure Score — **Ensure MFA is enabled for all users** / **Enable passwordless authentication methods**
- ASD Essential Eight — Multi-factor authentication (ML2: push MFA; ML3: phishing-resistant)
- ISO 27001:2022 — A.5.17 Authentication information, A.8.5 Secure authentication

---

## Verification & Monitoring

1. **Entra ID Portal:**
   - Navigate to `Protection → Authentication methods → Microsoft Authenticator`
   - Verify **State** = Enabled, **Authentication mode** matches current phase.
   - Confirm **Require number matching** = Enabled under Configure tab.

2. **Registration Coverage:**
   - `Entra ID → Protection → Authentication methods → User registration details`
   - Filter by method = Microsoft Authenticator; monitor % registered vs total users.
   - Target: >80% of all users registered before enabling `Passwordless` mode.

3. **Audit Log Monitoring:**
   ```kql
   SigninLogs
   | where AuthenticationDetails has "Microsoft Authenticator"
   | summarize Count = count() by AuthenticationMethodUsed = tostring(AuthenticationDetails[0].authenticationMethod), bin(TimeGenerated, 1d)
   | order by TimeGenerated desc
   ```

---

## Feedback Loop

1. **Assumptions:**
   - Users have enrolled Authenticator via `aka.ms/mysecurityinfo` or a TAP-bootstrapped registration campaign.
   - Authenticator app version is current (auto-update recommended); older versions do not support number matching UI.
   - Devices have internet access for push delivery — offline environments may require alternative methods.

2. **Potential Pitfalls:**
   - If `Authentication mode` is set to `Passwordless` before all users have enrolled, users without Authenticator registered will be unable to sign in.
   - Personal (BYOD) phones removed from service will block authentication; users need a backup method (FIDO2 key or WHfB).
   - Number matching UX is different from the legacy push prompt — users may need brief awareness communication before rollout.

3. **Validation Steps:**
   - Confirm registration: `Entra ID → Users → [user] → Authentication methods` — Authenticator app should appear with device name.
   - Test passwordless sign-in: user signs in, types email only, receives Authenticator push with number — enters number to complete.
   - Verify push shows app name and location by inspecting the notification on a test device after a sign-in attempt.

---

## Related

- [Microsoft Authenticator Deployment Guide](../../../../guides/passwordless/microsoft-auth/README.md) — Deployment steps, security feature overview, and comparison table.
- [TAP Authentication Method Policy](../authentication-method-tap/README.md) — Bootstrap Authenticator registration for new users.
- [FIDO2 Security Key Policy](../fido2-security-key/README.md) — Hardware key alternative for users without personal phones.
- [Phishing-Resistant MFA Enforcement](../phishing-resistant-mfa-enforcement/README.md) — CA policy enforcing phishing-resistant MFA post-registration.
- [Windows Hello for Business Policy](../windows-hello/README.md) — Device-bound alternative to Authenticator for managed Windows endpoints.
