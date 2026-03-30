<p align="center">
<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0EA5E9,100:2563EB&height=120&section=header&text=Alerts%20Triage%20Runbook&fontSize=32&fontColor=ffffff&animation=fadeIn"/>
</p>

This runbook describes the recommended investigation process for alerts generated in **Proofpoint Data Security Workbench**.

The purpose of triage is to determine whether an alert represents:

* Malicious insider activity
* Accidental data exposure
* Policy violation
* False positive detection

Alerts should always be investigated with the goal of identifying **user intent and data risk**.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Investigation%20Overview&fontSize=26&fontColor=ffffff"/>
</p>


Alerts typically follow this investigation path:

```text
Alert Review
↓
Evidence Analysis
↓
Activity Investigation
↓
Behavior Context
↓
Risk Assessment
↓
Escalation or Resolution
```

The investigation process uses multiple tools available within **Data Security Workbench** including:

* Alerts interface
* Timeline
* Explorations
* Data Catalog
* User Activity Player

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Step%201%20%E2%80%93%20Review%20Alert%20Summary&fontSize=26&fontColor=ffffff"/>
</p>

Open the alert from:

```
Proofpoint Data Security & Posture
→ Data Security Workbench
→ Alerts
```

Select the alert to open the **Alert Details panel**.

Review the following fields first:

| Field          | Purpose                                             |
| -------------- | --------------------------------------------------- |
| User           | Identify the user responsible for the activity      |
| Endpoint       | Identify the device or system involved              |
| Activity Type  | Determine what action triggered the alert           |
| Detection Rule | Identify which rule or detector generated the alert |
| Timestamp      | Determine when the activity occurred                |
| Severity       | Assess potential impact                             |

Understanding the **triggering rule** is important because it explains **why the alert was generated**.

Example triggers may include:

* file copied to USB
* file uploaded to cloud storage
* external sharing detected
* abnormal data transfer

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Step%202%20%E2%80%93%20Review%20Alert%20Evidence&fontSize=26&fontColor=ffffff"/>
</p>


Within the alert details panel, review any available evidence.

Evidence may include:

* Activity metadata
* File information
* Detection rule conditions
* Endpoint telemetry

If available, review **screenshot evidence** associated with the alert.

Screenshots provide visual confirmation of the user's activity at the time the alert occurred.

Note:

Screenshots may not be available in environments using **Endpoint DLP only**.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Step%203%20%E2%80%93%20Use%20the%20User%20Activity%20Player&fontSize=26&fontColor=ffffff"/>
</p>

If available, launch the **User Activity Player** from the screenshot section.

The User Activity Player allows investigators to replay user actions step-by-step.

The interface contains several components:

| Component           | Purpose                                    |
| ------------------- | ------------------------------------------ |
| Activity List       | Displays chronological user actions        |
| Screenshot Viewer   | Displays screenshots for each activity     |
| Activity Summary    | Shows metadata about the selected activity |
| Navigation Controls | Allows playback of activity sequence       |

Use the activity player to determine:

* what actions occurred before the alert
* what actions occurred after the alert
* whether the user attempted additional suspicious actions

This helps determine **user intent**.

Example suspicious behavior patterns:

* repeated attempts to upload files
* switching between multiple file transfer websites
* copying multiple files before uploading

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Step%204%20%E2%80%93%20Investigate%20Activity%20Timeline&fontSize=26&fontColor=ffffff"/>
</p>

Use the **Timeline view** to understand the sequence of user activity.

Access the timeline by searching for the user in the Data Security Workbench search bar and selecting:

```
Go to Timeline
```

The timeline displays chronological activity including:

| Activity Type         | Description                         |
| --------------------- | ----------------------------------- |
| Application activity  | Application usage                   |
| Web browsing activity | Website access                      |
| File activity         | File access, transfers, downloads   |
| USB activity          | External storage device usage       |
| Alert events          | Alerts triggered by detection rules |

The timeline helps determine:

* whether the alert was part of a larger sequence of activity
* if the user performed other suspicious actions
* whether data movement occurred before or after the alert

Example investigation questions:

* Did the user download files before uploading them?
* Did the user connect a USB device?
* Did the user access sensitive files before the alert?

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Step%205%20%E2%80%93%20Expand%20Investigation%20Using%20Explorations&fontSize=26&fontColor=ffffff"/>
</p>

Use **Explorations** to search for related activity across the platform.

Navigate to:

```
Data Security Workbench
→ Activity
→ Explorations
```

Explorations allow analysts to search for patterns such as:

* activity by a specific user
* activity on a specific endpoint
* file access activity
* cloud uploads

Example investigation query:

Monitor whether the same user triggered multiple DLP signals.

Filter example:

```
User → username
Activity → Signal Type → DLP
```

Explorations help determine whether the alert is:

* isolated behavior
* part of repeated activity
* part of a broader data exfiltration attempt

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Step%206%20%E2%80%93%20Review%20Data%20Risk&fontSize=26&fontColor=ffffff"/>
</p>

If the alert involves file activity, investigate the file using the **Data Catalog**.

Navigate to:

```
Data Security Workbench
→ Data
→ Data Catalog
```

Review file metadata including:

| Attribute           | Description |
| ------------------- | ----------- |
| File name           |             |
| File type           |             |
| File size           |             |
| Share permissions   |             |
| Data classification |             |
| Source application  |             |

Determine whether the file was:

* externally shared
* publicly accessible
* classified as sensitive

Files with **public or external sharing permissions** may represent higher data exposure risk.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Step%207%20%E2%80%93%20Determine%20User%20Intent&fontSize=26&fontColor=ffffff"/>
</p>

After reviewing activity evidence, determine the likely intent behind the activity.

Possible investigation outcomes include:

| Outcome                    | Description                                     |
| -------------------------- | ----------------------------------------------- |
| Malicious insider activity | Intentional data theft or exfiltration          |
| Negligent behavior         | User unintentionally violated policy            |
| Policy violation           | User knowingly violated acceptable use policies |
| False positive             | Detection rule triggered incorrectly            |

Indicators of malicious activity may include:

* unusually large data transfers
* repeated attempts to upload files externally
* attempts to bypass monitoring systems
* accessing sensitive data before transfer
* attempts to hide activity

Context is important when evaluating intent.

For example:

* uploading files to personal cloud storage may indicate data exfiltration
* printing large documents may indicate data leakage risk

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Step%208%20%E2%80%93%20Escalate%20the%20Alert&fontSize=26&fontColor=ffffff"/>
</p>


Escalate the alert if the investigation reveals high-risk activity.

Escalation scenarios include:

* confirmed data exfiltration
* compromised user accounts
* access to sensitive data without authorization
* suspicious administrative activity

Escalations may involve:

| Team                 | Reason                      |
| -------------------- | --------------------------- |
| SOC leadership       | Incident coordination       |
| Security engineering | Detection rule improvements |
| Legal or compliance  | Regulatory reporting        |
| IT operations        | Account containment actions |

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Step%209%20%E2%80%93%20Resolve%20the%20Alert&fontSize=26&fontColor=ffffff"/>
</p>

Once the investigation is complete, update the alert workflow status.

Typical final statuses include:

| Status         | Meaning                                          |
| -------------- | ------------------------------------------------ |
| Resolved       | Confirmed malicious or policy-violating activity |
| False Positive | Detection rule triggered incorrectly             |
| Not an Issue   | Activity was legitimate                          |

Final investigation actions should include:

1. Updating alert status
2. Documenting investigation findings
3. Applying investigation tags
4. Exporting evidence if required

Exported evidence may include:

* activity logs
* investigation notes
* screenshots
* timeline records

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Investigation%20Best%20Practices&fontSize=26&fontColor=ffffff"/>
</p>

Security analysts should follow these best practices when investigating alerts.

1. **Always review the full activity timeline.**

A single alert may represent only part of the user’s behavior.

2. **Verify the detection rule that generated the alert.**

Understanding the rule logic helps determine whether the alert represents expected behavior.

3. **Look for patterns across multiple alerts.**

Repeated alerts for the same user may indicate a larger incident.

4. **Investigate surrounding activity.**

Actions before and after the alert often provide critical context.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Relationship%20to%20Workflow%20Status&fontSize=26&fontColor=ffffff"/>
</p>

The triage process works together with the **Alert Workflow system**.

During the investigation:

| Stage                   | Recommended Status                       |
| ----------------------- | ---------------------------------------- |
| Alert received          | New                                      |
| Investigation started   | In Progress                              |
| Escalated investigation | Escalated                                |
| Investigation complete  | Resolved / False Positive / Not an Issue |

Updating workflow statuses helps analysts coordinate investigations across the team.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>
