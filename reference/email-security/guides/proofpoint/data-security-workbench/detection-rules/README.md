<p align="center">
<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0EA5E9,100:2563EB&height=120&section=header&text=Detection%20Rules&fontSize=32&fontColor=ffffff&animation=fadeIn"/>
</p>

Detection rules allow organizations to monitor activity within **Proofpoint Data Security Workbench** and generate alerts when defined conditions occur.

Rules operate using an **IF → THEN logic model**, where a condition triggers a defined action.

This enables security teams to detect potentially risky activity and respond quickly.

Detection rules are commonly used to monitor:

- data transfers
- suspicious user behavior
- unauthorized system access
- sensitive data exposure
- abnormal activity patterns

When a rule condition is met, the platform can automatically generate alerts that appear in the **Alerts dashboard** for investigation.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

## Contents

| Topic | Description |
|---|---|
| 🧠 [How Detection Rules Work](#how-detection-rules-work) | Understanding the IF → THEN model |
| 📊 [Detection Rule Use Cases](#detection-rule-use-cases) | Common monitoring scenarios |
| ⚠️ [Detection Severity Levels](#detection-severity-levels) | Risk classification examples |
| ⚙️ [Creating Detection Rules](#creating-detection-rules) | Steps for rule creation |
| 🔎 [How Detection Rules Trigger Alerts](#how-detection-rules-trigger-alerts) | Alert generation process |
| ⚠️ [Detection Rule Best Practices](#detection-rule-best-practices) | Guidance for reliable detections |

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=How%20Detection%20Rules%20Work&fontSize=26&fontColor=ffffff"/>
</p>

Detection rules use a logical model that evaluates observed activity and determines whether an alert should be generated.

The logic typically follows this structure:

```

IF
Defined activity or condition occurs

THEN
Execute configured action

Example detection logic:

```

IF
User copies file to USB device

THEN
Generate alert

Conditions may involve a wide range of monitored activities, including:

- file transfers
- permission changes
- suspicious login activity
- abnormal user behavior
- interactions with sensitive data

When the defined condition is satisfied, the platform performs the configured action, typically generating an alert for investigation.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Detection%20Rule%20Use%20Cases&fontSize=26&fontColor=ffffff"/>
</p>

Detection rules can be used to monitor a wide variety of behaviors that may indicate **data security risks or policy violations**.

Common examples include:

| Detection Scenario | Description |
|---|---|
| File copied to USB | Detects data transfers to removable devices |
| File uploaded to cloud storage | Identifies potential data exfiltration |
| Unauthorized server login | Detects suspicious authentication activity |
| Sensitive file exfiltration | Identifies movement of sensitive data outside approved systems |

These rules help organizations identify both **accidental policy violations** and **intentional insider threat activity**.

Detection rules are often tuned based on the organization's risk tolerance and security policies.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Detection%20Severity%20Levels&fontSize=26&fontColor=ffffff"/>
</p>

Detection rules often include severity classifications to indicate the potential impact of the activity.

Example severity levels:

| Detection | Severity |
|---|---|
| File copied to USB | Low |
| File uploaded to cloud storage | Medium |
| Unauthorized server login | High |
| Sensitive file exfiltration | Critical |

Severity helps analysts prioritize alerts and focus on the most significant risks first.

However, severity should be interpreted in context. Even low severity detections may become important when correlated with other suspicious activity.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Creating%20Detection%20Rules&fontSize=26&fontColor=ffffff"/>
</p>

Detection rules are created through the administrative interface.

Steps:

1. Navigate to

Administration → Policies → Rules

2. Click **New Rule**

3. Define rule conditions

4. Configure rule actions

5. Save the rule

Conditions typically define **what activity should trigger the rule**, while actions define **what happens when the rule is triggered**.

Actions may include:

- generating alerts
- tagging activity
- assigning workflow states
- initiating investigation workflows

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=How%20Detection%20Rules%20Trigger%20Alerts&fontSize=26&fontColor=ffffff"/>
</p>

When a detection rule condition is satisfied, the platform automatically generates an alert.

This alert becomes visible in the **Alerts dashboard**, where analysts can review the activity and begin an investigation.

The alert typically contains:

- user information
- activity details
- rule name
- severity level
- associated evidence

From the alert, analysts may pivot to other investigation tools such as:

- Explorations
- Timeline
- User Activity Player
- Data Catalog

This workflow allows analysts to move from **automated detection to detailed investigation**.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Detection%20Rule%20Best%20Practices&fontSize=26&fontColor=ffffff"/>
</p>

When designing detection rules, organizations should consider several best practices.

### Avoid overly broad conditions

Rules that trigger on very common activity may generate excessive alerts and reduce analyst efficiency.

### Use contextual signals

Combining multiple signals, such as file activity and user risk indicators, improves detection accuracy.

### Assign appropriate severity levels

Severity should reflect the potential impact of the detected activity.

### Periodically review rule effectiveness

Detection rules should be reviewed regularly to ensure they remain aligned with organizational security policies.

### Correlate detections with investigations

Alerts generated by detection rules should be reviewed alongside other investigation data to confirm whether activity is suspicious or benign.
