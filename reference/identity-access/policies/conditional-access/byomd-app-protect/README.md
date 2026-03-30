# Intune BYOMD App Protection Documentation

Application Protection for Personally Owned Mobile Devices

---

# 1. Overview

This document defines the configuration and operational model used to secure organizational data on **personally owned mobile devices** using **Microsoft Intune App Protection Policies (MAM)**.

The solution enables users to access corporate applications without requiring full device enrollment into Mobile Device Management (MDM).

Instead of managing the device itself, the organization applies security controls directly to the **applications that access corporate data**.

This approach provides a balance between:

* security enforcement
* user privacy
* operational usability

Corporate data remains protected while the personal device remains unmanaged.

---

# 2. Security Model

## Application Containment

Intune App Protection enforces security controls only within managed applications.

Examples of managed apps include:

* Microsoft Outlook
* Microsoft Teams
* Microsoft OneDrive
* Microsoft Edge
* Microsoft Office applications

These apps operate inside a **policy enforcement container**.

Unmanaged applications remain outside this boundary and cannot access protected corporate data.

---

## Core Security Principle: Data Containment

Corporate data must remain inside managed applications and approved storage locations.

Allowed locations include:

* OneDrive for Business
* SharePoint

Data movement outside the container is restricted unless explicitly allowed.

---

# 3. Policy and Control Alignment

## ISO 27001 Alignment

This configuration supports the following ISO 27001:2022 controls:

| Control                | Description                   |
| ---------------------- | ----------------------------- |
| ISO 27001 Annex A 5.15 | Information transfer controls |
| ISO 27001 Annex A 8.2  | Privileged access management  |
| ISO 27001 Annex A 8.12 | Data leakage prevention       |

These controls require organizations to implement safeguards that prevent unauthorized transfer or exposure of sensitive information.

Reference
[https://learn.microsoft.com/security/iso-27001](https://learn.microsoft.com/security/iso-27001)

---

## Zero Trust Alignment

This architecture follows Microsoft's Zero Trust principles.

| Principle         | Implementation                                      |
| ----------------- | --------------------------------------------------- |
| Verify explicitly | Authentication required in each managed application |
| Least privilege   | Data restricted to managed applications             |
| Assume breach     | Data exfiltration controls enforced                 |

Reference
[https://learn.microsoft.com/security/zero-trust/](https://learn.microsoft.com/security/zero-trust/)

---

## Mobile Application Management Model

Platform architecture:

BYOD Mobile Device
→ App Protection Policies (MAM)
→ Managed Applications Container

This enables application level enforcement without full device management.

Reference
[https://learn.microsoft.com/mem/intune/apps/app-protection-policy](https://learn.microsoft.com/mem/intune/apps/app-protection-policy)

---

# 4. Managed Browser Requirement

Corporate web content must open in **Microsoft Edge**.

This requirement strengthens the security model by ensuring:

* identity based access enforcement
* session control
* data transfer restrictions
* auditability of web access

Allowing unmanaged browsers would break containment and permit uncontrolled data transfer.

---

## Security Benefits of Managed Browser Enforcement

| Security Benefit       | Explanation                                  |
| ---------------------- | -------------------------------------------- |
| Policy enforcement     | Edge is managed by Intune App Protection     |
| Identity binding       | Web sessions tied to corporate identity      |
| Data isolation         | Prevents copying data into personal browsers |
| Security configuration | Enables enterprise security controls         |

---

# 5. Intune App Protection Controls

## Data Transfer Controls

| Control                      | Configuration                   |
| ---------------------------- | ------------------------------- |
| Send org data to other apps  | Policy managed apps only        |
| Receive data from other apps | Allowed                         |
| Cut, copy, paste             | Managed apps only with paste in |
| Character limit              | 30 characters                   |
| Restrict web transfer        | Microsoft Edge only             |

---

## Data Protection Controls

| Control                | Configuration         |
| ---------------------- | --------------------- |
| Encrypt org data       | Required              |
| Prevent backups        | Block                 |
| Save org data locally  | Block                 |
| Allowed save locations | OneDrive / SharePoint |

---

## Device Interaction Controls

| Control           | Configuration |
| ----------------- | ------------- |
| Screen capture    | Disabled      |
| Printing          | Blocked       |
| Org notifications | Allowed       |

---

## Authentication Controls

| Control                   | Configuration |
| ------------------------- | ------------- |
| App PIN required          | Yes           |
| Minimum PIN length        | 4             |
| Biometric allowed         | Yes           |
| Reauthentication interval | 30 minutes    |

---

## Conditional Launch Controls

| Condition                           | Action             |
| ----------------------------------- | ------------------ |
| Jailbroken / rooted device detected | Block              |
| Maximum PIN attempts exceeded       | Reset PIN          |
| Offline grace period exceeded       | Block or wipe data |

---

# 6. Microsoft Edge Security Controls

Microsoft Edge is configured as the managed browser for corporate content.

| Category                | Control                               |
| ----------------------- | ------------------------------------- |
| Identity                | Work account required                 |
| Data separation         | Managed identity isolation            |
| Data leakage prevention | Restrict web transfer to managed apps |
| Session protection      | Disable password autofill             |
| Sync protection         | Disable personal account sync         |
| Security                | SmartScreen enabled                   |

Reference
[https://learn.microsoft.com/deployedge/microsoft-edge-mobile-manage](https://learn.microsoft.com/deployedge/microsoft-edge-mobile-manage)

---

# 7. Android Device Setup (App Protection Only)

## Install Required Applications

Install the following applications from Google Play:

* Microsoft Intune Company Portal
* Microsoft Edge
* Microsoft Outlook
* Microsoft Teams
* Microsoft OneDrive

---

## Sign in to Company Portal

1 Open Company Portal
2 Sign in using corporate email
3 Complete MFA authentication

---

## Stop at Device Enrollment Prompt

During setup the user will see the message:

Set up your device to access email, devices, Wi-Fi and apps.

Users must select **Postpone**.

Selecting **Begin** would enroll the device into full device management which is not required.

---

## Verify Device Status

Open:

Company Portal
Devices

The device status should display:

This device is not managed

---

## Access Work Applications

Users can install and sign in to Microsoft work applications.

Once signed in, App Protection policies automatically apply.

---

## Confirm Protection

The first time an application is opened the user will be prompted to:

* create an application PIN
* enable biometric authentication

This confirms policy enforcement.

---

# 8. iOS Device Setup (App Protection Only)

## Install Required Applications

Install from the App Store:

* Microsoft Intune Company Portal
* Microsoft Edge
* Outlook
* Teams
* OneDrive

---

## Sign in to Company Portal

Open Company Portal and sign in using corporate credentials.

---

## Stop at Enrollment Prompt

When prompted to begin device setup:

Select:

Cancel
Skip
Not now

Do not proceed with enrollment.

---

## Verify Device Status

Company Portal
Devices

Device status should read:

This device is not managed.

---

## Access Work Applications

Users sign into Microsoft applications.

App Protection policies automatically apply.

---

# 9. Common Issues

## Copy Paste Restriction

Message displayed:

Your organization’s data cannot be pasted here.

Reason
Data transfer outside managed apps is blocked.

---

## Android Clipboard Bug

Some Android keyboards incorrectly trigger copy restrictions.

Workaround

Use:

Long press → Paste
or
Paste as plain text

Avoid using keyboard clipboard panels.

---

## Outlook to OneDrive Transfers

Users should first save documents to OneDrive.

Copying between apps may fail due to container restrictions.

---

## Teams Image Download Restrictions

Downloading images to unmanaged locations is blocked.

Recommended alternatives:

* upload images to Teams
* access via corporate laptop

---

# 10. Emergency Policy Change Procedure

If a production issue occurs:

1 Open Intune Admin Center
2 Navigate to App Protection Policy
3 Modify policy settings

Possible mitigations include:

* increasing copy paste limit
* removing affected users from assignment group

Full deletion requires recreating the policy.

---

# 11. References

Microsoft Intune App Protection Policies
[https://learn.microsoft.com/mem/intune/apps/app-protection-policy](https://learn.microsoft.com/mem/intune/apps/app-protection-policy)

Microsoft Edge Mobile Management
[https://learn.microsoft.com/deployedge/microsoft-edge-mobile-manage](https://learn.microsoft.com/deployedge/microsoft-edge-mobile-manage)

Microsoft Zero Trust Model
[https://learn.microsoft.com/security/zero-trust/](https://learn.microsoft.com/security/zero-trust/)
