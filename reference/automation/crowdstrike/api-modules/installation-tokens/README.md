This block defines **all the PowerShell cmdlets used to manage Falcon sensor installation tokens** in **CrowdStrike Falcon**, via the PSFalcon module.

Rule of inference applied:
Capability classification. I grouped the functions by whether they **read**, **create**, **modify**, **delete**, or **govern** installation tokens.

At a high level, these cmdlets control **who is allowed to install the Falcon sensor and under what conditions**.

---

## What installation tokens are (context)

An **installation token** is a security control that restricts Falcon sensor installation.
If tokens are required, a sensor cannot be installed unless a valid token is provided.

This prevents:

* Unauthorized sensor deployment
* Rogue or accidental installs
* Abuse of customer IDs in public installers

---

## Function-by-function breakdown

### 1. `Edit-FalconInstallTokenSetting`

**Purpose:**
Update **global tenant-level rules** for installation tokens.

**What it can change:**

* Whether a token is required to install Falcon at all
* The maximum number of active tokens allowed

**Impact level:** High
This affects the entire tenant.

**Typical use cases:**

* Enforcing token-based installs company-wide
* Limiting token sprawl
* Hardening sensor deployment controls

---

### 2. `Edit-FalconInstallToken`

**Purpose:**
Modify existing installation tokens.

**What it can do to a token:**

* Rename the label
* Change the expiration date
* Revoke or un-revoke the token

**Important detail:**
Revoking a token does not uninstall sensors already deployed with it. It only blocks future installs.

**Impact level:** Medium
Scoped to specific tokens.

---

### 3. `Get-FalconInstallToken`

**Purpose:**
Search for and retrieve installation tokens.

**What it returns:**

* Token metadata
* Expiration timestamps
* Revocation state
* Optional detailed information

**Typical use cases:**

* Token inventory
* Expiration audits
* Identifying stale or risky tokens

Read-only and safe.

---

### 4. `Get-FalconInstallTokenEvent`

**Purpose:**
Retrieve **audit logs** for installation token activity.

**What it shows:**

* Token creation
* Token updates
* Token revocation
* Who performed the action and when

**Typical use cases:**

* Security investigations
* Change tracking
* Audit and compliance evidence

This is critical for SOC and ISO audit trails.

---

### 5. `Get-FalconInstallTokenSetting`

**Purpose:**
Read current **tenant-wide installation token configuration**.

**What it returns:**

* Whether tokens are required
* Maximum active token count

Purely informational. No mutation.

---

### 6. `New-FalconInstallToken`

**Purpose:**
Create a new installation token.

**Required inputs:**

* Label
* Expiration timestamp or null

**Best practice usage:**

* One token per deployment method
* Always set expirations
* Avoid shared long-lived tokens

**Impact level:** Medium
Creates new deployment capability.

---

### 7. `Remove-FalconInstallToken`

**Purpose:**
Delete installation tokens entirely.

**Important behavior:**

* This permanently removes the token
* Equivalent to hard revocation plus deletion
* Sensors already installed are unaffected

**Impact level:** Medium to high
Irreversible change.

---

## How these functions work internally

All functions:

1. Validate input strictly
2. Batch IDs passed through the pipeline
3. Call `Invoke-Falcon`
4. Respect `-WhatIf` and `-Confirm`

No function here runs code on endpoints.
All actions are API-level configuration changes.

---

## Security impact summary

| Function                       | Read | Write | Tenant-wide |
| ------------------------------ | ---- | ----- | ----------- |
| Get-FalconInstallToken         | Yes  | No    | No          |
| Get-FalconInstallTokenEvent    | Yes  | No    | No          |
| Get-FalconInstallTokenSetting  | Yes  | No    | Yes         |
| New-FalconInstallToken         | No   | Yes   | No          |
| Edit-FalconInstallToken        | No   | Yes   | No          |
| Remove-FalconInstallToken      | No   | Yes   | No          |
| Edit-FalconInstallTokenSetting | No   | Yes   | Yes         |

From a governance view, **Edit-FalconInstallTokenSetting** is the most sensitive.

---

## What these functions do NOT do

* Do not install Falcon
* Do not uninstall Falcon
* Do not touch endpoints
* Do not expose token secrets

They strictly manage **token metadata and policy**.

---
