# Case Study: Identity Security Modernization (Passwordless, MFA & Conditional Access)

**Domain:** Identity & Access Management (IAM)
**Focus Areas:** Passwordless Authentication · Conditional Access · MFA Enforcement · Identity Governance · SOC Telemetry
**Standard Alignment:** ISO/IEC 27001:2022 · Zero Trust Principles · Microsoft Entra ID Security Baselines
**Status:** Implemented and Operationalised

---

## Overview

As the organisation expanded its reliance on cloud services, identity became the primary control plane for security enforcement. Traditional perimeter-based security models were no longer sufficient, and authentication patterns heavily reliant on passwords introduced unnecessary exposure to credential-based attacks.

This case study documents the modernization of identity security through the implementation of:

* Passwordless authentication (Windows Hello for Business, FIDO2, Passkeys)
* Strong MFA enforcement
* Conditional Access policies based on identity, device, and context
* Temporary Access Pass (TAP) for secure onboarding and recovery

The initiative focused on reducing credential exposure, improving authentication assurance, and aligning identity controls with a Zero Trust model while maintaining usability for end users.

---

## Context & Motivation

Several key drivers led to this initiative:

* **Password-based authentication remained a primary risk vector**
  Credential phishing, reuse, and token theft continued to be dominant attack methods.

* **Inconsistent MFA enforcement across services**
  Some applications enforced MFA, while others relied on weaker authentication patterns.

* **Limited visibility into authentication risk**
  Without consistent telemetry and policy enforcement, SOC visibility into identity threats was fragmented.

* **Shift to cloud-first access model**
  With SaaS adoption increasing, identity became the new perimeter, requiring stronger and more consistent controls.

* **Alignment with Zero Trust principles**
  The organisation needed to move toward:

  * Strong identity assurance
  * Device trust enforcement
  * Context-aware access decisions

---

## Security Challenge

The primary challenge was implementing stronger identity controls without creating friction that would:

* Disrupt business operations
* Drive users to insecure workarounds
* Increase support overhead

Specific tensions included:

* Moving away from passwords without breaking legacy workflows
* Enforcing MFA consistently without causing login fatigue
* Introducing Conditional Access without over-blocking legitimate access
* Supporting onboarding and recovery securely without reverting to weak controls

---

## Assessment and Planning

The assessment phase focused on identifying risk exposure and defining a staged rollout strategy.

### Key assessment areas:

* **High-risk user personas**

  * Privileged roles (admin access via PIM)
  * External access (B2B users)
  * Users accessing sensitive systems

* **Authentication weaknesses**

  * Password-only access paths
  * Lack of phishing-resistant authentication methods

* **Application sensitivity**

  * Critical SaaS platforms (M365, internal tools, vendor platforms)
  * Systems requiring stronger assurance levels

* **Device trust posture**

  * Managed vs unmanaged devices
  * Compliance alignment with Intune

---

### Design Principles

The implementation was guided by:

* **Defense in depth**
  Passwordless + MFA + Conditional Access

* **Phishing-resistant authentication**
  Prioritising:

  * Windows Hello for Business (biometric/PIN bound to device)
  * FIDO2 security keys / passkeys

* **Context-aware access**
  Based on:

  * Device compliance
  * Location (geo-blocking)
  * Risk signals

* **Progressive rollout**
  Pilot → staged enforcement → full deployment

---

## Implementation Strategy

### 1. Baseline Identity Posture

* Reviewed sign-in logs and authentication methods
* Identified:

  * Password-heavy workflows
  * MFA gaps
  * Risky sign-in patterns

---

### 2. Define Authentication Standards

Authentication tiers were defined:

* **Standard users**

  * MFA required
  * Passwordless encouraged

* **Privileged users**

  * Mandatory phishing-resistant authentication
  * PIM enforced for elevation

* **High-impact systems**

  * Strongest authentication requirements
  * Conditional Access enforcement

---

### 3. MFA Rollout (Foundation Layer)

* Introduced MFA enforcement via Conditional Access
* Pilot groups used to validate:

  * Login experience
  * Application compatibility
* Expanded in controlled waves

---

### 4. Passwordless Enablement

Implemented multiple passwordless methods:

#### Windows Hello for Business (WHfB)

* Device-bound authentication (PIN/biometric)
* Resistant to phishing and credential replay

#### FIDO2 Security Keys / Passkeys

* Hardware-backed or platform-based authentication
* Used for:

  * High-risk users
  * Break-glass scenarios (where appropriate)

#### Passkeys (where supported)

* Enabled modern authentication flows across supported platforms

---

### 5. Temporary Access Pass (TAP)

* Introduced TAP for:

  * Secure onboarding
  * MFA reset scenarios
  * Passwordless enrollment

* Reduced reliance on:

  * Temporary passwords
  * Service desk intervention

---

### 6. Conditional Access Enforcement

Conditional Access became the core policy engine.

Policies included:

* **Require compliant device**

* **Require MFA or phishing-resistant auth**

* **Block access outside Australia (geo-blocking)**

* **Session controls for high-risk scenarios**

* Applied progressively:

  * Pilot groups
  * Business units
  * Full organisation

---

### 7. Integration with Endpoint and Device Compliance

* Integrated with Intune:

  * Only compliant devices allowed access
* Reinforced:

  * Managed device requirement
  * Browser-based access controls

---

### 8. Operationalising Telemetry (SOC Integration)

* Centralised sign-in logs and policy outcomes

* SOC monitoring included:

  * Risky sign-ins
  * MFA failures
  * Conditional Access blocks

* Enabled:

  * Faster triage
  * Better correlation with endpoint and email threats

---

## Security Controls Implemented

* **Phishing-resistant authentication**

  * WHfB
  * FIDO2 / Passkeys

* **MFA enforcement**
  Across all relevant applications

* **Conditional Access policies**

  * Device-based
  * Location-based
  * Risk-based

* **Temporary Access Pass (TAP)**
  For secure onboarding and recovery

* **Privileged access controls**

  * PIM integration
  * Just-in-time access

* **Centralised identity telemetry**
  For SOC monitoring and response

---

## Operational Impact

### Improved Security Posture

* Reduced reliance on passwords
* Lower exposure to phishing and credential theft
* Stronger authentication assurance across all access paths

---

### Increased Visibility

* Clear insight into:

  * Authentication attempts
  * Policy enforcement outcomes
  * Risk signals

---

### User Experience Improvements

* Faster sign-ins via passwordless methods
* Reduced password reset overhead
* More consistent authentication experience

---

### Governance Maturity

* Standardised identity controls
* Clear enforcement model across all services
* Better alignment between identity, endpoint, and security operations

---

## Lessons Learned

* **Phased rollout is critical**
  Immediate enforcement would have caused disruption

* **Passwordless adoption requires enablement, not just enforcement**
  Users need guidance and support

* **Conditional Access must be carefully tuned**
  Overly aggressive policies create friction and exceptions

* **Recovery mechanisms must be secure**
  TAP significantly improved this area

* **Telemetry should be operationalised early**
  Monitoring during pilots provided valuable feedback

---

## Key Takeaways

Identity modernization is most effective when:

* Authentication strength is increased through passwordless methods
* Access decisions are context-aware via Conditional Access
* Identity telemetry is integrated into SOC workflows

A structured, phased approach enables strong security outcomes without disrupting user productivity.

---
* If identity is your primary control plane (true in cloud-first environments)
* And you implemented CA + WHfB + MFA (
