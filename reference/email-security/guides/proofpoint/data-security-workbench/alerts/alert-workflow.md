<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Alert%20Workflow&fontSize=26&fontColor=ffffff"/>
</p>

Alerts in Proofpoint Data Security Workbench follow a structured workflow that allows security teams to track the progress of investigations and manage the lifecycle of security events.

The workflow provides a method for analysts to:

* track investigation progress
* categorize alert outcomes
* coordinate investigations between analysts
* document investigation decisions
* distinguish between active and resolved alerts

Each alert progresses through a defined lifecycle beginning with detection and ending with investigation closure.

The alert workflow **does not automatically modify system policies or configuration settings**. Changing the workflow status only reflects the investigation state of the alert.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Alert%20Lifecycle&fontSize=26&fontColor=ffffff"/>
</p>

All alerts begin with the workflow status:

New

This indicates that the alert has been generated but has not yet been investigated.

During the investigation process, analysts update the workflow status to reflect the progress and outcome of the investigation.

The lifecycle generally follows this progression:

```
New → In Progress → Escalated / On Hold → Resolved
```

Alternative outcomes may also occur depending on the investigation findings.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Workflow%20Status%20Categories&fontSize=26&fontColor=ffffff"/>
</p>

Alert workflow statuses are grouped into three primary categories that indicate the overall investigation state.

| Category | Purpose                              |
| -------- | ------------------------------------ |
| Pending  | Alert requires investigation         |
| Open     | Alert is actively being investigated |
| Closed   | Investigation is complete            |

These categories help analysts quickly identify alerts that require attention.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Default%20Alert%20Status%20Lifecycle&fontSize=26&fontColor=ffffff"/>
</p>

The following workflow statuses are available by default.

| Status         | Category | Description                                                        |
| -------------- | -------- | ------------------------------------------------------------------ |
| New            | Pending  | Alert requires investigation                                       |
| Reopened       | Pending  | Alert requires additional investigation                            |
| In Progress    | Open     | Investigation is actively underway                                 |
| Escalated      | Open     | Alert has been escalated to senior analysts or security leadership |
| On Hold        | Open     | Investigation temporarily paused                                   |
| Resolved       | Closed   | Confirmed malicious or policy-violating activity                   |
| Compromised    | Closed   | Confirmed compromised account or identity                          |
| Not an Issue   | Closed   | Activity determined to be benign or expected                       |
| False Positive | Closed   | Alert triggered incorrectly due to detection logic                 |

These statuses allow analysts to communicate investigation progress and outcomes clearly.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Investigation%20State%20Definitions&fontSize=26&fontColor=ffffff"/>
</p>

### Pending

Alerts in the **Pending** category have been generated but not yet reviewed by a security analyst.

Examples:

* newly generated alerts
* alerts awaiting analyst review
* alerts reopened for additional investigation

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

### Open

Alerts in the **Open** category are actively under investigation.

Examples include:

* alerts currently being analyzed
* alerts escalated to senior analysts
* alerts temporarily paused while additional information is gathered

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

### Closed

Alerts in the **Closed** category have completed investigation and require no further action.

Closed alerts represent one of the following outcomes:

* confirmed malicious activity
* confirmed compromised account
* benign activity
* false positive detection

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Updating%20Alert%20Status&fontSize=26&fontColor=ffffff"/>
</p>


Alert workflow status can be updated directly from the Alerts interface.

Steps:

1. Open the **Alerts dashboard**
2. Select the alert to investigate
3. Locate the **Status** field within the alert details panel
4. Select the appropriate workflow status

Updating the alert status allows other analysts to understand the investigation state.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Multi-Alert%20Status%20Updates&fontSize=26&fontColor=ffffff"/>
</p>

Multiple alerts can be updated simultaneously using bulk actions.

Steps:

1. Select multiple alerts from the alerts table
2. Use the checkbox next to each alert
3. Choose **Bulk Actions**
4. Select **Status**
5. Apply the desired workflow status

Bulk actions are processed **asynchronously**, meaning the update may take a short period of time to complete.

Bulk updates are useful when:

* closing large groups of similar alerts
* marking alerts as false positives
* updating investigation states across multiple related alerts

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Custom%20Workflow%20Statuses&fontSize=26&fontColor=ffffff"/>
</p>

Organizations can define custom workflow statuses to better align with internal security operations processes.

Custom statuses are configured through the administrative interface.

Navigation path:

```
Administration
→ Definitions
→ Alerts Workflow
```

When creating custom workflow statuses, the status must be assigned to one of the following categories:

* Pending
* Open
* Closed

Custom statuses allow organizations to tailor investigation workflows to internal procedures.

Examples may include:

* Awaiting Manager Review
* Pending Legal Review
* Incident Response Engaged

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Workflow%20Visibility%20and%20Investigation%20Coordination&fontSize=26&fontColor=ffffff"/>
</p>

The workflow status allows multiple analysts to coordinate investigations efficiently.

Analysts reviewing the Alerts dashboard can quickly identify:

* alerts that have not yet been reviewed
* alerts currently being investigated
* alerts awaiting escalation
* alerts that have been resolved

This helps prevent duplicate investigations and ensures alerts are handled consistently.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Remediation%20Status%20Mapping&fontSize=26&fontColor=ffffff"/>
</p>

In some cases, remediation actions may fail due to platform or configuration limitations.

When this occurs, alert workflow status may indicate that investigation cannot proceed automatically.

Common remediation failure causes include:

* API rate limiting
* unsupported remediation action
* platform permission restrictions
* system errors
* integration failures

When remediation actions fail, the alert may be placed into a blocked or open investigation state.

Example status transition:

```
Open → Blocked
```

This ensures the alert remains visible for manual investigation.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Important%20Workflow%20Considerations&fontSize=26&fontColor=ffffff"/>
</p>

Several operational considerations should be understood when using the alert workflow system.

1. **Workflow status changes do not modify platform configuration.**

Updating alert status only reflects investigation progress.

2. **Alert status changes do not automatically synchronize between different Proofpoint consoles.**

For example, changing the status of a cloud DLP alert in the Data Security Workbench may not update the status in the CASB alert interface.

3. **Workflow status should be updated consistently.**

Consistent use of workflow statuses improves investigation tracking and reporting.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Recommended%20Investigation%20Workflow&fontSize=26&fontColor=ffffff"/>
</p>

Security teams typically follow a workflow similar to the following:

```
New
↓
In Progress
↓
Escalated (if required)
↓
Resolved / False Positive / Not an Issue
```

This approach ensures alerts are reviewed, investigated, and closed in a structured manner.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Relationship%20to%20Alert%20Triage&fontSize=26&fontColor=ffffff"/>
</p>

The alert workflow system works in conjunction with the **Alert Triage Runbook**, which defines the detailed steps analysts should follow when investigating alerts.

Workflow statuses should be updated throughout the triage process to reflect the current investigation stage.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>
