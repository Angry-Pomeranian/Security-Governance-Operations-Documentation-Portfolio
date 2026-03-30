# Workflow Status

Workflow statuses are **states assigned to alerts and investigations** to track their progress through the review and resolution process. Each alert moves through a lifecycle from initial detection to final resolution, and workflow statuses communicate where in that lifecycle an alert currently sits.

---

# Default Workflow Statuses

Proofpoint Data Security Workbench includes a set of default workflow statuses.

| Status | Meaning |
|---|---|
| New | Alert has been generated and not yet reviewed |
| In Review | An analyst has opened the alert and is actively investigating |
| Pending | Investigation is paused, awaiting additional information or a response |
| Escalated | Alert has been escalated to a senior analyst, incident response team, or HR |
| Resolved | Investigation is complete and the alert has been closed |
| False Positive | Alert was confirmed as non-malicious activity; no further action required |

---

# Updating Workflow Status

Steps:

1. Open an alert in the **Alerts dashboard**

2. Locate the **Status** field in the alert record

3. Select the appropriate status from the dropdown

4. Optionally, add a **Justification** note to explain the status change

5. Save

Status changes are logged in the alert's audit history, allowing teams to track when each transition occurred and who made it.

---

# Custom Workflow Statuses

Organisations can define custom workflow statuses to match their internal processes.

To create a custom status:

1. Navigate to:

```
Administration → Definitions → Workflow Status
```

2. Click **New Status**

3. Provide:
   - **Name** — descriptive label for the status
   - **Description** — what the status represents in your workflow

4. Save

Custom statuses appear alongside default statuses in the alert status dropdown.

---

# Workflow Status in Reporting

Workflow statuses can be used to filter and report on alert activity.

Common reporting use cases include:

- Tracking the number of alerts in **New** status at any given time (backlog visibility)
- Measuring mean time to review for alerts in **In Review** status
- Reporting on resolution rates and false positive rates over a period
- Identifying alerts that have been in **Pending** status for extended periods
