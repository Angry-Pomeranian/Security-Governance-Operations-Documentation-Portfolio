<p align="center">
<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0EA5E9,100:2563EB&height=120&section=header&text=Explorations%20Overview&fontSize=32&fontColor=ffffff&animation=fadeIn"/>
</p>

Explorations are one of the primary investigation tools within **Proofpoint Data Security Workbench**.

They allow analysts to search, filter, and analyze activity across endpoint, cloud, and platform data sources in order to investigate security alerts, monitor user behavior, and detect potential data risks.

An Exploration functions as a **structured investigation query**.  
Analysts define a data source, set a time range, apply filters, and review matching activity events.

Explorations are used during many types of investigations, including:

- alert investigations
- insider risk analysis
- data loss prevention (DLP) monitoring
- suspicious browsing investigations
- privileged user monitoring
- anomaly investigations
- data exposure reviews

Explorations often act as the **central analysis tool** when investigating activity detected by other platform features such as alerts or anomaly detection.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

## Contents

| Topic | Description |
|---|---|
| 🔎 [What Explorations Are](#what-explorations-are) | Overview of the Exploration investigation capability |
| ⚙️ [How Explorations Work](#how-explorations-work) | Understanding source nodes and filters |
| 🧭 [Typical Investigation Workflow](#typical-investigation-workflow) | How analysts use Explorations during investigations |
| 🧩 [Common Exploration Use Cases](#common-exploration-use-cases) | Typical investigation scenarios |
| 📂 [Exploration Documentation](#exploration-documentation) | Links to related documentation |
| 🧠 [Analyst Guidance](#analyst-guidance) | Recommended practices when using Explorations |

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=What%20Explorations%20Are&fontSize=26&fontColor=ffffff"/>
</p>

Explorations act as a **query engine for activity data collected by Proofpoint Data Security Workbench**.

They allow analysts to investigate activity across multiple monitored systems and telemetry sources.

Typical activity sources available to Explorations include:

- endpoint activity
- cloud platform activity
- audit logs
- agent telemetry
- platform detections
- browsing activity
- file operations

By combining filters, analysts can identify patterns such as:

- abnormal file downloads
- unusual browsing behavior
- large file transfers
- external file sharing
- suspicious administrative activity

Explorations are frequently used to **pivot from alerts into deeper investigation**.

For example, when an alert identifies suspicious activity, analysts may open an Exploration to review surrounding user behavior and determine whether the activity is isolated or part of a broader pattern.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=How%20Explorations%20Work&fontSize=26&fontColor=ffffff"/>
</p>

Every Exploration begins with a **source node**.

The source node defines the base dataset used for the investigation.

| Source Node Setting | Purpose |
|---|---|
| Region | Determines which tenant region or agent realm is queried |
| Time | Defines the investigation time window |
| Source | Defines which data source is searched |

After the source node is defined, analysts add **filter nodes** to refine the search.

Filter nodes allow analysts to specify conditions such as:

- specific users
- activity types
- websites or domains
- file operations
- risk indicators
- workflow status

Each filter narrows the results until the Exploration shows the relevant activity.

Explorations can then display results in table views, summary views, or graphs depending on the analysis required.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Typical%20Investigation%20Workflow&fontSize=26&fontColor=ffffff"/>
</p>

Explorations are typically used as part of a broader investigation workflow.

A common investigation process may look like this:

```

Alert or Detection
↓
Open Exploration
↓
Filter for the affected user or activity
↓
Review surrounding activity
↓
Pivot into Timeline or Activity Player
↓
Determine whether the behavior is legitimate or suspicious

```

This workflow allows analysts to move from a **single detection event** into a **broader behavioral investigation**.

Explorations help answer questions such as:

- What else did this user do before or after the alert?
- Has this behavior occurred before?
- Did the user interact with sensitive data?
- Was the activity isolated or repeated?

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Common%20Exploration%20Use%20Cases&fontSize=26&fontColor=ffffff"/>
</p>

Explorations support many types of investigations.

| Investigation Type | Example |
|---|---|
| Alert follow-up | Review activity surrounding a triggered alert |
| DLP investigations | Identify file transfers that triggered DLP policies |
| Insider threat investigations | Investigate suspicious user behavior |
| Browsing investigations | Identify users accessing risky websites |
| Privileged account monitoring | Monitor activity from administrative users |
| Anomaly follow-up | Investigate abnormal activity patterns |
| Data exposure review | Identify files shared externally |

Explorations are especially useful when an analyst needs to **search across multiple activity types simultaneously**.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Exploration%20Documentation&fontSize=26&fontColor=ffffff"/>
</p>

The following documents provide detailed guidance on working with Explorations.

| Document | Description |
|---|---|
| Creating Explorations | Step-by-step guide to building an Exploration |
| Smart Search Guidance | Using natural language queries to generate Exploration filters |
| Anomaly Investigation | Investigating behavioral anomalies detected by the platform |

Each document focuses on a specific aspect of the Exploration investigation workflow.

For example:

- **Creating Explorations** explains how to build filters and configure the source node.
- **Smart Search Guidance** explains how AI-assisted queries can generate initial explorations.
- **Anomaly Investigation** explains how Explorations are used during anomaly analysis.

Together, these documents provide a complete guide for using Explorations during security investigations.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Analyst%20Guidance&fontSize=26&fontColor=ffffff"/>
</p>

Explorations are most effective when analysts follow a structured investigation approach.

Recommended practices include:

1. Define the investigation objective clearly.
2. Confirm the correct region and data source.
3. Expand the time range if the investigation involves historical activity.
4. Start with one high-value filter such as the user involved in the alert.
5. Add additional filters gradually.
6. Review activity results carefully before refining the query.
7. Pivot into Timeline or Activity Player for deeper analysis.

Avoid starting with overly broad queries, as this often produces noisy results and slows investigations.

Instead, begin with the **known information from the alert or investigation trigger**, then refine the exploration as needed.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>
