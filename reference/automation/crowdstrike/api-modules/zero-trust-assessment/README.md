## What `Get-FalconZta` does

**Purpose:**
Retrieve **Zero Trust Assessment results** for endpoints.

In plain terms: it lets you **query how compliant or trustworthy a device is** according to CrowdStrike’s Zero Trust scoring model.

It does **not** enforce policy, remediate hosts, or change configuration. It only reads assessment data.

---

## What data it returns

Depending on parameters, it returns:

* ZTA scores per device
* Assessment pass or fail details
* Control categories such as:

  * OS posture
  * Sensor health
  * Configuration hardening
  * Risk indicators

With `-Detailed`, you get **per-control breakdowns**, not just the final score.

---

## How it can be used

### 1. Query by host ID

```powershell
Get-FalconZta -Id <aid>
```

* Retrieves the ZTA assessment for one or more specific endpoints.
* IDs must be valid Falcon agent IDs (AID).

### 2. Search using Falcon Query Language (FQL)

```powershell
Get-FalconZta -Filter "score:<70"
```

* Returns devices that fail or fall below a threshold.
* Useful for compliance reporting and posture monitoring.

### 3. Sort results

```powershell
Get-FalconZta -Filter "*" -Sort score|asc
```

* Finds the weakest devices first.

### 4. Bulk retrieval

* `-All` keeps requesting pages until all results are retrieved.
* `-Total` returns only the count, not the records.

---

## Parameter behavior explained

| Parameter  | Meaning                                       |
| ---------- | --------------------------------------------- |
| `Id`       | Falcon host ID(s) to retrieve assessments for |
| `Filter`   | FQL expression to narrow results              |
| `Sort`     | Sort by score ascending or descending         |
| `Limit`    | Max records per API call                      |
| `After`    | Pagination token                              |
| `Detailed` | Include full assessment detail                |
| `All`      | Retrieve all pages                            |
| `Total`    | Return count only                             |

Important constraint:
You **must** use either `Id` **or** `Filter`. You cannot mix them due to separate API endpoints.

---

## What this function does internally

1. Determines which API endpoint to call based on parameter set.
2. Collects host IDs if piped in.
3. Sends a request through `Invoke-Falcon`.
4. Returns structured assessment objects.

It follows the same batching and pipeline-safe pattern as the other PSFalcon cmdlets you posted.

---

## Security and operational impact

* **Permissions required:** `Zero Trust Assessment: Read`
* **Risk level:** Low
* **Side effects:** None
* **Audit visibility:** API read calls only

This is safe for:

* SOC analysts
* Compliance reporting
* Automation pipelines
* Dashboards

It should not be granted to roles that do not already have read access to endpoint posture data.

---

## What it does NOT do

* Does not quarantine devices
* Does not enforce Zero Trust
* Does not change device configuration
* Does not modify Falcon policies

It is purely observational.

---
