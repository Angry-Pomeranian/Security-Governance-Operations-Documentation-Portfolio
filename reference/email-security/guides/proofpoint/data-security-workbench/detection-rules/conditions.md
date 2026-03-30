<p align="center">
<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0EA5E9,100:2563EB&height=120&section=header&text=Detection%20Rule%20Conditions&fontSize=32&fontColor=ffffff&animation=fadeIn"/>
</p>

Conditions define **what activity must occur** for a detection rule to trigger an alert. A condition is the "IF" side of the rule's IF → THEN logic model.

When an observed activity matches all configured conditions, the rule fires and executes its configured action.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Condition%20Types&fontSize=26&fontColor=ffffff"/>
</p>

Conditions can be built from a variety of observable activity attributes.

| Condition Type | Description |
|---|---|
| Activity type | Specifies the kind of event to monitor (e.g. file copy, upload, login) |
| User or user group | Scopes the rule to specific users or organisational groups |
| Device or endpoint | Targets activity from specific managed endpoints |
| File name or extension | Monitors specific file types or naming patterns |
| Destination | Defines where data is being sent (e.g. USB device, cloud service, web domain) |
| Time window | Limits detection to specific hours or date ranges |
| Data classification | Triggers on activity involving files with a specific sensitivity label |
| Frequency threshold | Fires only when the activity exceeds a defined count within a time period |

Multiple conditions can be combined — all conditions must be satisfied for the rule to trigger.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Configuring%20Conditions&fontSize=26&fontColor=ffffff"/>
</p>

Conditions are defined when creating or editing a detection rule.

Steps:

1. Navigate to:

```
Administration → Policies → Rules → [Select or create a rule]
```

2. In the rule editor, locate the **Conditions** section

3. Click **Add Condition**

4. Select the condition type from the dropdown

5. Define the condition value or threshold

6. Repeat for each additional condition required

7. Save the rule

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Condition%20Best%20Practices&fontSize=26&fontColor=ffffff"/>
</p>

### Be specific

Broad conditions generate high alert volumes and reduce analyst efficiency. Narrow conditions to meaningful activity patterns.

### Combine activity type with destination

Pairing an activity type (e.g. file upload) with a destination (e.g. personal cloud storage) produces more actionable detections than either condition alone.

### Use user group scoping

Applying conditions to high-risk groups reduces noise while maintaining coverage where it matters most.

### Validate before full deployment

Test new conditions on a pilot group or in report-only mode before enabling organisation-wide.
