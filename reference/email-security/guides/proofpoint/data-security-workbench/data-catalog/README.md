<p align="center">
<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0EA5E9,100:2563EB&height=120&section=header&text=Data%20Catalog&fontSize=32&fontColor=ffffff&animation=fadeIn"/>
</p>

The **Data Catalog** in Proofpoint Data Security Workbench provides visibility into files that may present **data security risks**.

It allows analysts to identify and investigate files stored in cloud platforms that are associated with potentially sensitive activity.

The catalog highlights files involved in actions such as:

- file uploads
- external sharing
- permission changes
- DLP matches
- unusual access patterns

The Data Catalog helps analysts quickly locate files that may require further investigation, especially during **data exposure investigations or insider threat analysis**.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

## Contents

| Topic | Description |
|---|---|
| 📂 [What the Data Catalog Is](#what-the-data-catalog-is) | Overview of the catalog and its purpose |
| 🧭 [Accessing the Data Catalog](#accessing-the-data-catalog) | Navigation path within the platform |
| ⚠️ [File Risk Indicators](#file-risk-indicators) | Why files appear in the catalog |
| ☁️ [Cloud Sharing Levels](#cloud-sharing-levels) | Understanding file exposure levels |
| 🔎 [Using the Data Catalog During Investigations](#using-the-data-catalog-during-investigations) | How analysts use the catalog |

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=What%20the%20Data%20Catalog%20Is&fontSize=26&fontColor=ffffff"/>
</p>

The Data Catalog aggregates information about files that have been involved in activities associated with potential **data risk**.

Instead of requiring analysts to manually search for individual files across multiple events, the catalog provides a **centralized view of files that may require investigation**.

These files are typically associated with activities such as:

- uploads to cloud storage
- sharing with external users
- permission modifications
- sensitive data detection through DLP
- file transfers between systems

The catalog provides visibility into **which files are involved**, **who interacted with them**, and **how they were shared**.

This allows analysts to quickly determine whether a file represents a **data exposure risk**.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Accessing%20the%20Data%20Catalog&fontSize=26&fontColor=ffffff"/>
</p>

To access the Data Catalog:

```

Proofpoint Data Security & Posture
→ Data Security Workbench
→ Data
→ Data Catalog

```

Opening the Data Catalog displays a list of files that have triggered **risk indicators or activity signals**.

Analysts can then filter, search, and investigate these files to understand their potential security impact.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=File%20Risk%20Indicators&fontSize=26&fontColor=ffffff"/>
</p>

Files appear in the Data Catalog when they match **risk conditions defined within the platform**.

These conditions help identify files that may require investigation.

Examples include:

- sensitive content detection through DLP policies
- files shared externally
- files with public access permissions
- suspicious uploads or transfers
- files accessed by unusual users
- files involved in security alerts

These indicators help analysts quickly locate files that may represent:

- data leakage risks
- policy violations
- insider threat activity
- accidental data exposure

However, a file appearing in the catalog **does not automatically mean malicious activity occurred**.

The catalog should be treated as a **risk visibility tool**, not a definitive indicator of compromise.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Cloud%20Sharing%20Levels&fontSize=26&fontColor=ffffff"/>
</p>

Cloud file exposure is categorized by sharing level.

These levels indicate **how widely a file is accessible**.

| Level | Description |
|---|---|
| Private | File is only accessible by the owner |
| Internal | File is shared within the organization |
| External | File is shared with users outside the organization |
| Public | File is accessible by anyone with the link |

Files with **External** or **Public** sharing levels typically represent higher potential risk.

During investigations, analysts often prioritize reviewing files that have broader access permissions.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Using%20the%20Data%20Catalog%20During%20Investigations&fontSize=26&fontColor=ffffff"/>
</p>

The Data Catalog is commonly used during investigations involving **data exposure or suspicious file activity**.

Typical investigation workflows include:

### Investigating external file sharing

An alert may indicate that a user shared files externally.

Analysts can open the Data Catalog to review:

- which files were shared
- who shared them
- who received access
- the sharing level of the file

### Investigating potential data exfiltration

If a user is suspected of transferring sensitive information, the Data Catalog may help identify:

- files uploaded to external platforms
- files containing sensitive data
- recently accessed or modified files

### Reviewing sensitive content exposure

When DLP policies detect sensitive information within files, those files may appear in the catalog.

Analysts can review:

- the file name
- sharing permissions
- activity history
- associated users

Combining this information with other investigation tools such as:

- Alerts
- Explorations
- Timeline analysis

helps analysts determine whether the activity represents **legitimate work activity or potential data exposure**.
