<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Creating%20Alerts&fontSize=26&fontColor=ffffff"/>
</p>

In Proofpoint Data Security Workbench, alerts are generated when monitored activity matches defined detection logic.

Alerts themselves are **not manually created objects**. Instead, alerts are produced when activity matches:

- Detection Rules
- Threat Library detections
- CASB DLP detectors
- Website category detections
- Behavioral anomaly detection

Administrators configure these detection mechanisms to monitor activity across endpoints, cloud services, and web browsing.

When a monitored activity matches the configured logic, the platform automatically generates an alert in the **Alerts dashboard**.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Alert%20Generation%20Architecture&fontSize=26&fontColor=ffffff"/>
</p>

Alert creation follows this process:

```

User Activity
↓
Detection Logic Evaluated
↓
Rule or Detector Triggered
↓
Alert Generated
↓
Alert Appears in Alerts Dashboard

```

User activity may originate from multiple sources including:

- endpoint file activity
- cloud storage usage
- web browsing activity
- application activity
- email activity

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Methods%20for%20Generating%20Alerts&fontSize=26&fontColor=ffffff"/>
</p>

Alerts can be generated using several mechanisms within Proofpoint.

| Method | Description |
|---|---|
| Detection Rules | Custom rules configured by administrators |
| Threat Library | Predefined detections for risky behavior |
| CASB DLP Detectors | Sensitive data detection in cloud platforms |
| Website Categorization | Alerts triggered by browsing specific categories |
| Anomaly Detection | Behavioral analytics detecting abnormal activity |

Each of these mechanisms evaluates user activity and generates alerts when suspicious behavior is detected.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Creating%20Alerts%20Using%20Detection%20Rules&fontSize=26&fontColor=ffffff"/>
</p>

Detection rules are the **primary method** used to generate alerts.

Rules monitor activity and trigger alerts when predefined conditions are met.

Rules follow an **IF → THEN logic model**.

Example rule:

```

IF
User copies file to USB

THEN
Generate alert

```

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Creating%20a%20Detection%20Rule&fontSize=26&fontColor=ffffff"/>
</p>

Steps:

1. Navigate to the administration interface.

```

Administration
→ Policies
→ Rules

```

2. Click **New Rule**

3. Define rule conditions

4. Configure the rule action

5. Save the rule

Once the rule is active, alerts will automatically be generated when the rule conditions are met.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Creating%20Alerts%20Using%20Threat%20Library%20Detections&fontSize=26&fontColor=ffffff"/>
</p>

Proofpoint provides a **Threat Library** containing predefined detection logic.

The Threat Library includes detections for common security risks such as:

- use of TOR browser
- installation of VPN or proxy tools
- downloading password cracking utilities
- copying files to USB storage
- uploading files to cloud storage

Administrators can convert Threat Library detections into active rules.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Creating%20Alerts%20Based%20on%20Website%20Categories&fontSize=26&fontColor=ffffff"/>
</p>

Steps:

1. Navigate to:

```

Administration
→ Threat Library

```

2. Select a threat item

3. Click **Save as Rule**

The system creates a detection rule using the predefined threat logic.

The rule will generate alerts when the monitored activity occurs.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Creating%20Alerts%20Using%20CASB%20DLP%20Detectors&fontSize=26&fontColor=ffffff"/>
</p>

Proofpoint classifies websites into categories based on browsing activity.

Examples include:

| Category | Description |
|---|---|
| Generative AI | AI tools that generate content |
| Social Networking | Social media platforms |
| Gambling | Online betting platforms |
| Peer to Peer | Torrent and file sharing sites |
| Malware Sites | Known malicious domains |

Detection rules can generate alerts when users access specific categories.

Example rule:

```

IF
Website Category = Games

THEN
Generate alert

```

This allows organizations to monitor unacceptable browsing behavior.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Alerts%20Generated%20by%20Anomaly%20Detection&fontSize=26&fontColor=ffffff"/>
</p>

Cloud Application Security Broker (CASB) detectors identify sensitive data stored or shared in cloud platforms.

CASB DLP detectors analyze files for:

- sensitive data patterns
- classified information
- confidential documents

When a file matches a DLP detector, a **CASB alert** is generated.

These alerts provide details including:

- file location
- sharing permissions
- affected users
- geographic location of the event

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Alerts%20Generated%20by%20Anomaly%20Detection&fontSize=26&fontColor=ffffff"/>
</p>

Proofpoint anomaly detection uses machine learning to identify behavior that deviates from normal patterns.

The system builds behavioral baselines using:

- individual user activity
- organization-wide activity patterns

Baseline models include:

| Model | Description |
|---|---|
| User Median | Baseline derived from individual user behavior |
| Tenant Median | Baseline derived from organization-wide activity |

When activity significantly deviates from the baseline, an anomaly alert is generated.

Examples include:

- unusually large downloads
- abnormal file sharing activity
- excessive USB file transfers
- abnormal permission changes

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Verifying%20Alert%20Generation&fontSize=26&fontColor=ffffff"/>
</p>

After configuring a detection rule or detector, administrators should verify that alerts are generated correctly.

Verification steps:

1. Trigger the monitored activity in a test environment.

Example:

- copy a file to USB
- upload a file to a monitored cloud storage site

2. Navigate to:

```

Data Security Workbench
→ Alerts

```

3. Confirm the alert appears in the alerts dashboard.

4. Review the alert details to verify the detection rule triggered correctly.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Best%20Practices%20for%20Alert%20Creation&fontSize=26&fontColor=ffffff"/>
</p>

Security teams should follow these guidelines when creating detection rules.

1. **Avoid overly broad detection rules.**

Broad rules may generate excessive alerts.

2. **Prioritize high-risk behaviors.**

Focus on activities most associated with data exfiltration.

3. **Test detection rules before production deployment.**

This helps reduce false positives.

4. **Use Threat Library detections when possible.**

Prebuilt detections are designed using industry threat intelligence.

5. **Review alert volume regularly.**

Adjust rules to maintain manageable investigation workloads.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Relationship%20to%20Alert%20Workflow&fontSize=26&fontColor=ffffff"/>
</p>

Once alerts are generated, they appear in the **Alerts dashboard** where analysts investigate them using the alert workflow.

Alerts then progress through the workflow stages:

```

New
↓
In Progress
↓
Escalated / On Hold
↓
Resolved / False Positive / Not an Issue

```

The alert triage process is documented in:

```

alerts/alert-triage-runbook.md

```
