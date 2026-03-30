# Microsoft Authenticator — Passwordless Setup

## Overview

Microsoft Authenticator enables passwordless phone sign-in and phishing-resistant MFA for Entra ID accounts. When configured for passwordless, users approve sign-ins via a number match prompt in the Authenticator app rather than entering a password. This eliminates the password as an attack vector while maintaining a familiar, low-friction user experience.

Authenticator is deployed and managed via the Entra ID **Authentication Methods** policy, which allows granular control over which users or groups can use each authentication method and in which mode.

---

## Deployment Steps

1. **Enable Microsoft Authenticator** in Entra ID:
   - Navigate to: `Entra ID → Protection → Authentication methods → Microsoft Authenticator`
   - Set **Enable** to `Yes`
   - Set **Target** to a pilot group, then expand to all users after validation

2. **Configure authentication mode:**
   - `Any` — allows both passwordless phone sign-in and push notification MFA
   - `Passwordless` — enforces phone sign-in only (users cannot fall back to password + push)
   - Start with `Any` during rollout; tighten to `Passwordless` as adoption matures

3. **Enable Number Matching** (required, not optional):
   - Navigate to: `Authentication methods → Microsoft Authenticator → Configure`
   - Set **Require number matching** to `Enabled`
   - Number matching prevents MFA fatigue attacks by requiring users to enter a number shown on the sign-in screen into the Authenticator app prompt

4. **Enable Additional Context:**
   - Set **Show application name** and **Show geographic location** to `Enabled`
   - Provides users with contextual information in the push notification to detect suspicious approvals

5. **User registration:**
   - Direct users to `aka.ms/mysecurityinfo` or enforce via SSPR combined registration
   - Users scan a QR code to add their work account to Authenticator
   - Registration can be bootstrapped using a [Temporary Access Pass (TAP)](../tap/README.md) for new or passwordless-only users

---

## Security Features

| Feature | Security Benefit |
|---|---|
| Number Matching | Prevents MFA fatigue (prompt bombing) attacks — user must actively enter a number, not just tap Approve |
| Additional Context (app + location) | Helps users identify and reject suspicious push notifications from unfamiliar apps or locations |
| Passwordless Phone Sign-in | Eliminates password entirely; credentials are device-bound and phishing-resistant |
| FIPS 140-2 Compliant Mode | Available for regulated environments requiring FIPS-validated cryptographic modules |
| Device-Bound Credentials | Authenticator credentials are tied to the enrolled device; cannot be transferred or phished |

---

## Comparison: Authenticator vs Other Passwordless Methods

| Method | Phishing Resistance | User Experience | Best For |
|---|---|---|---|
| Microsoft Authenticator (passwordless) | High (device-bound) | Mobile push approval | General workforce |
| Windows Hello for Business | Very high (TPM-bound) | Biometric/PIN on Windows | Managed Windows endpoints |
| Passkey / FIDO2 security key | Very high (hardware-bound) | Physical key tap | Admin accounts, high-assurance |
| Temporary Access Pass (TAP) | N/A (time-limited bootstrap) | One-time code | New user onboarding only |

---

## Related

- [Temporary Access Pass (TAP)](../tap/README.md) — Bootstrap Authenticator registration for new or passwordless-only users.
- [Passkey (FIDO2)](../passkey/README.md) — Hardware security key and platform passkey deployment.
- [Windows Hello for Business](../../policies/conditional-access/windows-hello/README.md) — TPM-bound passwordless for managed Windows endpoints.
- [Microsoft Authenticator Authentication Method Policy](../../policies/conditional-access/authentication-method-microsoft-authenticator/README.md) — Entra ID policy configuring number matching, contextual push, and passwordless mode.
- [MFA Deployment Guide](../../mfa/README.md) — MFA rollout guide with screenshots.
- [Identity Access Overview](../../../README.md)
