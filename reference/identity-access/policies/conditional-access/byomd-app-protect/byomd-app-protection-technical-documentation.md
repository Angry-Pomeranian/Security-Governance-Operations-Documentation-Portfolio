# BYOMD App Protection Technical Documentation

## Document Purpose

This document defines the technical and operational model for **BYOMD** using **Microsoft Intune App Protection Policies**. 

It documents how organizational data is protected on personally owned mobile devices without requiring full device enrollment.

**BYOMD** refers to a personally owned mobile device access model where work data is protected through application-level controls without requiring full device enrollment.

This model is intended to support secure access to work applications and work data while maintaining separation between personal and corporate use on mobile devices.

---

## 1. Overview

### 1.1 Objective

The objective of this configuration is to:

- prevent organizational data from leaving the managed application boundary on personally owned devices
- maintain enforceable application-level controls for work data
- preserve identity assurance and policy enforcement
- allow secure access to work resources without full device management

### 1.2 BYOMD Model

This approach uses **App Protection only**, not full mobile device management.

BYOMD provides a middle ground between:

- full device management, which introduces higher user friction
- weak or absent app protection, which introduces higher data leakage risk

Under this model:

- personal devices remain personally owned and are not fully enrolled into Intune device management
- organizational data is accessed only through protected applications
- policy controls apply inside the managed application boundary
- unmanaged applications remain outside the enforcement boundary

### 1.3 Core Security Principle

**Data Containment**

App Protection policies enforce restrictions only within managed applications. Because unmanaged applications are outside the protection boundary, the model requires corporate data to remain within approved and policy-managed apps.

---

## 2. Policy and Control Alignment

### 2.1 ISO 27001 Annex A Alignment

This configuration supports the following ISO 27001 Annex A controls:

- **ISO 27001 Annex A 5.15**: Information transfer
- **ISO 27001 Annex A 8.2**: Privileged access management
- **ISO 27001 Annex A 8.12**: Data leakage prevention

These controls are supported through application-level restrictions on:

- data transfer between apps
- protected access to organizational content
- enforcement of PIN and biometric controls
- containment of web content within an approved managed browser
- prevention of backup and uncontrolled copying of organizational data

### 2.2 Zero Trust Alignment

This configuration supports the following Zero Trust principles:

- **Verify explicitly**
- **Least privilege**
- **Assume breach**

Allowing unmanaged browsers or unmanaged applications to handle organizational data weakens these principles by reducing containment, auditability, and control over data movement.

### 2.3 Mobile Application Management Alignment

This model aligns to Mobile Application Management best practice for unmanaged devices through:

- personally owned mobile devices
- Intune App Protection Policies
- policy-managed applications
- restriction of organizational data transfer to other policy-managed apps
- use of Microsoft Edge as the managed browser for work-related web access

### 2.4 Policy Premise

App Protection policies enforce restrictions only within managed applications. Unmanaged applications sit outside the enforcement boundary.

### 2.5 Policy Objective

Prevent organizational data from leaving the managed application container on personally owned devices while maintaining enforceable policy controls and identity assurance.

---

## 3. Architecture and Enforcement Model

### 3.1 Enforcement Boundary

The enforcement boundary exists at the **application layer**, not the device layer.

This means:

- policy is enforced inside approved and policy-managed applications
- unmanaged apps are not controlled by App Protection policy
- data leaving a managed app into an unmanaged app reduces control and assurance
- browser-based access to work content must remain inside a managed browser

### 3.2 Why Microsoft Edge Is Required

Microsoft Edge is required for protected work-related web access on BYOMD devices.

#### Security value of requiring Edge

- work URLs open in a policy-managed browser
- policy enforcement remains continuous across app-to-web workflows
- identity binding is preserved
- auditability is strengthened
- accidental mixing of personal and work data is reduced
- future hardening opportunities are enabled, including CIS baselines and app configuration policies

### 3.3 Policy Interpretation

The browser requirement is not based on personal preference. It is based on containment and enforceable control.

Using unmanaged browsers would contradict:

- least privilege
- controlled information transfer
- application-layer data protection objectives

---

## 4. Risk Scenarios and Control Interpretation

### 4.1 Preference Objections

**Scenario:** A user prefers another browser.

**Interpretation:** The policy requirement is not based on personal choice. It is based on containment, auditability, and security.

### 4.2 Low Likelihood Objections

**Scenario:** A user argues the risk is unlikely.

**Interpretation:** Even if the likelihood appears low, the impact remains high. The control is justified because the policy is intended to reduce the consequences of data leakage, uncontrolled transfer, or mixed personal and corporate handling.

### 4.3 Device Loss or Theft

**Scenario:** A BYOMD phone is lost or stolen.

**Interpretation:** App Protection with managed applications and managed browser access supports selective removal of corporate app data without requiring full device management.

---

## 5. BYOMD Rationale

BYOMD provides a privacy-preserving middle ground between:

- full device management, which introduces high friction
- weak or absent App Protection, which introduces high risk

BYOMD is allowed for phones only with strong application-level containment as a compensating control.

---

## 6. Supported Technical Controls

### 6.1 Intune App Protection Policy Controls

| Control Category | Specific Control |
|---|---|
| Data Transfer | Restrict cut, copy, and paste between apps |
| Data Transfer | Only allow sending organizational data to other policy-managed apps |
| Data Transfer | Restrict web content transfer with other apps |
| Encryption | Encrypt app data |
| Access Requirements | Require PIN or biometrics |
| Conditional Launch | Block access on jailbroken or rooted devices |
| Data Protection | Disable backup of organizational data |

### 6.2 Microsoft Edge Mobile Security Controls

| Category | Control |
|---|---|
| Identity | Require work account sign in |
| Data Separation | Managed app identity isolation |
| Data Leakage | Restrict web content to managed apps |
| Session Control | Block saving passwords and autofill |
| Data Protection | Disable sync for personal accounts |
| Security | SmartScreen enabled |

---

## 7. Android Intune App Protection Policy Configuration

### 7.1 Policy Overview

**Policy name:** `MEM - Android - Office Protection Policy`  
**Platform:** Android  
**Status:** Active

**Description:**  
This policy requires that mobile devices accessing company data are protected with application-level security controls, including encryption, data loss prevention, and access restrictions.

### 7.2 App Targeting

- Target to apps on all device types: **Yes**
- Public apps: **All Microsoft Apps**

#### Custom apps

- `com.microsoft.copilot`
- `com.microsoft.ramobile`
- `com.microsoft.rdc.android`
- `com.microsoft.stream`

### 7.3 Data Protection Settings

#### Data Handling

- Prevent backups: **Block**
- Save copies of org data: **Block**

#### Allowed save locations

- OneDrive for Business
- SharePoint

### 7.4 Data Transfer Controls

#### Sending org data

- Send org data to other apps: **Policy managed apps**

#### Exempt apps

- Android dialer and telephony service
- `com.android.phone`
- Android settings content provider
- `com.android.providers.settings`
- Android Settings UI
- `com.android.settings`
- Google Play Store
- `com.android.vending`
- Microsoft Teams mobile application
- `com.microsoft.teams`
- SMS messaging applications
- `com.google.android.apps.messaging`
- `com.android.mms`
- `com.samsung.android.messaging`

#### Receiving data

- Receive data from other apps: **All apps**

#### Clipboard restriction

- Restrict cut, copy, and paste between other apps: **Policy managed apps with paste in**
- Cut and copy character limit: **30 characters**

### 7.5 Telephony and Messaging Controls

- Transfer telecommunication data to: **Any dialer app**
- Transfer messaging data to: **Any messaging app**

### 7.6 Open In and Content Controls

- Open data into org documents: **Allow**

#### Allowed sources

- OneDrive for Business
- SharePoint
- Camera
- Photo Library

#### Web content restriction

- Restrict web content transfer with other apps: **Microsoft Edge**

### 7.7 Device Interaction Controls

- Screen capture and Google Assistant: **Disable**
- Printing org data: **Block**
- Org data notifications: **Allow**

### 7.8 Keyboard Configuration

- Approved keyboards required: **Not required**

#### Known keyboards not enforced

- Gboard
- `com.google.android.inputmethod.latin`
- SwiftKey
- `com.touchtype.swiftkey`
- Samsung Keyboard
- `com.sec.android.inputmethod`
- `com.samsung.android.honeyboard`
- Google Indic Keyboard
- `com.google.android.apps.inputmethod.hindi`
- Google Pinyin Input
- `com.google.android.inputmethod.pinyin`
- Google Japanese Input
- `com.google.android.inputmethod.japanese`
- Google Korean Input
- `com.google.android.inputmethod.korean`
- Google Handwriting Input
- `com.google.android.apps.handwriting.ime`
- Google voice typing
- `com.google.android.googlequicksearchbox`
- Samsung voice input
- `com.samsung.android.svoiceime`

### 7.9 Encryption

- Encrypt org data: **Require**
- Encrypt org data on enrolled devices: **Require**
- Sync policy managed app data with native apps or add-ins: **Allow**

### 7.10 Access Requirements

- PIN required: **Yes**
- PIN type: **Numeric**
- Simple PIN allowed: **Yes**
- Minimum PIN length: **4**
- Biometrics allowed: **Yes**
- App PIN required when device PIN is set: **Require**
- Recheck access requirements after inactivity: **30 minutes**

### 7.11 Conditional Launch Settings

| Condition | Value | Action |
|---|---|---|
| Max PIN attempts | 5 | Reset PIN |
| Offline grace period | 720 minutes | Block access |
| Offline grace period | 90 minutes | Wipe data |
| Jailbroken or rooted device | Detected | Block access |

### 7.12 Assignments

#### Included groups

- `Intune - Microsoft Protection Policy`

#### Excluded groups

- None

#### Scope tag

- Default

---

## 8. Step-by-Step Guide: Android Device Setup (App Protection Only)

### 8.1 Purpose

This process enables secure access to work apps and data without fully enrolling a personal device into device management.

### 8.2 Install Required Apps

#### Install Microsoft Intune Company Portal

1. Open the Google Play Store.
2. Search for **Company Portal**.
3. Tap **Install**.

#### Install Microsoft Edge

1. Open the Google Play Store.
2. Search for **Microsoft Edge**.
3. Tap **Install**.

Microsoft Edge is required to securely open work-related links from apps such as Outlook and Teams.

### 8.3 Sign in to Company Portal

1. Open the Company Portal app.
2. Tap **Sign In**.
3. Enter work email.
4. Proceed through sign-in.
5. Complete MFA.

### 8.4 Stop at the Setup Prompt

When prompted with:

> **Set up your device to access your email, devices, Wi-Fi, and apps for work**

Select **Postpone**.

**Do not select Begin.**

#### Reason

Selecting **Begin** will fully enroll the device into Intune device management. Full device enrollment is not required and is not supported for personal devices under this BYOMD model.

Selecting **Postpone** allows secure access to work apps while keeping the device personal.

### 8.5 Confirm Device Status

1. Open **Company Portal**
2. Go to **Devices**
3. Select the phone
4. Confirm the status shows:

> **This device is not managed**

This confirms the phone is not fully enrolled and is using the App Protection access path.

### 8.6 Access Work Apps

1. Install Microsoft work apps such as Outlook, Teams, OneDrive, and Edge from the Play Store.
2. Sign in using the work account.
3. App Protection policies apply automatically.

### 8.7 Use Web Links Securely

- work-related links opened from managed apps must open in **Microsoft Edge**
- personal browsers may still be used for personal activity
- unmanaged browsers are not supported for protected work content

If Microsoft Edge is not installed, links may fail to open.

### 8.8 Confirm Access

Users may be prompted to:

- create an app PIN
- enable biometric access

This confirms that App Protection is active.

Users do not need to complete device enrollment or create a work profile.

---

## 9. Step-by-Step Guide: iOS Device Setup (App Protection Only)

### 9.1 Purpose

This process enables secure access to work apps and data without fully enrolling a personal device into device management.

### 9.2 Install Required Apps

#### Install Microsoft Intune Company Portal

1. Open the App Store.
2. Search for **Company Portal**.
3. Install the app.

#### Install Microsoft Edge

1. Open the App Store.
2. Search for **Microsoft Edge**.
3. Install the app.

Microsoft Edge is required to securely open work-related links from apps such as Outlook and Teams.

### 9.3 Sign in to Company Portal

1. Open the Company Portal app.
2. Sign in using the work or school account.

### 9.4 Stop at the Device Setup Prompt

When prompted to begin device setup or enrollment:

- select **Cancel**
- select **Skip**
- select **Not now**
- select **Postpone**

Do not proceed with device enrollment.

#### Reason

Proceeding would fully enroll the device into Intune management, which is not required for personal devices under this BYOMD model.

### 9.5 Confirm Device Status

1. Open **Company Portal**
2. Go to **Devices**
3. Confirm the phone shows:

> **This device is not managed**

### 9.6 Access Work Apps

1. Install Microsoft work apps such as Outlook, Teams, OneDrive, and Edge from the App Store.
2. Sign in using the work account.
3. App Protection policies apply automatically.

### 9.7 Use Web Links Securely

- work-related links opened from managed apps must open in **Microsoft Edge**
- unmanaged browsers are not supported for protected work content

### 9.8 Confirm Access

Users may be prompted to:

- create an app PIN
- enable biometric access

This confirms secure access is enabled.

### 9.9 Important Notes

- this setup uses **application-level protection only**, not full device management
- personal apps, data, and settings remain private
- only approved work apps and web access via Microsoft Edge are protected

---

## 10. Outlook Sign-In and Authentication Experience

When users access managed work apps:

- the applications are managed by the organization
- PIN entry may be required
- biometric confirmation may be required

This confirms application-level security is active.

Personal accounts remain separate from work accounts, and users can switch profiles where supported.

---

## 11. Common Issues and Workarounds

### 11.1 Issue 1: Copy from Managed App to Unmanaged App Is Blocked

**Message:**  
`Your organization's data cannot be pasted here. Only 30 characters allowed.`

**Reason:**  
This restriction exists to reduce the risk of organizational data exfiltration outside the managed application boundary.

**Action:**  
If the transfer is occurring between managed apps and still fails, contact the Service Desk.

### 11.2 Issue 2: Android Copy and Paste Between Managed Apps Shows a False Error

**Workaround:**

- use **long press > Paste**
- use **Paste as plain text**

**Do not use:**

- keyboard clipboard panel

### 11.3 Issue 3: Copy and Paste from Outlook to OneDrive

**Workaround:**  
Save the document into OneDrive first, then perform the copy or paste action inside OneDrive.

### 11.4 Issue 4: Prompted for PIN When Accessing Personal Email in Outlook

**Explanation:**  
The user may need to switch profiles inside Outlook.

**Action:**  
Swipe to the personal account profile to access personal mail.

### 11.5 Issue 5: Cannot Download Images from Teams

**Workarounds:**

- use a work laptop if required
- upload images directly to Teams instead
- keep transfers within managed apps where possible

### 11.6 Issue 6: Copy and Paste into Personal SMS for On-Call Use

**Behavior:**

- a small phone number or short text copy is allowed
- image sharing is disabled

**Reason:**  
This supports limited operational use while reducing data leakage risk.

**Alternative:**  
Dial directly from the Teams contact card where available.

### 11.7 Issue 7: Emergency Policy Disable

Possible administrative actions include:

- modifying or removing the word count or character limit in the App Protection policy
- removing a user from policy assignment
- recreating the policy if full removal of certain settings is required

---

## 12. Operational Notes

### 12.1 What This Model Does

- protects organizational data at the application layer
- allows work access on personal phones without full enrollment
- restricts data movement outside approved applications
- requires Microsoft Edge for protected work web access
- enforces PIN, biometric, encryption, and conditional launch controls

### 12.2 What This Model Does Not Do

- it does not fully manage the personal device
- it does not apply full device-level Intune management
- it does not enforce controls inside unmanaged personal apps
- it does not permit unrestricted browser choice for work content

---

## 13. Summary

The BYOMD App Protection model is designed to provide secure and enforceable access to corporate data on personally owned mobile devices through application-level controls.

Its effectiveness depends on four key principles:

1. organizational data remains inside policy-managed apps
2. protected web content opens only in Microsoft Edge
3. access is gated by PIN, biometric, encryption, and conditional launch controls
4. personal devices remain outside full device enrollment unless a different management model is explicitly adopted

This makes BYOMD a practical security model for mobile access where privacy, usability, and data containment must all be balanced.

---

## 14. References

- Microsoft Learn, App Protection Policies Overview
- Microsoft Learn, Manage Microsoft Edge Mobile
