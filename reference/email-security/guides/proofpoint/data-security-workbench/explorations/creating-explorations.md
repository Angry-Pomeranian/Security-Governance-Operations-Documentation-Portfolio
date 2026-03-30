<p align="center">
<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0EA5E9,100:2563EB&height=120&section=header&text=Creating%20a%20New%20Exploration&fontSize=32&fontColor=ffffff&animation=fadeIn"/>
</p>

Creating an Exploration involves defining the investigation scope and then progressively refining the search using filter nodes.

A typical process includes:

1. opening a new Exploration
2. confirming the source node configuration
3. adding filter nodes
4. reviewing results
5. refining filters if needed
6. saving the Exploration if it will be reused

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

### Step 1: Open the Exploration view

Navigate to:

```

Proofpoint Data Security & Posture
→ Data Security Workbench
→ Activity
→ Explorations
→ New Exploration

```

When the new Exploration opens, the **source node is already present**.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

### Step 2: Review and adjust the source node

Click the source node to open its configuration panel.

Review the following settings:

- **Region**
- **Time**
- **Source**

Adjust these settings depending on the investigation.

Examples:

- set **30 days** if investigating repeated user behavior
- use **Endpoint Activity** for endpoint file or application activity
- include **Agent Telemetry** or **Audit Events** when investigating system-level events

Click **Done** once the source node configuration is correct.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

### Step 3: Add filter nodes

Click **+** to add a new filter node.

From the **Filter by** menu, select the field to search.

Examples of common filter areas include:

- User
- Activity
- Website
- Indicator
- Workflow
- File or Resource

After selecting the field:

1. choose the operator
2. enter or select the value
3. click **Done**

Each filter node narrows or expands the results depending on the configuration.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

### Step 4: Review results

As filters are added, the results panel updates automatically.

Review the results table and summary view to confirm the Exploration is returning the expected data.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

### Step 5: Save the Exploration

If the query proves useful, save it with a descriptive name.

Saved Explorations can later be reused by analysts investigating similar activity.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Example%20Explorations&fontSize=26&fontColor=ffffff"/>
</p>

Below are practical examples of Explorations used during real investigations.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

## Example Exploration: Monitor Admin DLP Activity

### Goal

Monitor **DLP activity performed by users in the admin group**.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

### Source Node

| Setting | Example Value |
|---|---|
| Region | US1 or relevant region |
| Time | Last 24 hours |
| Source | Endpoint Activity |

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

### Filter 1

| Setting | Value |
|---|---|
| Field | User → Groups |
| Operator | Includes |
| Value | admin |

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

### Filter 2

| Setting | Value |
|---|---|
| Field | Activity → Signal Type |
| Operator | Includes |
| Value | DLP |

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

### Result

The results table shows **DLP-related endpoint activity performed by members of the admin group**.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

### Why This Exploration Is Useful

Privileged users often have wider access to sensitive systems and data.

Filtering for **admin group users and DLP signals** can help detect risky data handling behavior by high-privilege accounts.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

## Example Exploration: Monitor VAP Users Over 30 Days

### Goal

Review activity for users marked as **VAP (Very Attacked People)** over a longer period.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

### Source Node

| Setting | Example Value |
|---|---|
| Region | Relevant region |
| Time | 30 days |
| Source | CASB or cloud activity source |

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

### Filter 1

| Setting | Value |
|---|---|
| Field | VAP property |
| Operator | Includes |
| Value | Yes |

This returns activity performed by VAP users during the selected period.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

### Adding Risk Visibility

To extend the Exploration, add another filter.

### Filter 2

| Setting | Value |
|---|---|
| Field | Indicator → Risk Level |
| Operator | Includes |
| Value | Select all values |

This adds **Risk Level visibility** so analysts can see whether VAP activity is classified as:

- low risk
- medium risk
- high risk
- critical risk

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

### Why This Exploration Is Useful

This exploration combines:

- user exposure level
- observed activity
- Proofpoint risk scoring

This helps analysts determine which high-exposure users may require closer monitoring.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

## Example Exploration: Review Web Activity by Category

### Goal

Identify users browsing **gaming websites**.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

### Source Node

| Setting | Example Value |
|---|---|
| Region | Relevant region |
| Time | Last 7 days |
| Source | Web or endpoint browsing activity |

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

### Filter 1

| Setting | Value |
|---|---|
| Field | Website → Categories Type |
| Operator | Includes |
| Value | Games |

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

### Result

The results show:

- URLs accessed
- users who accessed them
- timestamps of browsing activity

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

### Why This Exploration Is Useful

This type of exploration can support:

- acceptable use investigations
- productivity monitoring
- policy enforcement
- validation of browsing policies

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Choosing%20the%20Right%20Time%20Range&fontSize=26&fontColor=ffffff"/>
</p>

Selecting the correct time range is one of the most important factors when building an Exploration.

| Investigation Type | Suggested Time Range |
|---|---|
| Immediate alert follow-up | Last 24 hours |
| Repeated suspicious behavior | Last 7 to 30 days |
| User trend review | 30 days |
| Historical investigation | Custom range |

A common mistake is leaving the **default 24-hour window** unchanged.

Always confirm the time filter before assuming the activity does not exist.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Choosing%20the%20Right%20Source&fontSize=26&fontColor=ffffff"/>
</p>

The **source node determines which activity data is available** to the Exploration.

| Source Type | Typical Use Case |
|---|---|
| Endpoint Activity | File operations, application activity, USB events |
| Agent Telemetry | Agent system events |
| Audit Events | Platform audit logs |
| Platform Detections | Anomaly or detection data |

If results appear incomplete, confirm that the source node matches the type of event being investigated.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>
