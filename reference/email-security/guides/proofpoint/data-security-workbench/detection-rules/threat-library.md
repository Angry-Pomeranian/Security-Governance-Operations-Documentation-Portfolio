<p align="center">
<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0EA5E9,100:2563EB&height=120&section=header&text=Threat%20Library&fontSize=32&fontColor=ffffff&animation=fadeIn"/>
</p>

The Threat Library is a collection of **prebuilt, Proofpoint-maintained detection rules** that cover common insider threat and data security scenarios. These rules are ready to use without custom configuration and are updated by Proofpoint as new threat patterns emerge.

Using threat library detections reduces the time required to achieve detection coverage and ensures alignment with industry-recognised threat patterns.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Threat%20Library%20Categories&fontSize=26&fontColor=ffffff"/>
</p>

Threat library detections are organised by threat category.

| Category | Examples |
|---|---|
| Data exfiltration | File upload to personal cloud, USB copy, email forwarding of sensitive data |
| Insider threat indicators | Activity during off-hours, bulk file access, downloading before resignation |
| Account and access misuse | Unauthorized server login, privilege escalation, shared credential use |
| Policy violations | Use of prohibited applications, access to restricted systems |
| Behavioural anomalies | Activity deviating significantly from the user's established baseline |
| Sensitive data exposure | Sensitive files shared externally, screenshots of confidential documents |

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Enabling%20Threat%20Library%20Detections&fontSize=26&fontColor=ffffff"/>
</p>

Steps:

1. Navigate to:

```
Administration → Policies → Threat Library
```

2. Browse or search for detections relevant to your use case

3. Click a detection to view its description, conditions, and severity level

4. Click **Enable** to activate the detection for your environment

5. Optionally, customise the severity level or scoping before enabling

Enabled threat library detections generate alerts in the same way as custom detection rules — alerts appear in the **Alerts dashboard** when activity matches.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Threat%20Library%20vs%20Custom%20Rules&fontSize=26&fontColor=ffffff"/>
</p>

| Attribute | Threat Library | Custom Detection Rules |
|---|---|---|
| Authorship | Maintained by Proofpoint | Created and maintained in-house |
| Setup effort | Low — enable and go | Higher — conditions and logic must be defined |
| Customisation | Limited (severity and scope adjustable) | Full control over all conditions and actions |
| Update cadence | Updated by Proofpoint | Updated manually by security team |
| Best for | Baseline coverage, known threat patterns | Organisation-specific risks, bespoke policies |

A mature detection posture typically combines threat library detections for broad baseline coverage with custom rules for organisation-specific scenarios.
