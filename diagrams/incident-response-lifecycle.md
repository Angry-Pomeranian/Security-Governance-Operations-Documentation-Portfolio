# Incident Response Lifecycle

## Overview

This diagram shows the incident response lifecycle used across all nine playbooks in this portfolio. It maps each phase to the tools, data sources, and decision points that appear consistently in the playbooks — from initial detection through post-incident review. The lifecycle is aligned to ISO 27001:2022 Annex A.5.26 and NIST SP 800-61 Rev 2.

---

## Lifecycle Diagram

```mermaid
flowchart TD
    subgraph Detection["Phase 1 — Detection & Alerting"]
        Sentinel[Microsoft Sentinel\nAnalytics Rule Fires]
        Proofpoint[Proofpoint TAP / TRAP\nPhishing / BEC Detected]
        CrowdStrike[CrowdStrike Falcon\nEndpoint Alert]
        UserReport[User Report\nPhishAlarm / IT Helpdesk]
        Sentinel --> Alert
        Proofpoint --> Alert
        CrowdStrike --> Alert
        UserReport --> Alert
        Alert[Alert Created\nSeverity: Low · Medium · High · Critical]
    end

    subgraph Triage["Phase 2 — Triage"]
        Alert --> Assign[Assign to Analyst]
        Assign --> Enrich[Enrich Alert\nEntity lookup · IP reputation · User history]
        Enrich --> Verdict{Verdict}
        Verdict -->|FP| Close[Close — False Positive\nDocument · Tune rule]
        Verdict -->|Confirmed| Contain
    end

    subgraph Containment["Phase 3 — Containment"]
        Contain[Containment Actions]
        Contain --> IsoDevice[Isolate Endpoint\nCrowdStrike network contain]
        Contain --> DisableAcct[Disable User Account\nEntra ID / reset credentials]
        Contain --> RevokeSession[Revoke Sessions & Tokens\nAll active sessions terminated]
        Contain --> BlockIP[Block Malicious IP/Domain\nSentinel watchlist · Umbrella block]
        Contain --> TRAP[TRAP Email Pull\nRemove from all inboxes]
    end

    subgraph Eradication["Phase 4 — Eradication"]
        IsoDevice --> Forensic[Forensic Preservation\nMemory · Disk · Logs]
        DisableAcct --> ScopeReview[Scope Review\nOther affected users / systems]
        Forensic --> Remove[Remove Malicious Artefacts\nMalware · Persistence · Backdoors]
        ScopeReview --> Remove
        Remove --> PatchVuln[Patch / Remediate\nVulnerability that was exploited]
    end

    subgraph Recovery["Phase 5 — Recovery"]
        PatchVuln --> Restore[Restore Services\nValidate integrity before reconnecting]
        Restore --> Monitor[Enhanced Monitoring\n72-hour elevated watch]
        Monitor --> ReenableAcct[Re-enable Account\nWith MFA re-enrolment required]
    end

    subgraph PostIncident["Phase 6 — Post-Incident Review"]
        ReenableAcct --> PIR[Post-Incident Report\nTimeline · Root cause · Impact]
        PIR --> Lessons[Lessons Learned\nDetection gaps · Response gaps]
        Lessons --> TuneRules[Tune Detection Rules\nKQL · Sentinel analytics]
        Lessons --> UpdatePlaybook[Update Playbooks\nRevise procedures]
        Lessons --> TrainUsers[User Awareness\nTargeted training if human error]
    end
```

---

## Playbooks Using This Lifecycle

| Playbook | Key detection source | Primary containment action |
|---|---|---|
| [Account Compromise](../incident-response/account-compromise-playbook.md) | Sentinel signin anomaly | Disable account + revoke sessions |
| [BEC](../incident-response/business-email-compromise-playbook.md) | Proofpoint TAP / user report | TRAP pull + OAuth revocation |
| [Cloud Account Compromise](../incident-response/cloud-account-compromise-playbook.md) | Sentinel / AWS GuardDuty | Revoke IAM credentials |
| [Data Exfiltration](../incident-response/data-exfiltration-response-playbook.md) | Proofpoint DLP / Sentinel | Block egress + isolate endpoint |
| [Malicious Code Execution](../incident-response/malicious-code-execution-playbook.md) | CrowdStrike Falcon | Network contain endpoint |
| [Network Intrusion](../incident-response/network-intrusion-playbook.md) | Sentinel network analytics | Block IP + segment network |
| [Phishing](../incident-response/phishing-investigation-playbook.md) | Proofpoint TAP | TRAP pull + disable clicked links |
| [Privileged Access Abuse](../incident-response/privileged-access-abuse-playbook.md) | Sentinel PIM logs | Revoke PIM role + audit access |
| [Ransomware](../incident-response/ransomware-response-playbook.md) | CrowdStrike / Sentinel | Immediate network contain |

---

## Related Documentation

- [`incident-response/`](../incident-response/) — All nine incident response playbooks
- [`reference/sentinel/`](../reference/sentinel/) — Sentinel analytics rules and hunting content
- [`reference/identity-access/`](../reference/identity-access/) — Account containment controls (Conditional Access, PIM)
