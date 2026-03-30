# Auditor Summary

**Microsoft Edge CIS Level 1 and Level 2 Hardening Policy**

## Policy Objective

This policy implements **CIS Benchmark Level 1 and Level 2 security controls** for Microsoft Edge on Windows 10 and later devices.
Its primary objective is to reduce the risk of data leakage, credential compromise, and malicious browser based activity while preserving user privacy and business usability.

The policy enforces a **secure by default posture** for managed work browsing and is deployed initially as a pilot prior to broader rollout.

---

## Scope and Applicability

**In Scope:**

* Microsoft Edge (Chromium) on Windows 10 and later
* Managed Work browser profiles
* Extension installation and browser feature controls
* InPrivate browsing behavior

**Out of Scope:**

* Personal browser profiles
* Non Chromium browsers
* Legacy Internet Explorer outside IE mode controls

---

## Control Coverage Summary

### Identity and Access Control

**Control intent:** Prevent unauthorized browser identities and profile misuse.

**Key controls enforced:**

* Browser sign in restricted to managed work accounts
* Guest and ephemeral profiles disabled
* External links open in the primary work profile

**Risk addressed:**
Unauthorized account usage, profile sprawl, and identity mixing between personal and work contexts.

---

### Data Protection and Credential Security

**Control intent:** Prevent credential leakage and uncontrolled data synchronization.

**Key controls enforced:**

* Password saving, importing, and exporting disabled
* Autofill for addresses and payment instruments disabled
* Browser data import from other browsers blocked
* Passwords excluded from any synchronization capability

**Risk addressed:**
Credential reuse, unmanaged password storage, and silent data exfiltration via browser sync features.

---

### Extension Governance and InPrivate Enforcement

**Control intent:** Minimize extension based attack surface and ensure security controls remain active in private browsing.

**Key controls enforced:**

* Default deny extension model
* Explicit allow list and force installed security extensions
* Explicit block on remote access extensions
* InPrivate browsing allowed only when required security extensions are enabled

**Required security extensions for InPrivate browsing:**

* Microsoft Single Sign On
* Proofpoint ZenWeb (DLP enforcement)

**Risk addressed:**
Malicious or unvetted extensions, bypass of security controls via InPrivate mode, and remote access abuse.

---

### Web Platform and Privacy Hardening

**Control intent:** Reduce browser level attack surface and tracking exposure.

**Key controls enforced:**

* JavaScript JIT disabled
* Web Bluetooth, WebHID, and Serial API blocked
* Mixed content loading blocked
* Geolocation blocked by default
* Tracking prevention enabled

**Risk addressed:**
Client side exploitation, hardware access abuse, fingerprinting, and excessive telemetry.

---

### Threat Protection and Anti Abuse Controls

**Control intent:** Protect users from malicious content and social engineering.

**Key controls enforced:**

* Microsoft Defender SmartScreen enabled
* Blocking of potentially unwanted applications
* Prevention of SmartScreen bypass
* Website typo protection enabled

**Risk addressed:**
Phishing, malware delivery, typosquatting, and unsafe downloads.

---

## Alignment to Security Frameworks

**CIS Benchmarks:**

* CIS Microsoft Edge Benchmark Level 1
* CIS Microsoft Edge Benchmark Level 2

**Essential Eight (Australian Signals Directorate):**

* Application control
* Restrict administrative privileges
* Patch applications
* User application hardening

**General compliance alignment:**

* Data loss prevention principles
* Least privilege
* Defense in depth

---

## Operational Assurance

**Enforcement mechanism:**
Microsoft Intune device configuration profiles with device level enforcement.

**Verification methods:**

* Edge policy inspection via `edge://policy`
* Extension state validation via `edge://extensions`
* Intune compliance and configuration reporting
* Event log inspection for policy enforcement

**Exception handling:**
Approved exclusions are managed through group based targeting and documented exceptions.

---

## Auditor Notes

* The policy intentionally distinguishes between Work and Personal browser profiles to preserve user privacy.
* InPrivate browsing is not disabled outright but is conditionally restricted to ensure security tooling remains active.
* Recommended extensions are approved but not force installed to avoid unnecessary user impact.

This control set represents a **balanced implementation** of CIS L1 and L2 guidance suitable for enterprise environments requiring strong browser security without prohibitive usability constraints.

---
