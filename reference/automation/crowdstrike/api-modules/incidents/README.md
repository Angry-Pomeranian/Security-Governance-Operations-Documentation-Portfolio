## 1. `Get-FalconBehavior`

**Purpose:**
Query behavioral events that belong to incidents in CrowdStrike Falcon.

**What it does:**

* Retrieves behavior records linked to detections or incidents.
* Supports:

  * Searching by behavior ID.
  * Filtering using Falcon Query Language (FQL).
  * Sorting by timestamp.
  * Pagination, totals-only mode, or full dataset retrieval.
  * Optional detailed results.

**Typical use cases:**

* Investigating what exact actions triggered an incident.
* Pulling behavior timelines for forensics.
* Correlating behaviors across multiple incidents.

**Key detail:**
If you pass IDs via the pipeline, it batches them before calling the API.

---

## 2. `Get-FalconIncident`

**Purpose:**
Search for and retrieve incidents.

**What it does:**

* Queries incident records from Falcon.
* Can:

  * Fetch incidents by ID.
  * Filter incidents by state, status, owner, timestamps, etc.
  * Sort on multiple fields like severity, assigned analyst, or lifecycle stage.
  * Retrieve full incident objects or just counts.

**Typical use cases:**

* SOC dashboards.
* Incident reviews.
* Automation workflows that triage incidents by severity or state.

---

## 3. `Get-FalconScore`

**Purpose:**
Retrieve CrowdScore values over time.

**What it does:**

* Queries CrowdStrike’s aggregate threat score metric.
* Supports filtering, sorting, pagination, totals-only, or full history.

**Typical use cases:**

* Measuring threat posture trends.
* Feeding SOC or executive dashboards.
* Correlating score changes with incidents or campaigns.

**Important limitation:**
This function is read-only and does not retrieve incident details, only scoring data.

---

## 4. `Invoke-FalconIncidentAction`

**Purpose:**
Modify incidents.

**This is the only function here that changes data.**

**What it can do:**

* Update incident status.
* Assign or unassign incidents.
* Rename incidents.
* Add or remove tags.
* Update descriptions.
* Optionally update linked detections at the same time.

**How it works:**

* Accepts one or more incident IDs.
* Supports:

  * Single action name + value.
  * Multiple actions passed as structured hashtables.
* Validates action names and values before sending the request.
* Automatically formats the request body to match Falcon API requirements.

**Typical use cases:**

* SOC automation.
* Bulk remediation.
* Workflow-driven incident lifecycle management.

**Critical note:**
This function requires `Incidents: Write` permissions and will actively modify incident state.

---

## Common design patterns across all functions

1. **Advanced functions**

   * They use `[CmdletBinding()]`, making them behave like native PowerShell cmdlets.

2. **Strict input validation**

   * Regex validation for IDs.
   * FQL validation.
   * Enumerated valid values for actions and sorting.

3. **Pipeline-aware**

   * IDs can be piped in.
   * Collected and sent in batches for efficiency.

4. **Central execution**

   * All API calls ultimately go through `Invoke-Falcon`, which handles authentication, formatting, and HTTP transport.

5. **Safe-by-default**

   * `SupportsShouldProcess` allows use of `-WhatIf` and `-Confirm`.

---

## What this script does not do

* It does not deploy Falcon.
* It does not touch endpoints directly.
* It does not run malware scans.
* It does not bypass Falcon controls.

It strictly interacts with the **Incidents API layer**.

---

## Security impact summary

* **Read-only functions:** `Get-FalconBehavior`, `Get-FalconIncident`, `Get-FalconScore`
* **State-changing function:** `Invoke-FalconIncidentAction`
* **Blast radius:** Limited to incident metadata and status, not endpoint execution.

From a governance perspective, this is SOC automation tooling, not offensive tooling.

---
