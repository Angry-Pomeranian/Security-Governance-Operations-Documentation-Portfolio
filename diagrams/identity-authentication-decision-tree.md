# Identity Authentication Decision

## Overview

This diagram maps the authentication strength decision tree as implemented across the Conditional Access policies in this portfolio. It shows how authentication methods are evaluated for phishing-resistance, which methods satisfy each Conditional Access enforcement tier, and which policies enforce each tier.

This reflects the policies documented in [`reference/identity-access/policies/conditional-access/`](../reference/identity-access/policies/conditional-access/).

---

## Decision Diagram

```mermaid
flowchart TD
    subgraph UserAttempt["User Initiates Authentication"]
        Login[User accesses\nCloud App or Azure Resource]
    end

    subgraph CAEval["Conditional Access Policy Evaluation"]
        Login --> CAMatch{Which CA policy\napplies?}

        CAMatch -->|Azure Management / PIM roles| PIMPolicy[pim-server-access policy\nRequires: Phishing-Resistant MFA Strength]
        CAMatch -->|All cloud apps — phased rollout| PhishPolicy[phishing-resistant-mfa-enforcement\nRequires: Phishing-Resistant MFA Strength]
        CAMatch -->|Standard app access| StandardPolicy[Standard MFA policies\nRequires: MFA — any method]
    end

    subgraph PhishResistant["Phishing-Resistant Methods — Satisfy Both Policies Above"]
        PIMPolicy --> PRCheck{Authentication\nmethod used?}
        PhishPolicy --> PRCheck

        PRCheck -->|Windows Hello for Business| WHfB[Windows Hello for Business\nCertificate-backed · TPM-bound\nPhishing-resistant ✅]
        PRCheck -->|FIDO2 security key| FIDO2[FIDO2 Security Key\nYubiKey / Feitian / Authenticator passkey\nPhishing-resistant ✅]
        PRCheck -->|Authenticator passkey| Passkey[Microsoft Authenticator — Passkey\nDevice-bound · FIDO2 compliant\nPhishing-resistant ✅]
        PRCheck -->|Certificate-based auth| CBA[Certificate-Based Auth\nSmartcard / PIV\nPhishing-resistant ✅]

        WHfB --> Granted[Access Granted]
        FIDO2 --> Granted
        Passkey --> Granted
        CBA --> Granted
    end

    subgraph NotPhishResistant["NOT Phishing-Resistant — Blocked by PIM / Phishing-Resistant Policies"]
        PRCheck -->|Push notification MFA| PushBlocked[Authenticator Push\nNot phishing-resistant ❌\nVulnerable to MFA fatigue]
        PRCheck -->|TOTP app code| TOTPBlocked[TOTP / Auth App Code\nNot phishing-resistant ❌]
        PRCheck -->|SMS OTP| SMSBlocked[SMS One-Time Password\nNot phishing-resistant ❌\nSIM-swap risk]
        PRCheck -->|Phone call| PhoneBlocked[Phone Call MFA\nNot phishing-resistant ❌]
        PushBlocked --> Blocked[Access Blocked\nBlock page + registration campaign prompt]
        TOTPBlocked --> Blocked
        SMSBlocked --> Blocked
        PhoneBlocked --> Blocked
    end

    subgraph RegistrationPath["Registration Path — New or Migrating Users"]
        Blocked --> TAPIssued{TAP issued\nby admin?}
        TAPIssued -->|Yes| TAPReg[Temporary Access Pass\nOne-time passwordless bootstrap\nMax 60 min · Single use]
        TAPIssued -->|No| Helpdesk[Contact IT Helpdesk\nRequest TAP for registration]
        TAPReg --> EnrolMethod[Enrol phishing-resistant method\nWHfB · FIDO2 key · Authenticator passkey]
        EnrolMethod --> Granted
    end

    subgraph AuthMethodPolicies["Authentication Method Policies — What Can Be Registered"]
        WHfB --- WHfBPolicy[windows-hello policy\nAll users · Device-joined required]
        FIDO2 --- FIDO2Policy[fido2-security-key policy\nAAGUID allowlist · Attestation enforced]
        Passkey --- AuthPolicy[authentication-method-microsoft-authenticator policy\nNumber match required · FIPS optional]
        TAPReg --- TAPPolicy[authentication-method-tap policy\nLifetime ≤ 60 min · Single use · Admin-issued only]
    end
```

---

## Policy Files Referenced

| Policy | File |
|---|---|
| `pim-server-access` | [`reference/identity-access/policies/conditional-access/pim-server-access/README.md`](../reference/identity-access/policies/conditional-access/pim-server-access/README.md) |
| `phishing-resistant-mfa-enforcement` | [`reference/identity-access/policies/conditional-access/phishing-resistant-mfa-enforcement/README.md`](../reference/identity-access/policies/conditional-access/phishing-resistant-mfa-enforcement/README.md) |
| `windows-hello` | [`reference/identity-access/policies/conditional-access/windows-hello/README.md`](../reference/identity-access/policies/conditional-access/windows-hello/README.md) |
| `fido2-security-key` | [`reference/identity-access/policies/conditional-access/fido2-security-key/README.md`](../reference/identity-access/policies/conditional-access/fido2-security-key/README.md) |
| `authentication-method-microsoft-authenticator` | [`reference/identity-access/policies/conditional-access/authentication-method-microsoft-authenticator/README.md`](../reference/identity-access/policies/conditional-access/authentication-method-microsoft-authenticator/README.md) |
| `authentication-method-tap` | [`reference/identity-access/policies/conditional-access/authentication-method-tap/README.md`](../reference/identity-access/policies/conditional-access/authentication-method-tap/README.md) |
