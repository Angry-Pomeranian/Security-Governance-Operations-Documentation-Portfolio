# Temporary Access Pass (TAP)

## Overview

A Temporary Access Pass (TAP) is a time-limited, admin-issued passcode that allows a user to sign in and register new authentication methods without requiring existing credentials. TAPs are the recommended bootstrap mechanism for passwordless authentication rollout — they enable a user to register Microsoft Authenticator, a FIDO2 security key, or Windows Hello for Business without ever needing a password.

TAPs can be configured as single-use (invalidated after first use) or multi-use (valid for the configured lifetime period).

---

## When to Use TAP

| Scenario | Why TAP |
|---|---|
| New employee onboarding | User has no existing MFA registered; TAP lets them register Authenticator or a security key on day one |
| Passwordless migration | Bootstrap passkey or WHfB enrollment for users who previously used passwords + SMS MFA |
| Account recovery | User lost phone/key and has no backup MFA methods; admin issues TAP to restore access |
| Admin-initiated re-registration | Force re-registration after suspected credential compromise |
| Shared device setup | Provision initial access on a kiosk or shared workstation |

---

## Prerequisites

- **License:** Entra ID P1 or P2 (included in M365 Business Premium, E3, E5)
- **Admin role:** Authentication Administrator or Global Administrator to issue TAPs
- **TAP policy enabled** in Entra ID Authentication Methods (disabled by default)

---

## Enable TAP in Entra ID

1. Navigate to: `Entra ID → Protection → Authentication methods → Temporary Access Pass`
2. Set **Enable** to `Yes`
3. Set **Target** to a pilot group initially, then expand to all users
4. Configure policy defaults:

| Setting | Recommended Value | Notes |
|---|---|---|
| Minimum lifetime | 60 minutes | Sufficient for most registrations |
| Maximum lifetime | 480 minutes (8 hours) | Cap for high-assurance environments |
| Default lifetime | 60 minutes | What admins get by default when creating a TAP |
| One-time use | Enabled (for new enrollments) | Prevents reuse after first sign-in |

---

## Create a TAP — Entra ID Portal

1. Navigate to: `Entra ID → Users → [select user] → Authentication methods`
2. Click **+ Add authentication method**
3. Select **Temporary Access Pass**
4. Configure duration and whether it is one-time use
5. Copy the generated passcode — it is only shown once

---

## Create a TAP — PowerShell

```powershell
# Requires: Microsoft.Graph PowerShell module
Connect-MgGraph -Scopes "UserAuthenticationMethod.ReadWrite.All"

# Single-use TAP valid for 60 minutes
$tapParams = @{
    isUsableOnce    = $true
    lifetimeInMinutes = 60
}

$tap = New-MgUserAuthenticationTemporaryAccessPassMethod `
    -UserId "j.smith@corp.onmicrosoft.com" `
    -TemporaryAccessPass $tapParams

Write-Host "TAP created: $($tap.TemporaryAccessPass)"
Write-Host "Expires:     $($tap.StartDateTime.AddMinutes($tap.LifetimeInMinutes))"
```

---

## User Experience

1. User navigates to `aka.ms/mysecurityinfo` (or is prompted on first sign-in)
2. When asked for credentials, the user enters the TAP instead of their password
3. User is taken to the security info registration page
4. User selects **Add method** and registers their preferred method (Authenticator, FIDO2 key, Windows Hello)
5. After successful registration, the one-time TAP is invalidated

---

## Security Considerations

| Control | Detail |
|---|---|
| One-time use | TAP is invalidated immediately after its first successful use — cannot be reused even within the validity window |
| Short lifetime | Default 60-minute window minimises exposure if a TAP is intercepted or observed |
| Audit logging | Every TAP creation and use is recorded in Entra ID sign-in logs and audit logs (`AuditLogs` table in Sentinel) |
| Privilege scope | A TAP cannot be used to register authentication methods for a different account or elevate permissions |
| No MFA bypass | TAP satisfies MFA claims; users still land in secure registration flow — cannot skip to sensitive resources directly |

---

## Related

- [Microsoft Authenticator](../microsoft-auth/README.md) — Register Authenticator using a TAP for new users.
- [Passkey (FIDO2)](../passkey/README.md) — Register a hardware security key or platform passkey using a TAP.
- [Windows Hello for Business](../whfb/README.md) — WHfB enrollment can be bootstrapped with a TAP on first sign-in.
- [PIM Passwordless Server Access](../servers/README.md) — Server access via privileged roles after passwordless enrollment.
- [TAP Authentication Method Policy](../../policies/conditional-access/authentication-method-tap/README.md) — Entra ID policy configuring TAP lifetime, one-time use, and group scope.
- [Identity Access Overview](../../../README.md)
