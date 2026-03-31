# Case Study: Identity Security Modernization (Passwordless, MFA & Conditional Access)

**Domain:** Identity & Access Management (IAM)
**Focus Areas:** Passwordless Authentication · Conditional Access · MFA Enforcement · Identity Governance · SOC Telemetry
**Standard Alignment:** ISO/IEC 27001:2022 · Zero Trust Principles · Microsoft Entra ID Security Baselines
**Status:** Implemented and Operationalised

---

## Overview

As the organisation expanded its reliance on cloud services, identity became the primary control plane for security enforcement. Traditional perimeter-based security models were no longer sufficient, and authentication patterns heavily reliant on passwords created unnecessary exposure to credential-based attacks.

This case study documents the modernization of identity security through the implementation of passwordless authentication (Windows Hello for Business, FIDO2, Passkeys), strong MFA enforcement, Conditional Access policies based on identity, device, and context, and Temporary Access Pass for secure onboarding and recovery.

The goal was reducing credential exposure and improving authentication assurance, while keeping the rollout from being the thing that caused a week of helpdesk tickets.

---

## Context & Motivation

Credential phishing, reuse, and token theft were the dominant attack methods we were seeing, and password-based authentication was still the primary pattern for most users. MFA enforcement was inconsistent across services, and without centralised telemetry and policy enforcement, SOC visibility into identity threats was fragmented at best.

The shift to cloud-first access also changed the threat model. With SaaS adoption increasing, identity was the new perimeter, and the controls needed to reflect that. The direction was Zero Trust: strong identity assurance, device trust enforcement, and context-aware access decisions rather than implicit trust based on network location.

---

## Security Challenge

The challenge was not the technical implementation. The challenge was doing it without causing enough friction that users found workarounds, helpdesk volume spiked, or legacy workflows broke in ways that were hard to unpick.

Specific tensions: moving away from passwords without breaking legacy app compatibility, enforcing MFA consistently without causing login fatigue, introducing Conditional Access without over-blocking legitimate access patterns, and supporting onboarding and account recovery securely without reverting to temporary passwords.

---

## Assessment and Planning

The assessment phase mapped out where the actual risk exposure sat. High-risk user personas (privileged roles with PIM access, external B2B users, users accessing sensitive systems) were identified as the starting point for enforcement. Password-only access paths were catalogued, application sensitivity was rated, and device compliance posture via Intune was reviewed to understand what the baseline actually looked like before any policy changes.

Design principles going in were defense in depth (passwordless plus MFA plus Conditional Access, not just one layer), phishing-resistant authentication as the target state, context-aware access, and progressive rollout. Pilot before enforcing broadly.

---

## Implementation

### Authentication Standards

Authentication tiers were defined before any policy was written. Standard users: MFA required, passwordless encouraged. Privileged users: mandatory phishing-resistant authentication, PIM enforced for elevation. High-impact systems: strongest authentication requirements with Conditional Access enforcement.

### MFA Rollout

Introduced MFA enforcement via Conditional Access with pilot groups first to validate login experience and application compatibility, then expanded in controlled waves. Watching sign-in interruption rates and risky sign-in trends during pilots caught issues early enough to fix before broad rollout.

### Passwordless Enablement

**Windows Hello for Business** was the primary passwordless method for managed endpoints. Device-bound authentication using PIN or biometric, resistant to phishing and credential replay. This ended up being the most impactful change in terms of reducing password dependency at scale.

**FIDO2 security keys and passkeys** were used for high-risk users and break-glass scenarios where WHfB wasn't suitable. For scenarios where passkeys were supported across platforms, they were enabled to support modern authentication flows.

**Temporary Access Pass** replaced the previous pattern of temporary passwords and service desk intervention for onboarding and MFA reset scenarios. TAP made the recovery process secure without creating a gap in the authentication model.

### Conditional Access Enforcement

Conditional Access became the core policy engine. Policies covered requiring compliant devices, requiring MFA or phishing-resistant authentication, blocking access from outside Australia, and applying session controls for high-risk scenarios. Every policy went through pilot groups before broader enforcement.

Integration with Intune meant device compliance was a real enforcement gate, not just a reporting metric.

### SOC Integration

Centralised sign-in logs and Conditional Access policy outcomes into Sentinel for SOC monitoring. Risky sign-ins, MFA failures, and CA blocks became visible and queryable. This directly improved triage speed and correlation with endpoint and email threats during investigations.

---

## Outcomes

Reduced reliance on passwords, lower exposure to phishing and credential theft, stronger authentication assurance across all access paths. SOC gained clear insight into authentication attempts, policy enforcement outcomes, and risk signals. Password reset overhead dropped and sign-in experience improved for users on passwordless flows.

From a governance standpoint, identity controls became standardised with a clear enforcement model across all services.

**Key observations:**

Phased rollout is not optional. Piloting with real users and monitoring sign-in interruption rates before broad enforcement is what makes the difference between a controlled rollout and an incident. Passwordless adoption requires enablement, not just enforcement. Users need guidance, working registration flows, and a recovery path that doesn't create a new gap. Telemetry should be operationalised during pilots, not after full deployment. The feedback you get from monitoring Conditional Access outcomes during a pilot is how you catch misconfigurations before they affect everyone.

---

*Organisational identifiers, client data, and commercially sensitive information have been omitted.*
