This pair of functions lets you **investigate where a specific Indicator of Compromise (IOC) has appeared in your environment** using the **CrowdStrike Falcon IOC APIs**.

Rule of inference used:
Set membership and correlation. The cmdlets answer two related questions: which hosts saw an indicator, and which processes on a host were involved.

Both are **read-only** and require `IOCs: Read`.

---

## 1. `Get-FalconIocHost`

### What it does

Finds **endpoints that have observed a specific custom IOC**.

In plain terms:
“Which devices in my tenant have seen this hash, IP, domain, or address?”

### Inputs

* `Type`
  Indicator type. One of:

  * domain
  * ipv4
  * ipv6
  * md5
  * sha256
* `Value`
  The actual indicator value.
* Optional pagination:

  * `Limit`
  * `Offset`
  * `All`
* `Total`
  Returns only the count of affected hosts instead of the host list.

### Output

* Host IDs and metadata for devices that observed the indicator
* Or just a total count if `-Total` is used

### Example uses

* Validate spread after ingesting a threat intel IOC
* Scope impact during incident response
* Feed containment workflows

Example:

```powershell
Get-FalconIocHost -Type sha256 -Value "<hash>"
```

---

## 2. `Get-FalconIocProcess`

### What it does

Finds **processes on a specific host that were associated with a given IOC**.

In plain terms:
“On this device, which processes touched or matched this indicator?”

This is a **deeper forensic step** after identifying affected hosts.

### Inputs

* `Type` and `Value`
  Same IOC definition as above
* `HostId`
  Falcon agent ID of the endpoint
* Optional:

  * `Detailed` for full process metadata
  * `Limit`, `Offset`, `All` for pagination
* `Id`
  Can accept Falcon process IDs from the pipeline

### Output

* Process records tied to the IOC
* With `-Detailed`, includes execution context and metadata

### Example uses

* Root cause analysis
* Malware execution tracing
* Validation before remediation or containment

Example:

```powershell
Get-FalconIocProcess -Type domain -Value "bad.example" -HostId "<aid>" -Detailed
```

---

## How these two fit together

Typical investigation flow:

1. Identify impacted endpoints

```powershell
Get-FalconIocHost -Type sha256 -Value "<hash>"
```

2. Investigate execution on a specific device

```powershell
Get-FalconIocProcess -Type sha256 -Value "<hash>" -HostId "<aid>"
```

This mirrors how an analyst pivots from scope to execution detail.

---

## What these functions do NOT do

* Do not create IOCs
* Do not block indicators
* Do not kill processes
* Do not quarantine hosts

They only **query telemetry** already collected by Falcon.

---

## Security and operational impact

* Permissions: `IOCs: Read`
* Risk: Low
* Side effects: None
* Safe for SOC analysts, threat hunting, and automation

They are commonly used in:

* Threat hunting
* Intel validation
* Incident scoping
* Audit evidence collection

---
