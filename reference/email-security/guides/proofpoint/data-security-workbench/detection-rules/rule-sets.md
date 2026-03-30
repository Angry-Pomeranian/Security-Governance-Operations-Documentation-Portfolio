<p align="center">
<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0EA5E9,100:2563EB&height=120&section=header&text=Rule%20Sets&fontSize=32&fontColor=ffffff&animation=fadeIn"/>
</p>

Rule sets are **named collections of detection rules** that are grouped together for organisational or operational purposes. Grouping rules into sets makes it easier to manage large rule libraries, apply rules to specific user populations, and maintain separation between detection use cases.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Why%20Use%20Rule%20Sets&fontSize=26&fontColor=ffffff"/>
</p>

Rule sets help security teams organise detection coverage by use case, risk level, or user population.

Common rule set patterns include:

| Rule Set Example | Purpose |
|---|---|
| Insider Threat — High Risk Users | Rules scoped to users flagged as elevated risk |
| Data Exfiltration — Finance | Rules targeting financial data movements for finance team members |
| USB and Removable Media | Rules monitoring all removable device activity |
| Cloud Upload Monitoring | Rules covering uploads to personal cloud services |
| Privileged User Activity | Rules focused on administrator and privileged account behaviour |

Organising rules into sets makes it easier to enable or disable groups of rules during investigations or policy changes without affecting unrelated detections.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Creating%20a%20Rule%20Set&fontSize=26&fontColor=ffffff"/>
</p>

Steps:

1. Navigate to:

```
Administration → Policies → Rule Sets
```

2. Click **New Rule Set**

3. Provide:
   - **Name** — descriptive name reflecting the use case or population
   - **Description** — brief summary of what the rule set monitors

4. Add existing rules to the set, or create new rules and assign them to this set

5. Save the rule set

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Managing%20Rule%20Sets&fontSize=26&fontColor=ffffff"/>
</p>

Rule sets can be enabled or disabled as a group, allowing analysts to quickly activate or deactivate a full set of detections during an investigation or response.

### Assigning rules to a set

Rules can be assigned to a rule set during rule creation or by editing an existing rule and updating its set assignment.

### Reviewing rule set coverage

Periodically review each rule set to ensure:
- Rules remain relevant to the current threat landscape
- No duplicate coverage exists across sets
- Sets are aligned with current organisational policy and risk appetite

### Disabling a rule set

If a rule set needs to be temporarily deactivated (e.g. during a planned maintenance window or system migration), disable the set rather than deleting individual rules to preserve the configuration.
