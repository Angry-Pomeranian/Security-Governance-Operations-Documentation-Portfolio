# Config Refresh – Windows

## Overview

**Platform:** Windows
**Profile Type:** Configuration Refresh

**Description:**
This policy enforces a **scheduled configuration refresh** for all managed Windows devices.
By enabling Configuration Refresh, *company* ensures that local Group Policy Object (GPO) and MDM settings are automatically re-applied at a fixed cadence — preventing drift, tampering, or manual modification of system configurations.

The policy runs at regular intervals to **reassert compliance** with Intune-managed baselines and maintain consistent device posture across the environment.

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

**Path:** Configuration Refresh

| Setting                       | Value   | Description                                                                         |
| ----------------------------- | ------- | ----------------------------------------------------------------------------------- |
| **Config Refresh**            | Enabled | Enables periodic enforcement of Intune configuration policies.                      |
| **Refresh Cadence (minutes)** | 30      | Forces devices to re-apply all MDM-managed configuration settings every 30 minutes. |

---

## Policy Rationale

Configuration drift — when local device settings diverge from Intune baselines — can lead to **inconsistent policy enforcement**, **security risk**, or **compliance violations**.
This policy mitigates those risks by automatically restoring compliant configurations at a defined interval, ensuring that all security, compliance, and application baselines remain active.

Key benefits:

* **Security:** Prevents unauthorized local changes to system or security settings.
* **Reliability:** Ensures settings remain applied even if temporary local overrides occur.
* **Compliance:** Supports continuous adherence to CIS, ISO 27001, and Essential Eight standards.

---

## Verification & Monitoring

To confirm proper operation:

1. In Intune → **Devices → Configuration profiles → Config Refresh – Windows**, verify **Device Status** shows *Succeeded* for all endpoints.
2. On a managed device, open **Settings → Accounts → Access work or school → Info**, and check for “Last Config Refresh” timestamps updating at ~30-minute intervals.
3. Optionally, review the Windows event log under
   **Applications and Services Logs → Microsoft → Windows → DeviceManagement-Enterprise-Diagnostics-Provider (Admin)**
   for periodic refresh events (Event ID 813).

---

## Feedback Loop

1. **Assumptions:**

   * Devices are Intune-enrolled and connected to the MDM service.
   * Refresh cadence is measured in minutes (default minimum: 30).
   * No conflicting Configuration Refresh policies are assigned to the same device.

2. **Potential Pitfalls:**

   * Excessively short refresh intervals can increase network traffic or CPU usage.
   * Offline devices will only refresh once reconnected to the corporate network or MDM.

3. **Validation Steps:**

   * Confirm refresh enforcement via event logs and policy timestamps.
   * Compare device configuration drift reports before and after applying this policy.
   * Use **Intune Device Compliance reports** to validate consistent posture across endpoints.


---

## IF HAVING SYNC ISSUES WITH INTUNE PLEASE SEE BELOW!

# Intune Configuration Refresh Validation Script: Check-ConfigRefresh.ps1

## Overview

This PowerShell script provides a **non-administrative diagnostic check** for verifying whether **Intune Configuration Refresh** is enabled and functioning correctly on a Windows device.

It is designed to help users and IT staff **confirm MDM policy health** and identify whether a device is properly reapplying configuration baselines — without needing elevated privileges or access to the Intune Admin Center.

---

## Purpose

**Configuration Refresh** is an Intune feature that periodically reapplies MDM-managed settings (such as device restrictions, compliance rules, and configuration profiles) to prevent configuration drift.

When a device appears **out of sync** or **non-compliant**, this script helps determine:

* Whether the scheduled MDM maintenance tasks are active.
* If the **Config Refresh** registry keys are present and healthy.
* How frequently Intune is re-enforcing policies (the cadence).

This allows quick, local validation of MDM health without waiting for Intune portal sync logs or using admin tools.

---

## What the Script Does

### Step 1 – Check Enterprise Management Scheduled Tasks

* Lists all tasks under
  `\Microsoft\Windows\EnterpriseMgmt\*`
* Confirms that the MDM enrollment-related scheduled tasks exist and are running.
* If no tasks are found, this may indicate a **broken or incomplete MDM enrollment**.

### Step 2 – Inspect the Config Refresh Registry Key

* Looks for the registry path:

  ```
  HKLM:\SOFTWARE\Microsoft\Enrollments\<EnrollmentID>\ConfigRefresh
  ```
* Displays the values of:

  * **Enabled** – Indicates if Config Refresh is turned on (`1 = Enabled`).
  * **Cadence** – The refresh interval in minutes (typically 30).
* Reports on health status:

  * ✅ *Active and healthy* — Configuration Refresh is enabled and running.
  * ⚠️ *Present but misconfigured* — Key exists, but values are not correct.
  * ⌛ *Missing key* — Device is waiting for next MDM sync to create the key.

---

## Example Output

```
=== Step 1: EnterpriseMgmt Scheduled Tasks ===
TaskPath                                TaskName              State
--------                                --------              -----
\Microsoft\Windows\EnterpriseMgmt\     Schedule #1           Ready

=== Step 2: Config Refresh Registry State ===
✅ ConfigRefresh key exists for active enrollment:
HKLM:\SOFTWARE\Microsoft\Enrollments\<EnrollmentID>\ConfigRefresh

Enabled : 1
Cadence : 30

✅ Config Refresh is active and healthy. Drift Control will run automatically every 30 minutes.
=== Validation Complete ===
```

---

## Why This Script Is Useful

When Intune devices fail to sync or drift from their expected configuration, it’s often unclear whether the **Config Refresh engine** is still active. This script provides immediate, local feedback without needing:

* Administrative privileges.
* Intune portal access.
* Event Viewer or diagnostic tools.

### Use Cases:

* **Troubleshooting “stale” devices** that don’t appear to update policies.
* **Verifying policy enforcement frequency** (Config Refresh cadence).
* **Confirming MDM enrollment integrity** after device provisioning or autopilot setup.
* **Supporting helpdesk triage** without requiring full Intune access.

---

## Recommended Next Steps (If Issues Are Found)

| Detected Issue                | Recommended Action                                                                                                   |
| ----------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| No EnterpriseMgmt tasks found | Re-enroll the device with Intune or check MDM enrollment status under *Settings → Accounts → Access work or school*. |
| ConfigRefresh key missing     | Trigger a manual sync via the **Company Portal** or **Access work or school → Info → Sync**.                         |
| Enabled = 0 or Cadence = 0    | Confirm the Intune “Configuration Refresh” policy is correctly assigned and applied to the device.                   |
| Values incorrect after sync   | Restart the **MDM agent** or perform an **MDM diagnostic export** for review.                                        |

---

## Notes

* The script can be safely run by standard users.
* It performs only read operations on system settings.
* It does not modify or reset any MDM configuration.

---
