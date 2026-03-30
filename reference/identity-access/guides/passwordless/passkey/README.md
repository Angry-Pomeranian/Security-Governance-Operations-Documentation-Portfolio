# Passkey (FIDO2) — Passwordless Setup

## Overview

Passkeys are phishing-resistant FIDO2 credentials that replace passwords for authentication. A passkey is a cryptographic key pair where the private key is stored on a trusted device or hardware authenticator and never leaves it. Authentication is performed by a challenge-response protocol — the private key signs a challenge from the relying party without transmitting the credential itself.

Microsoft Entra ID supports passkeys as a first-class authentication method. They are the strongest available passwordless option and are recommended for privileged accounts and shared workstations where device-bound credentials (Windows Hello) are not practical.

---

## Passkey Types

| Type | Examples | Use Case |
|---|---|---|
| Hardware security keys | YubiKey 5 series, Feitian ePass | Privileged/admin accounts, shared workstations, break-glass accounts |
| Platform passkeys | Windows Hello for Business, Apple Face ID / Touch ID | Managed user endpoints |
| Mobile passkeys | Microsoft Authenticator (Android/iOS) | Hybrid environments, BYOD with Authenticator enrollment |

---

## Deployment Steps

1. **Enable FIDO2 security keys** in Entra ID:
   - Navigate to: `Entra ID → Protection → Authentication methods → FIDO2 Security Key`
   - Set **Enable** to `Yes`
   - Set **Target** to a pilot group (e.g. `grp-passwordless-pilot`), then expand

2. **Configure FIDO2 settings:**
   - **Allow self-service setup** — `Yes` (allows users to register keys at `mysecurityinfo`)
   - **Enforce attestation** — `Yes` for high-assurance environments (verifies key is a genuine, approved FIDO2 device)
   - **Restrict specific keys by AAGUID** — Optional; limits enrollment to approved hardware (e.g. only YubiKey 5 series)

3. **User registration:**
   - Users navigate to `aka.ms/mysecurityinfo` → Add sign-in method → Security key
   - Insert hardware key, tap when prompted, set a PIN (required for FIDO2)
   - For mobile passkeys (Authenticator): registered via the Authenticator app using the passkey option

4. **Enforce via Conditional Access (recommended):**
   - Create a CA policy targeting privileged accounts requiring **Authentication strength: Phishing-resistant MFA**
   - This ensures only FIDO2 keys, Windows Hello for Business, or certificate-based auth satisfy the requirement — passwords + push MFA do not qualify

---

## Security Properties

| Property | Description |
|---|---|
| Phishing-resistant | Private key never transmitted; bound to the specific relying party (Entra ID tenant) — cannot be reused on a phishing site |
| No shared secrets | No password or symmetric key stored on the server side |
| Device binding | Private key is locked to the hardware or platform authenticator; cannot be exported |
| Replay-resistant | Each authentication uses a unique challenge signed once — captured responses cannot be replayed |

---

## AAGUID Reference (Common Keys)

AAGUIDs are used to identify specific authenticator models when enforcing key restrictions:

| Key | AAGUID |
|---|---|
| YubiKey 5 NFC | `2fc0579f-8113-47ea-b116-bb5a8db9202a` |
| YubiKey 5C NFC | `c1f9a0bc-1dd2-404a-b27f-8e29047a43fd` |
| Feitian ePass FIDO2 | `833b721a-ff5f-4d00-bb2e-bdda7ec3e0a3` |

AAGUIDs for all certified FIDO2 authenticators are published in the [FIDO Alliance Metadata Service](https://fidoalliance.org/metadata/).

---

## Related

- [Microsoft Authenticator Passwordless](../microsoft-auth/README.md) — Mobile-based passwordless using push sign-in.
- [Temporary Access Pass (TAP)](../tap/README.md) — Bootstrap passkey registration for new users.
- [PIM Passwordless Server Access](../servers/README.md) — FIDO2 key usage for privileged server access via PIM.
- [Windows Hello for Business](../../policies/conditional-access/windows-hello/README.md) — Platform passkey for managed Windows endpoints.
- [FIDO2 Security Key Policy](../../policies/conditional-access/fido2-security-key/README.md) — Entra ID policy configuring attestation enforcement and approved AAGUID allowlist.
- [Phishing-Resistant MFA Enforcement Policy](../../policies/conditional-access/phishing-resistant-mfa-enforcement/README.md) — CA policy that FIDO2 keys satisfy.
- [Identity Access Overview](../../../README.md)
