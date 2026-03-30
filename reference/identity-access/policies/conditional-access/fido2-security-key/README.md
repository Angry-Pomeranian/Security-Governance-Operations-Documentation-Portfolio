# Entra ID – AuthN – FIDO2 Security Key

## Overview

**Platform:** Entra ID
**Profile Type:** Authentication Methods Policy

**Description:**
This policy configures **FIDO2 security keys** (passkeys) as an authentication method in Entra ID. FIDO2 keys are the strongest available phishing-resistant credential — private keys are stored in hardware, never transmitted, and are bound to the specific relying party (Entra ID tenant). They cannot be phished, replayed, or extracted.

This policy covers: enabling the FIDO2 method, enforcing attestation to verify key authenticity, and optionally restricting registrations to approved hardware models via AAGUID allowlist. It applies to hardware keys (YubiKey, Feitian) and platform passkeys (Windows Hello, Authenticator passkey, Apple/Google passkeys).

---

## Assignments

### Included Groups

| Group                        | Status | Filter | Filter Mode |
| ---------------------------- | ------ | ------ | ----------- |
| grp-privileged-users         | Active | None   | None        |
| grp-passwordless-pilot       | Active | None   | None        |

> Start with privileged/admin accounts and shared workstation users. Expand to general users after hardware procurement and registration guidance is in place.

### Excluded Groups

| Group                    | Status   |
| ------------------------ | -------- |
| grp-service-accounts     | Excluded |

### Scope Tags

| Selected Tags |
| ------------- |
| Default       |

---

## Configuration Settings

### Enablement

| Setting                    | Value  | Description                                                                                                     |
| -------------------------- | ------ | --------------------------------------------------------------------------------------------------------------- |
| **Enable**                 | Yes    | Activates FIDO2 security keys as a usable authentication method.                                                |
| **Allow self-service setup** | Yes  | Permits users to register keys at `aka.ms/mysecurityinfo` without admin intervention.                           |
| **Target**                 | Pilot group → expand | Begin with privileged accounts and shared workstation users; expand as hardware is procured. |

---

### Attestation & Key Restrictions

| Setting                          | Value         | Description                                                                                                                                                                     |
| -------------------------------- | ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Enforce attestation**          | Yes           | Verifies each registered key against the FIDO Alliance Metadata Service (MDS), confirming it is a genuine, certified FIDO2 authenticator. Required for high-assurance environments. |
| **Key restrictions enforcement** | Allowed list  | When set to **Allowed**, only keys whose AAGUID is in the list below can be registered. Prevents use of uncertified, low-assurance, or consumer-grade keys.                      |

---

### AAGUID Allowlist (Approved Hardware)

AAGUIDs uniquely identify authenticator models. Restrict registration to approved hardware:

| Key Model                    | AAGUID                                 | Notes                          |
| ---------------------------- | -------------------------------------- | ------------------------------ |
| YubiKey 5 NFC                | `2fc0579f-8113-47ea-b116-bb5a8db9202a` | USB-A + NFC                    |
| YubiKey 5C NFC               | `c1f9a0bc-1dd2-404a-b27f-8e29047a43fd` | USB-C + NFC                    |
| YubiKey 5Ci                  | `c5ef55ff-ad9a-4b9f-b580-adebafe026d0` | USB-C + Lightning              |
| Feitian ePass FIDO2          | `833b721a-ff5f-4d00-bb2e-bdda7ec3e0a3` | USB-A, NFC, BLE variant        |
| Microsoft Authenticator (passkey) | `90a3ccdf-635c-4729-a248-9b709135078f` | Mobile passkey (Android/iOS) |

> Full AAGUID catalogue: [FIDO Alliance Metadata Service](https://fidoalliance.org/metadata/)
> Add additional approved models by obtaining their AAGUID from the MDS before procurement.

---

## Who Should Use FIDO2 Keys

| User Type                        | Recommended? | Notes                                                                              |
| -------------------------------- | ------------ | ---------------------------------------------------------------------------------- |
| Global Administrators            | ✅ Required  | Highest-privilege accounts demand hardware-bound credentials                       |
| Privileged/Azure AD role holders | ✅ Required  | All role-eligible accounts should use phishing-resistant auth                      |
| Shared workstation users         | ✅ Preferred | No personal device to register WHfB; hardware key travels with the user             |
| Break-glass accounts             | ✅ Required  | Emergency accounts should use FIDO2 keys stored securely offline                  |
| General workforce (Windows)      | Optional     | WHfB covers this use case; FIDO2 key is a backup/alternative                       |
| Service accounts                 | ❌ Excluded  | Non-interactive accounts; use managed identities or certificate-based auth         |

---

## Policy Rationale

- **Attestation prevents low-quality keys:** without attestation enforcement, a user could register a software-emulated or uncertified FIDO2 device. Attestation verifies the key is genuine hardware meeting FIDO2 standards.
- **AAGUID allowlist enforces procurement control:** only hardware approved via IT procurement can be enrolled, preventing unsupported or unmanaged keys entering the estate.
- **Phishing resistance is architectural:** the FIDO2 private key is scoped to the Entra ID tenant's origin URL — a phishing site with a different URL cannot obtain a valid assertion, even if the user is deceived into visiting it.
- **Break-glass FIDO2 keys:** offline, sealed FIDO2 keys for break-glass accounts are immune to MFA fatigue, SIM-swapping, and all remote attack vectors.

These controls align with:

- Microsoft Secure Score — **Enable phishing-resistant MFA**
- ASD Essential Eight — Multi-factor authentication ML3 (phishing-resistant)
- ISO 27001:2022 — A.5.17 Authentication information, A.8.5 Secure authentication, A.8.2 Privileged access rights

---

## Verification & Monitoring

1. **Entra ID Portal:**
   - Navigate to `Protection → Authentication methods → FIDO2 Security Key`
   - Verify **State** = Enabled, **Enforce attestation** = Yes, **Key restrictions** = Allowed list with AAGUIDs above.

2. **User Registration Check:**
   - `Entra ID → Users → [user] → Authentication methods` — FIDO2 key appears with device name and creation date.
   - Registration report: `Protection → Authentication methods → User registration details` → filter by FIDO2.

3. **KQL — FIDO2 sign-ins:**
   ```kql
   SigninLogs
   | where AuthenticationDetails has "FIDO2 security key"
   | project TimeGenerated, UserPrincipalName, AppDisplayName, Location, ResultType
   | order by TimeGenerated desc
   ```

---

## Feedback Loop

1. **Assumptions:**
   - Hardware keys have been procured from the approved vendor list; AAGUIDs above are pre-loaded.
   - Users with FIDO2 keys have received guidance on registering at `mysecurityinfo` and setting a key PIN.
   - FIDO2 PIN setup is required before registration — users should set a PIN of ≥4 digits (≥6 recommended for admin accounts).

2. **Potential Pitfalls:**
   - Enabling attestation after keys are already registered will not retroactively fail existing registrations — it only applies to new registrations.
   - Keys not in the AAGUID allowlist will fail registration with a generic error; users should be pre-informed of approved models.
   - Attestation enforcement requires the key to be reachable via FIDO Alliance MDS at registration time — air-gapped environments may need special handling.

3. **Validation Steps:**
   - Register a test key from the approved hardware list; confirm registration succeeds with attestation.
   - Attempt to register a non-allowlisted key; confirm registration is blocked.
   - Perform a test sign-in with the registered key; verify sign-in log shows `authenticationMethod = FIDO2 security key`.

---

## Related

- [Passkey (FIDO2) Deployment Guide](../../../../guides/passwordless/passkey/README.md) — Deployment steps, AAGUID reference, and security properties.
- [TAP Authentication Method Policy](../authentication-method-tap/README.md) — Bootstrap FIDO2 key registration for new users.
- [Phishing-Resistant MFA Enforcement](../phishing-resistant-mfa-enforcement/README.md) — CA policy that FIDO2 keys satisfy.
- [PIM Server Access Policy](../pim-server-access/README.md) — FIDO2 keys used for privileged server access via PIM.
- [Windows Hello for Business Policy](../windows-hello/README.md) — Platform passkey alternative for managed Windows endpoints.
