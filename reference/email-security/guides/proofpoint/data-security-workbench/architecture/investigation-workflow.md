# Investigation Workflow

The investigation workflow describes how security analysts move from an initial alert to a final resolution decision within Proofpoint Data Security Workbench. Following a consistent workflow ensures thorough investigation and supports accurate, audit-ready documentation.

---

# Workflow Overview

```
Alert Generated
↓
Analyst Reviews Alert
↓
Initial Triage (Is this real activity? Is it risky?)
↓
Deep Investigation (Explorations, Timeline, Data Catalog)
↓
User Context Review (Is this in-scope behaviour for this user?)
↓
Determination (False Positive / Policy Violation / Confirmed Incident)
↓
Action (Close / Escalate / Notify HR or Legal)
↓
Justification Recorded
↓
Alert Resolved
```

---

# Stage 1: Alert Triage

When a new alert appears in the Alerts dashboard:

1. Open the alert and review the summary
2. Identify the user, activity type, and triggering rule
3. Assess the severity level assigned by the detection rule
4. Determine whether the activity is anomalous given the user's role and typical behaviour
5. Set the workflow status to **In Review**

---

# Stage 2: Deep Investigation

For alerts that require further analysis:

1. **Explorations** — run a query scoped to the user and time window to review surrounding activity; look for patterns that confirm or contradict the alert
2. **Timeline** — review a chronological view of the user's activity before and after the alert event; identify correlated actions (e.g. bulk file access followed by USB copy)
3. **Data Catalog** — if files are involved, review their classification and access history
4. **User Activity Player** — for supported endpoints, review a session recording of the activity that triggered the alert

---

# Stage 3: User Context

Before making a final determination, consider the user context:

| Factor | Questions to Ask |
|---|---|
| Role | Does this activity align with the user's job function? |
| Risk profile | Is the user on a watchlist, under a PIP, or in a departure process? |
| Prior alerts | Has this user generated similar alerts previously? |
| Approved exceptions | Is this activity covered by an approved policy exception? |
| Corroborating signals | Are there HR, manager, or ticketing system signals that explain the activity? |

---

# Stage 4: Determination and Action

After completing the investigation, make a formal determination:

| Determination | Action |
|---|---|
| False positive | Close the alert; tune the detection rule if the pattern is recurring |
| Policy violation (minor) | Document finding; notify user's manager if required by policy |
| Policy violation (significant) | Escalate to HR or legal; preserve evidence; initiate formal process |
| Confirmed incident | Escalate to incident response; follow the IR playbook |
| Approved exception | Close the alert; document the exception in the justification field |

---

# Stage 5: Documentation

Before closing the alert:

1. Update the **workflow status** to reflect the outcome
2. Add a **justification** with sufficient detail for audit review
3. Note any tuning actions taken on the triggering rule
4. If escalated, record the escalation path and any ticket numbers

---

# Related

- [Architecture Overview](README.md)
- [Detection Architecture](detection-architecture.md)
- [Alert Triage Runbook](../alerts/alert-triage-runbook.md)
- [Alerts Overview](../alerts/README.md)
