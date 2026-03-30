<p align="center">
<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0EA5E9,100:2563EB&height=120&section=header&text=Anomaly%20Investigation&fontSize=32&fontColor=ffffff&animation=fadeIn"/>
</p>


Proofpoint Data Security Workbench includes anomaly detection capabilities that identify user behavior which deviates from established activity baselines. 

These anomalies may indicate potential security risks such as insider threats, compromised accounts, or abnormal data movement.

Anomaly alerts help analysts detect situations where user activity significantly differs from normal behavioral patterns. 

These alerts should be investigated carefully to determine whether the behavior represents legitimate work activity, negligence, or malicious intent.

This document describes how to investigate anomalies using Data Security Workbench tools such as Explorations, Timeline, Alerts, and the User Activity Player.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Understanding%20Anomaly%20Detection&fontSize=26&fontColor=ffffff"/>
</p>

Anomaly detection is a behavioral analytics feature that monitors activity patterns across endpoints and cloud environments. 

The platform establishes baseline activity models and identifies events that exceed expected thresholds.

Proofpoint typically builds baselines using historical user activity over a period of time. 

The documentation indicates that behavioral baselines typically require approximately **30 days of activity data** to establish reliable patterns.

When user behavior significantly deviates from the baseline, an anomaly alert may be generated.

Examples of behavioral anomalies include:

| Activity Type | Example Scenario |
|---|---|
| Data Access | User downloads an unusually large number of files |
| Data Exfiltration | Large uploads to external websites or cloud services |
| File Permission Changes | Unexpected sharing permissions applied to files |
| USB Activity | Unusually large file copies to removable media |
| Printing Activity | Large document printing outside normal patterns |

Anomalies are designed to highlight activity that may indicate:

- Insider data theft
- Compromised user accounts
- Policy violations
- Suspicious data movement
- Unusual access to sensitive information

Not all anomalies represent malicious behavior. Analysts must investigate anomalies within the context of user roles and expected activity patterns.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Types%20of%20Anomalies&fontSize=26&fontColor=ffffff"/>
</p>

Proofpoint anomaly detection may identify multiple types of abnormal behavior across monitored systems.

## Endpoint Anomalies

Endpoint anomalies are generated when abnormal activity occurs on monitored endpoints.

Examples include:

| Detection | Description |
|---|---|
| Anomalous Data Access | User downloads significantly more files than usual |
| Anomalous Data Exfiltration | User transfers unusually large volumes of data |
| Anomalous Permission Changes | User modifies file permissions outside normal patterns |
| Abnormal File Activity | Excessive copying, renaming, or deleting of files |

Endpoint anomalies often involve sensitive file access or data movement activity.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=How%20Anomalies%20Appear%20in%20the%20Platform&fontSize=26&fontColor=ffffff"/>
</p>

Cloud anomalies are generated when abnormal activity occurs in cloud platforms monitored by CASB integrations.

Examples include:

| Detection | Description |
|---|---|
| Large Cloud Downloads | Significant data downloads from cloud storage |
| Unusual External Sharing | Files shared with external users unexpectedly |
| Abnormal File Access | Access to sensitive files not normally accessed |
| Suspicious File Uploads | Large uploads to external cloud services |

Cloud anomalies often indicate potential data exfiltration attempts or account compromise.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Investigating%20Anomalies%20Using%20Explorations&fontSize=26&fontColor=ffffff"/>
</p>


Anomalies typically appear as alerts within the Alerts dashboard.

Navigation path:

Proofpoint Data Security & Posture
→ Data Security Workbench
→ Alerts


An anomaly alert usually contains:

| Field | Description |
|---|---|
| User | The user responsible for the activity |
| Endpoint | Device where the anomaly occurred |
| Activity Type | Type of anomalous activity detected |
| Risk Level | Severity or impact of the anomaly |
| Detection Logic | Behavioral rule that triggered the anomaly |

Some anomaly alerts include a **Forensics tab**, which provides additional evidence explaining why the system considered the activity suspicious.

The forensics panel may include:

- behavioral deviation metrics
- baseline comparison graphs
- historical activity context
- related user activity

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>


Explorations allow analysts to search and analyze activity data across the platform.

Navigation path:

Data Security Workbench
→ Activity
→ Explorations

When investigating anomalies, analysts should create an exploration that focuses on the affected user or activity.

Example investigation workflow:

1. Identify the user associated with the anomaly alert.
2. Create an exploration filtering for the user.
3. Review all activity associated with the user during the relevant timeframe.

Example filter configuration:

| Filter | Value |
|---|---|
| User | Username associated with alert |
| Time | Range covering the alert and surrounding activity |
| Activity Type | File activity, web activity, or signal type |

Explorations allow analysts to determine whether the anomaly represents isolated behavior or part of a larger pattern.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Using%20the%20Timeline%20for%20Anomaly%20Investigation&fontSize=26&fontColor=ffffff"/>
</p>

The Timeline view allows analysts to review user activity chronologically.

Access the timeline by entering the user name in the Data Security Workbench search bar and selecting:

```

Go to Timeline

```

The timeline view displays all user activity events in chronological order.

Activity categories displayed may include:

| Activity Type | Description |
|---|---|
| Application Activity | Programs executed on the system |
| Web Activity | Websites accessed by the user |
| File Activity | File access, copying, and deletion |
| USB Activity | Removable media usage |
| Alert Events | Detection rule or anomaly alerts |

Timeline analysis allows analysts to understand the full context of the anomaly.

For example, investigators may determine:

- whether the user downloaded files before uploading them
- whether the user accessed sensitive files prior to transfer
- whether the anomaly is part of a larger sequence of actions

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Using%20the%20User%20Activity%20Player&fontSize=26&fontColor=ffffff"/>
</p>

If screenshot capture is enabled, the User Activity Player can be used to review user actions visually.

The activity player provides step-by-step playback of user activity aligned with screenshots.

Key components of the interface include:

| Component | Description |
|---|---|
| Activity List | Chronological list of user actions |
| Screenshot View | Screenshot associated with each activity |
| Activity Summary | Metadata for the selected activity |
| Navigation Controls | Controls for playback and activity navigation |

The activity player allows analysts to see exactly what actions were performed.

This helps determine user intent and identify suspicious behavior patterns.

Examples include:

- users attempting to bypass security restrictions
- repeated attempts to upload files
- accessing multiple sensitive files prior to transfer

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Investigating%20Data%20Risk&fontSize=26&fontColor=ffffff"/>
</p>

If the anomaly involves file access or file transfers, analysts should review the file within the **Data Catalog**.

Navigation path:

Data Security Workbench
→ Data
→ Data Catalog

The Data Catalog contains information about cloud files and potential exposure risks.

Relevant metadata may include:

| Attribute | Description |
|---|---|
| File Name | Name of the file involved |
| File Size | Size of the file |
| File Type | Type of document |
| Sharing Permissions | Access permissions |
| Data Classification | Sensitivity indicators |

Files that are externally shared or publicly accessible represent higher risk.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Determining%20Whether%20an%20Anomaly%20Is%20Malicious&fontSize=26&fontColor=ffffff"/>
</p>

Not all anomalies represent malicious behavior.

Analysts should consider several contextual factors:

| Factor | Questions to Consider |
|---|---|
| User Role | Does the user's job require this activity? |
| Timing | Did the activity occur outside normal working hours? |
| Data Sensitivity | Were sensitive files involved? |
| Activity Volume | Was the amount of activity abnormal? |
| Repetition | Has the user triggered similar alerts previously? |

Examples of legitimate anomalies may include:

- employees performing large data transfers during projects
- administrators accessing many systems during maintenance
- users downloading large files for legitimate work purposes

Examples of suspicious anomalies may include:

- large data transfers to external destinations
- attempts to bypass monitoring tools
- unusual activity outside working hours
- accessing sensitive files without business justification

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Escalation%20Guidelines&fontSize=26&fontColor=ffffff"/>
</p>

Escalate anomaly alerts if the investigation reveals:

- confirmed data exfiltration
- compromised user accounts
- abnormal access to sensitive data
- suspicious administrative activity

Escalations may involve:

| Team | Responsibility |
|---|---|
| Security Operations | Incident investigation |
| Security Engineering | Detection rule adjustments |
| IT Operations | Account containment actions |
| Legal or Compliance | Regulatory obligations |

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Resolving%20the%20Investigation&fontSize=26&fontColor=ffffff"/>
</p>

Once the anomaly investigation is complete:

1. Update the alert workflow status.
2. Document investigation findings.
3. Tag the alert appropriately.
4. Export evidence if necessary.

Possible outcomes include:

| Status | Meaning |
|---|---|
| Resolved | Malicious or policy-violating activity confirmed |
| False Positive | Detection logic triggered incorrectly |
| Not an Issue | Activity was legitimate |

Proper documentation ensures that future alerts can be evaluated more efficiently.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Investigation%20Best%20Practices&fontSize=26&fontColor=ffffff"/>
</p>


Security analysts investigating anomalies should follow these best practices:

1. Always review surrounding user activity using the Timeline.
2. Investigate both actions before and after the anomaly.
3. Consider the user's role and expected behavior.
4. Look for patterns across multiple alerts.
5. Validate the anomaly against historical user behavior.

Anomaly detection is most effective when combined with contextual investigation and analyst judgment.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Relationship%20to%20Other%20Investigation%20Tools&fontSize=26&fontColor=ffffff"/>
</p>

Anomaly investigation typically involves multiple Proofpoint tools.

| Tool | Purpose |
|---|---|
| Alerts | Identify the anomaly event |
| Explorations | Search for related activity |
| Timeline | Analyze chronological activity |
| User Activity Player | Visual playback of user actions |
| Data Catalog | Evaluate data exposure risk |

These tools collectively provide analysts with a comprehensive view of user activity.
