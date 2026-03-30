# Detection Architecture

The detection architecture in Proofpoint Data Security Workbench describes how raw telemetry from monitored sources is ingested, evaluated against detection logic, and surfaced as actionable alerts for security analysts.

---

# Data Collection Layer

Telemetry is collected from multiple sources across the organisation.

| Source | Data Collected |
|---|---|
| Endpoint agents | File operations, application activity, clipboard events, USB activity |
| CASB connectors | Cloud storage uploads/downloads, sharing activity, access events |
| Web proxy / browser | Browsing activity, file uploads to web destinations |
| Email | Outbound email attachments, forwarding rules, large send events |
| Network | Data transfer volumes, destination monitoring |

Endpoint agents run on managed Windows and macOS devices and forward telemetry to the Proofpoint cloud platform for analysis.

---

# Detection Evaluation Layer

Once telemetry is ingested, it is evaluated against configured detection logic.

```
Raw Telemetry
↓
Normalisation and Enrichment
↓
Rule Evaluation (Detection Rules + Threat Library)
↓
Anomaly Detection (Behavioural Baseline Comparison)
↓
CASB DLP Policy Evaluation
↓
Website Categorisation
↓
Alert Generation (when condition met)
```

Detection evaluation runs continuously. As new telemetry arrives, it is assessed in near real-time against all enabled detection rules and policies.

---

# Alert Generation

When detected activity satisfies the conditions of an enabled rule or policy, an alert is generated automatically.

Alerts include:

- the triggering rule or policy name
- the user associated with the activity
- the endpoint or source
- a timestamp and activity description
- severity level
- links to supporting evidence (file details, activity timeline, Explorations)

Alerts appear immediately in the **Alerts dashboard** for analyst review.

---

# User Behaviour Baseline

The platform builds a behavioural baseline for each monitored user over time. This baseline represents the user's typical activity patterns — file operations, access times, upload volumes, and application usage.

Anomaly detection compares new activity against this baseline. Significant deviations — such as unusually large file transfers, activity at unusual hours, or access to systems the user does not normally interact with — are flagged for review.

Baseline modelling improves over time as more telemetry is collected.

---

# Related

- [Architecture Overview](README.md)
- [Investigation Workflow](investigation-workflow.md)
- [Detection Rules](../detection-rules/README.md)
- [Threat Library](../detection-rules/threat-library.md)
