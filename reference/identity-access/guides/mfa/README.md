# Microsoft Entra MFA — Deployment Guide

This guide covers enabling multifactor authentication for all users via a Conditional Access policy in Microsoft Entra ID. MFA blocks over 99% of identity-based attacks and is the single highest-impact security control available in the Microsoft 365 ecosystem.

---

## 1. Overview — Securing User Sign-ins

<img width="2400" height="1358" alt="1_Securing-User-Sign-ins-with-Microsoft-Entra-Multifactor-Authentication" src="https://github.com/user-attachments/assets/1f236126-c53e-470f-a97c-462fdb2e41b7" />

MFA requires users to verify their identity with a second factor at sign-in — something they have (Authenticator push, FIDO2 key) or something they are (biometric). A stolen password alone is not sufficient to complete authentication.

This guide uses **Conditional Access** (not legacy per-user MFA) to enforce MFA, which provides greater control, better reporting, and support for exclusions.

---

## 2. Understanding Multifactor Authentication

<img width="2400" height="1350" alt="2_Understanding-Multifactor-Authentication" src="https://github.com/user-attachments/assets/32c8d72a-970c-49af-8d26-3ec0406d0ff7" />

**Supported MFA methods (strongest to weakest):**

| Method | Phishing-Resistant | Recommended |
|---|---|---|
| FIDO2 security key | Yes | Privileged accounts |
| Windows Hello for Business | Yes | Managed Windows endpoints |
| Microsoft Authenticator (passwordless) | Yes | All users |
| Microsoft Authenticator (number match push) | Partial | All users (fallback) |
| OATH hardware token | No | Limited use |
| SMS / Voice call | No | Avoid — legacy, SIM-swappable |

**Avoid SMS/voice:** These methods are vulnerable to SIM swap attacks and do not satisfy phishing-resistant MFA requirements.

---

## 3. Prerequisites

<img width="2400" height="1350" alt="3_Prerequisites-for-Implementation" src="https://github.com/user-attachments/assets/db975252-1d8c-4a41-b64c-8acc03f1875f" />

Before creating the CA policy:
- **License:** Entra ID P1 or P2 (M365 Business Premium, E3, E5)
- **Security Defaults disabled:** Security Defaults and Conditional Access are mutually exclusive — disable Security Defaults first (`Entra ID → Properties → Manage Security Defaults → Disabled`)
- **Admin role:** Conditional Access Administrator or Global Administrator
- **Exclusion group created:** Create a group (e.g. `grp-ca-mfa-exclude`) for emergency break-glass accounts before enabling the policy

---

## 4. Creating a Conditional Access Policy

<img width="2400" height="1350" alt="4_Creating-a-Conditional-Access-Policy" src="https://github.com/user-attachments/assets/770f23df-6eeb-4163-88c5-d1a9a5424165" />

1. Navigate to: `Entra ID → Protection → Conditional Access → Policies → + New policy`
2. Name the policy (e.g. `CA001 — Require MFA for all users`)
3. **Assignments — Users:**
   - Include: `All users`
   - Exclude: `Directory roles: Global Administrator` (covered by a separate stricter policy), your break-glass exclusion group
4. **Assignments — Target resources:**
   - Include: `All cloud apps`
5. **Conditions:** Leave all conditions at default (no location, device, or risk conditions at this stage)

---

## 5. Configuring the MFA Policy

<img width="2400" height="3678" alt="5_Configuring-the-MFA-Policy" src="https://github.com/user-attachments/assets/2f62f5f8-efdf-41b8-91d7-c8b1549cd353" />

6. **Access controls — Grant:**
   - Select: `Grant access`
   - Check: `Require multifactor authentication`
   - For: `All the selected controls`
7. **Enable policy:**
   - Start with `Report-only` — this logs what would have happened without blocking users
   - After 1–2 weeks of report-only validation, switch to `On`
8. Click **Create**

---

## 6. Testing the MFA Implementation

<img width="2400" height="1350" alt="6_Testing-the-MFA-Implementation" src="https://github.com/user-attachments/assets/c62d5cd9-84f8-4e42-9345-017fa8685534" />

**In report-only mode:**
- Sign in as a test user → Entra ID → Sign-in logs → find the sign-in → `Conditional Access` tab → confirm the policy shows as `Would have applied — Require MFA`

**After switching to On:**
- Sign in as a non-admin test user → confirm MFA prompt appears
- Confirm sign-in fails if MFA is rejected

**Check CA sign-in logs for policy failures:**
- Entra ID → Monitoring → Sign-in logs → filter by Policy name → review `Failure` entries

---

## 7. MFA Registration and Verification Process

<img width="2400" height="1350" alt="7_MFA-Registration-and-Verification-Process" src="https://github.com/user-attachments/assets/62526bc1-9366-496e-810f-afe05694e9c1" />

Users who have not yet registered MFA will be prompted on their next sign-in to complete registration at `aka.ms/mysecurityinfo`.

**To enforce registration proactively:** Use the built-in **Microsoft Entra Authentication methods → Registration campaign** to prompt users over a defined number of days.

**Recommended methods to enable in Authentication Methods policy:**
- Microsoft Authenticator (push + passwordless phone sign-in)
- FIDO2 Security Key
- Temporary Access Pass (for initial setup only)
- *Disable:* SMS, Voice call

---

## 8. Next Steps and Resource Management

<img width="2400" height="1350" alt="8_Next-Steps-and-Resource-Management" src="https://github.com/user-attachments/assets/40434019-94d9-4304-9a75-f89e21b2fcbb" />

After MFA is fully enforced, consider these incremental improvements:

| Next Step | Purpose |
|---|---|
| Upgrade to Authentication Strengths | Require phishing-resistant MFA (FIDO2 / WHfB) for admin and sensitive apps |
| Enable number matching on Authenticator | Prevent MFA fatigue attacks — requires users to enter a matching number |
| Add risk-based conditions | Require MFA step-up only when sign-in risk is Medium/High (reduces friction) |
| Create a separate admin MFA policy | Admins require phishing-resistant MFA specifically |
| Monitor with Sentinel | KQL on `SigninLogs` for CA policy failures; build workbook for MFA coverage gaps |

---

## Related

- [Microsoft Authenticator Setup](../passwordless/microsoft-auth/README.md) — Deploy the recommended MFA method.
- [Temporary Access Pass](../passwordless/tap/README.md) — Bootstrap MFA registration for new users.
- [Windows Hello for Business](../passwordless/whfb/README.md) — Upgrade from MFA to phishing-resistant passwordless.
- [Conditional Access Policy Reference](../../policies/conditional-access/README.md)
- [Identity Access Overview](../../README.md)
