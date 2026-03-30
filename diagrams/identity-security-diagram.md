# Identity Security Architecture Diagram

## Overview

High-level view of the identity security architecture: users authenticate through the identity platform, MFA and passwordless controls gate access, Conditional Access policies evaluate device and risk signals before granting app access, and all sign-in activity is forwarded to the SIEM for monitoring.

For the specific policy configurations, validation scripts, and implementation guides, see [`reference/identity-access/`](../reference/identity-access/).

---

## Architecture Diagram

```mermaid
flowchart TD
    Users[Users and Administrators] --> IdP[Microsoft Entra ID\nIdentity Platform]
    IdP --> Auth[Authentication Layer]
    Auth --> MFA[MFA Controls\nAuthenticator push · TOTP]
    Auth --> Passwordless[Passwordless Methods\nWHfB · FIDO2 · Passkey · TAP]
    MFA --> CA[Conditional Access Policies\nPhishing-resistant MFA · PIM enforcement]
    Passwordless --> CA
    DeviceSignals[Device Compliance and Risk Signals\nIntune · Defender for Endpoint] --> CA
    CA --> Apps[Enterprise Apps and Cloud Resources]
    IdP --> Logs[Sign-in and Policy Logs\nAudit · SigninLogs · AADNonInteractive]
    Logs --> SIEM[Microsoft Sentinel]
```

---

## Related Documentation

- [`reference/identity-access/guides/passwordless/`](../reference/identity-access/guides/passwordless/) — Passwordless rollout guides (WHfB, FIDO2, Authenticator, TAP, B2C)
- [`reference/identity-access/policies/conditional-access/`](../reference/identity-access/policies/conditional-access/) — All Conditional Access and Authentication Methods policies
- [Identity Authentication Decision diagram](identity-authentication-decision-tree.md) — Detailed decision tree: what satisfies phishing-resistant MFA strength and what does not
