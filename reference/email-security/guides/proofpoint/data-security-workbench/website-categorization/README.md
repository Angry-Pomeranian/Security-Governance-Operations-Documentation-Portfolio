<p align="center">
<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0EA5E9,100:2563EB&height=120&section=header&text=Website%20Categorization&fontSize=32&fontColor=ffffff&animation=fadeIn"/>
</p>

Website categorization is a feature within **Proofpoint Data Security Workbench** that classifies websites based on observed browsing activity.

These categories allow security teams to monitor how users interact with external websites and identify browsing behavior that may introduce **data risk, security exposure, or policy violations**.

Website categories are commonly used to:

- monitor employee browsing behavior
- identify risky website access
- detect access to suspicious or prohibited domains
- support acceptable use policy enforcement
- investigate insider risk indicators
- generate alerts or detection rules based on website activity

Website categorization data is typically collected through **endpoint activity monitoring** and can be analyzed using **Explorations, alerts, and investigation tools** within the platform.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

## Contents

| Topic | Description |
|---|---|
| 🌐 [What Website Categorization Is](#what-website-categorization-is) | How Proofpoint classifies websites |
| 🧠 [How Website Categories Are Used](#how-website-categories-are-used) | Investigation and monitoring use cases |
| 🗂️ [Common Website Categories](#common-website-categories) | Examples of platform classifications |
| 🔎 [Example Investigation](#example-investigation) | Using categories during investigations |

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=What%20Website%20Categorization%20Is&fontSize=26&fontColor=ffffff"/>
</p>

Proofpoint categorizes websites by analyzing browsing activity observed through monitored endpoints and integrated telemetry sources.

Each website accessed by a user may be classified into one or more **category types**. These categories help analysts understand the type of website being accessed without manually reviewing every domain.

Examples include:

- entertainment websites
- social media platforms
- AI tools
- peer-to-peer services
- malicious or suspicious domains

Website categorization allows analysts to quickly answer questions such as:

- Are users visiting risky or suspicious websites?
- Are employees accessing non-work-related websites during investigations?
- Is a user interacting with services that could enable data exfiltration?
- Is a user accessing websites that may violate internal policies?

This capability provides valuable **context during investigations**, especially when browsing behavior is related to other suspicious activity.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=How%20Website%20Categories%20Are%20Used&fontSize=26&fontColor=ffffff"/>
</p>

Website categories can be used across several investigation workflows.

Common uses include:

### Monitoring risky browsing behavior

Security teams may monitor categories associated with higher risk, such as:

- peer-to-peer file sharing
- suspicious domains
- malware-related sites
- anonymization or proxy services

These categories may indicate attempts to bypass security controls or interact with unsafe infrastructure.

### Acceptable use monitoring

Organizations may also use website categories to identify browsing activity that violates internal **acceptable use policies**, such as:

- gambling
- gaming
- streaming services
- social networking during work hours

While not always a security threat, this type of activity may still be relevant during investigations.

### Data exfiltration context

Some website categories may be associated with **data movement risks**, such as:

- cloud storage services
- generative AI platforms
- collaboration tools
- file sharing services

If a user is suspected of attempting data exfiltration, reviewing website activity may help determine whether files were uploaded to external services.

### Detection rule creation

Website categories can also be used when creating:

- **Explorations**
- **detection rules**
- **alerts**

This allows organizations to automatically flag browsing activity that matches defined risk criteria.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Common%20Website%20Categories&fontSize=26&fontColor=ffffff"/>
</p>

Proofpoint maintains a large taxonomy of website categories. The exact categories available may vary depending on platform configuration and telemetry.

Examples include:

| Category | Description |
|---|---|
| Generative AI | AI platforms that generate content, code, or media |
| Social Networking | Social media platforms such as community and messaging sites |
| Peer to Peer | Torrent networks and decentralized file sharing platforms |
| Malware Sites | Domains associated with malicious activity |
| Gambling | Online betting or gaming platforms |
| Games | Online gaming websites |
| Cloud Storage | File hosting or sharing platforms |
| Productivity Tools | Collaboration and document tools |

During investigations, analysts typically filter on the **Website → Categories Type** field to locate browsing activity that falls into one or more categories.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Example%20Investigation&fontSize=26&fontColor=ffffff"/>
</p>

### Investigation Goal

Identify users browsing **gaming websites**.

This investigation may be performed to:

- review acceptable use violations
- understand browsing behavior during a larger investigation
- identify distractions during incident timelines

### Exploration Filter Configuration

| Setting | Value |
|---|---|
| Field | Website → Categories Type |
| Operator | Includes |
| Value | Games |

### Investigation Result

This exploration returns activity where users accessed websites categorized as **Games**.

Analysts can then review:

- which users accessed the websites
- timestamps of browsing activity
- specific URLs visited
- whether browsing occurred alongside other suspicious activity

Website categorization is often most useful when combined with other signals such as:

- DLP alerts
- anomaly detections
- high-risk user activity
- file transfers or uploads

By combining browsing activity with these signals, analysts can better determine whether the activity represents **benign behavior, policy violations, or malicious intent**.
