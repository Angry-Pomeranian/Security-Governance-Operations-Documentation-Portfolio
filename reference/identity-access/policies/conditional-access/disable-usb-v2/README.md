# Disable USB (V2)

## Overview

**Platform:** Windows
**Profile Type:** Administrative Templates

**Description:**
This policy enforces **USB and removable storage access restrictions** on Windows 10 and later devices by denying read and write access to all removable storage classes, including **Windows Portable Devices (WPD)**.

The configuration is designed to prevent unauthorized use of USB storage media and reduce data exfiltration risk, aligning with data protection, DLP, and baseline hardening objectives.

This policy applies to a **pilot device group** for testing and validation prior to broader rollout.

---

## Assignments

### Included Groups

| Group             | Status | Filter | Filter Mode |
| ----------------- | ------ | ------ | ----------- |
| Test Device Group | Active | None   | None        |

### Excluded Groups

| Group               | Status |
| ------------------- | ------ |
| USB Exclusion Group | Active |

### Scope Tags

| Selected Tags |
| ------------- |
| Default       |

---

## Configuration Settings

### Administrative Templates

**Path:** System → Removable Storage Access

| Policy Setting                                 | Status  | Details                                                               |
| ---------------------------------------------- | ------- | --------------------------------------------------------------------- |
| All Removable Storage classes: Deny all access | Enabled | Blocks read and write access to all removable storage device classes. |
| WPD Devices: Deny read access                  | Enabled | Prevents reading data from Windows Portable Devices.                  |
| WPD Devices: Deny write access                 | Enabled | Prevents writing data to Windows Portable Devices.                    |

---

## Notes

This configuration enforces a **hard block on removable storage access**, including USB mass storage and portable media presented via WPD interfaces.

The policy is deployed as a **pilot** to evaluate:

* Effectiveness of removable storage blocking at the OS level
* Impact on devices that rely on portable media for diagnostics or workflows
* Interaction with exclusion groups for approved exceptions

---
