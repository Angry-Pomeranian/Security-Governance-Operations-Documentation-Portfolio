# Windows – AuthN – Windows Hello

## Overview

**Platform:** Windows 10 and later
**Profile Type:** Administrative Templates / Authentication Policy

**Description:**
This configuration profile enforces *company*’s **Windows Hello for Business (WHfB)** and **modern authentication** baseline.
It strengthens credential protection and enables passwordless or hardware-backed authentication using TPM, biometric, or FIDO2 devices.

The policy ensures devices use secure identity verification mechanisms — such as PINs, facial recognition, fingerprint sensors, and security keys — while aligning with Microsoft’s **recommended authentication hardening standards** and **CIS Level 1 Windows baseline** guidance.

---

## Assignments

### Included Groups

| Group      | Status | Filter | Filter Mode |
| ---------- | ------ | ------ | ----------- |
| Test Group | Active | None   | None        |

### Excluded Groups

| Group        | Status |
| ------------ | ------ |
| *No results* |        |

### Scope Tags

| Selected Tags |
| ------------- |
| Default       |

---

## Configuration Settings

### Authentication

| Setting                | Value   | Description                                                                                                                     |
| ---------------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------- |
| **Enable Web Sign-In** | Enabled | Allows sign-in using web-based identity providers (e.g., Entra ID / Azure AD). Required for modern SSO and passwordless logins. |

---

### Device Guard

| Setting              | Value                  | Description                                                                                                                                                                |
| -------------------- | ---------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Credential Guard** | Enabled with UEFI Lock | Uses virtualization-based security (VBS) to isolate and protect credential secrets from theft. The UEFI lock prevents it from being disabled even by local administrators. |

---

### Windows Hello for Business

| Setting                                               | Value   | Description                                                                                                                                                           |
| ----------------------------------------------------- | ------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Dynamic Lock**                                      | Enabled | Automatically locks the device when paired Bluetooth devices (e.g., phone) are out of range, reducing unattended access risk.                                         |
| **Enable ESS with Supported Peripherals**             | Enabled | Enables *Enhanced Sign-in Security* (ESS) for supported biometric hardware. Blocks insecure peripherals and ensures only trusted facial/fingerprint sensors are used. |
| **Facial Features Use Enhanced Anti-Spoofing**        | True    | Enables anti-spoofing AI detection for facial recognition to prevent photo or mask-based bypasses.                                                                    |
| **Use Security Key for Sign-In**                      | Enabled | Allows use of external FIDO2 hardware security keys for Windows logon.                                                                                                |
| **Use Windows Hello for Business (Device)**           | True    | Enables Windows Hello for Business at the device level (TPM-bound authentication).                                                                                    |
| **Use Cloud Trust for On-Prem Auth**                  | Enabled | Enables WHfB *Cloud Trust* — allowing Entra ID–based sign-in to on-prem AD resources without requiring hybrid key trust or certificate trust setup.                   |
| **Use Remote Passport**                               | Enabled | Allows users to authenticate with Windows Hello credentials for remote sign-in sessions.                                                                              |
| **Use Hello Certificates as Smart Card Certificates** | Enabled | Allows WHfB certificates to function as smart card equivalents, supporting legacy systems that require smart card authentication.                                     |
| **Restrict use of TPM 1.2**                           | Enabled | Ensures only TPM 2.0 hardware (or higher) is used for credential protection. TPM 1.2 devices are not trusted for WHfB.                                                |
| **Require Security Device**                           | True    | Mandates that a trusted security device (TPM, biometric sensor, or FIDO2 key) must be present for enrollment.                                                         |

---

### PIN Configuration

| Setting                 | Value   | Description                                                                                                      |
| ----------------------- | ------- | ---------------------------------------------------------------------------------------------------------------- |
| **Minimum PIN Length**  | 6       | Defines the minimum length for Windows Hello PINs.                                                               |
| **PIN History**         | 2       | Prevents reuse of the last two PINs, reducing credential reuse risk.                                             |
| **Uppercase Letters**   | Allowed | Permits uppercase letters in PINs.                                                                               |
| **Lowercase Letters**   | Allowed | Permits lowercase letters in PINs.                                                                               |
| **Digits**              | Allowed | Allows numbers in PINs (recommended for complexity).                                                             |
| **Enable PIN Recovery** | True    | Allows users to reset their Windows Hello PIN using their Entra ID credentials, improving self-service recovery. |

---

## Policy Rationale

This configuration enforces **strong authentication posture** through multi-layered protection:

* **Passwordless security:** Reduces credential theft by using biometric and PIN authentication tied to TPM hardware.
* **VBS isolation:** Protects user credentials with virtualization-based security (Credential Guard).
* **Hardware trust:** Blocks legacy or insecure sensors, ensuring only FIDO2-compliant or TPM 2.0 devices are used.
* **Seamless SSO:** Enables modern authentication through Web Sign-In and Cloud Trust for hybrid environments.

These controls align with:

* Microsoft Secure Score recommendations
* CIS Windows 10/11 Level 1 and Level 2 benchmarks
* Essential Eight “Application Control” and “User Access Hardening” objectives

---

## Verification & Monitoring

1. **Intune Portal:**

   * Go to *Devices → Configuration profiles → Windows – AuthN – Windows Hello* and verify **Device Status** = *Succeeded*.
2. **Local Verification:**

   * Run `dsregcmd /status` → confirm device is Azure AD joined and WHfB enabled.
   * In Event Viewer → *Applications and Services Logs → Microsoft → Windows → HelloForBusiness/Operational*, confirm successful provisioning events.
   * Check Windows Settings → *Accounts → Sign-in options* to verify Hello PIN, biometric, and FIDO2 options are available.
3. **Security Validation:**

   * In Device Guard status (MSInfo32), confirm “Credential Guard: Running”.

---

## Feedback Loop

1. **Assumptions:**

   * Devices are Entra ID joined or Hybrid Azure AD joined.
   * TPM 2.0 and Secure Boot are enabled in BIOS.
   * Users have enrolled biometric or PIN credentials.

2. **Potential Pitfalls:**

   * Non-UEFI or legacy BIOS systems may not support Credential Guard.
   * External fingerprint scanners may fail if not ESS-certified.
   * TPM 1.2 devices will be blocked due to the “Restrict use of TPM 1.2” setting.

3. **Validation Steps:**

   * Confirm WHfB enrollment via **Event ID 300** in *Microsoft-Windows-HelloForBusiness/Operational*.
   * Run `Get-ComputerInfo | Select-Object WindowsHello*` to confirm Hello configuration.
   * Use Microsoft Endpoint Manager compliance reports to verify policy alignment across endpoints.

---
