# Disable USB

## Overview

**Platform:** Windows
**Profile Type:** Administrative Templates

**Description:**
This policy restricts USB device installation to a controlled subset of allowed device classes, preventing unauthorized or removable storage devices from being installed. It applies to the **Intune Pilot – Disable USB** group for testing and validation prior to organization-wide deployment.

The configuration enforces **device installation restrictions** under *System > Device Installation*, in accordance with *company*’s data protection objectives and CIS / Essential Eight control requirements to minimize data exfiltration risks through removable media.

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

### Administrative Templates

**Path:** System → Device Installation → Device Installation Restrictions

| Policy Setting                                                                    | Status   | Details                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| --------------------------------------------------------------------------------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Allow installation of devices that match any of these device IDs                  | Disabled | Prevents device installation by explicit ID.                                                                                                                                                                                                                                                                                                                                                                                                                             |
| Allow installation of devices using drivers that match these device setup classes | Enabled  | Allows only specific device setup classes (below).                                                                                                                                                                                                                                                                                                                                                                                                                       |
| **Allowed Classes (GUIDs)**                                                       | —        | 5C4C3332-344D-483C-8739-259E934C9CC8<br>{36fc9e60-c465-11cf-8056-444553540000}<br>{4D36E97D-E325-11CE-BFC1-08002BE10318}<br>{4d36e96b-e325-11ce-bfc1-08002be10318}<br>{4d36e96c-e325-11ce-bfc1-08002be10318}<br>{4d36e96f-e325-11ce-bfc1-08002be10318}<br>{62f9c741-b25a-46ce-b54c-9bccce08b6f2}<br>{6bdd1fc6-810f-11d0-bec7-08002be2092f}<br>{745a17a0-74d3-11d0-b6fe-00a0c90f57da}<br>{c166523c-fe0c-4a94-a586-f1a80cfbbf3e}<br>{ca3e7ab9-b4c3-4ae6-8251-579ef933890f} |
| Prevent installation of devices not described by other policy settings            | Enabled  | Enforces a default-deny rule for all other device types.                                                                                                                                                                                                                                                                                                                                                                                                                 |

---

## Notes

This configuration effectively **blocks USB storage and unauthorized peripherals** while still allowing functional system and input devices (e.g., keyboards, mice, audio, and essential system components).
It is deployed as a **pilot policy** to assess:

* Compatibility with existing workstation peripherals
* Behavior of Intune device-level vs. user-level targeting
* Impact on legitimate engineering or diagnostic tools

---

### Feedback Loop

1. **Assumptions:**

   * Devices in the pilot group include diverse hardware (docks, headsets, keyboards).
   * Allowed class GUIDs cover essential, non-storage peripherals.

2. **Potential Pitfalls:**

   * USB hubs or docks that present composite devices may require additional class exceptions.
   * Certain webcams and audio interfaces enumerate under blocked storage classes.

3. **Verification:**

   * Review results in **Intune → Devices → Configuration Profiles → Device Installation Restrictions**.
   * Confirm applied registry keys:
     `HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions`
   * Validate enforcement by plugging in test USB devices and checking Event Viewer → **Microsoft-Windows-DriverFrameworks-UserMode/Operational** logs for policy blocks.

---
