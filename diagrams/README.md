# Diagrams

Visual architecture diagrams for the security controls and data flows documented in this portfolio. All diagrams use [Mermaid](https://mermaid.js.org/) and render natively on GitHub.

---

## Index

| Diagram | Domain | Related documentation |
|---|---|---|
| [Cloud Telemetry Ingestion](cloud-telemetry-ingestion-diagram.md) | Cloud Security | [`reference/sentinel/automate-deployment/`](../reference/sentinel/automate-deployment/) · [`reference/sentinel/manual/aws/`](../reference/sentinel/manual/aws/) |
| [Identity Security Architecture](identity-security-diagram.md) | Identity & Access | [`reference/identity-access/`](../reference/identity-access/) |
| [Security Automation](security-automation-diagram.md) | Automation | [`reference/automation/`](../reference/automation/) |
| [Security Integration](security-integration-diagram.md) | Platform Integration | [`reference/sentinel/`](../reference/sentinel/) · [`reference/automation/`](../reference/automation/) |
| [Security Monitoring](security-monitoring-diagram.md) | Detection Engineering | [`reference/sentinel/`](../reference/sentinel/) |
| [Sentinel Data Pipeline](sentinel-data-pipeline.md) | SIEM Engineering | [`reference/sentinel/`](../reference/sentinel/) |
| [Proofpoint AI Governance Flow](proofpoint-ai-governance-flow.md) | Email & AI Security | [`reference/email-security/guides/proofpoint/ai-governance/`](../reference/email-security/guides/proofpoint/ai-governance/) |
| [Incident Response Lifecycle](incident-response-lifecycle.md) | Incident Response | [`incident-response/`](../incident-response/) |
| [Umbrella DNS Security Flow](umbrella-dns-security-flow.md) | Network Security | [`reference/network-security/guides/umbrella/`](../reference/network-security/guides/umbrella/) |
| [Identity Authentication Decision](identity-authentication-decision-tree.md) | Identity & Access | [`reference/identity-access/policies/conditional-access/`](../reference/identity-access/policies/conditional-access/) |

---

## Architecture Overview

The diagrams in this folder map to five major security domains:

```
Identity & Access ──── how users authenticate and what they can access
        │
        ▼
Security Monitoring ── what is visible: logs, connectors, SIEM
        │
        ▼
Detection & Response ─ how threats are found and contained (IR lifecycle)
        │
        ▼
Platform Automation ── how controls are deployed and maintained consistently
        │
        ▼
Data Protection ──────  how sensitive data is governed (AI governance flow)
```

Each diagram reflects actual implementations documented in the `reference/` tree — not theoretical architecture.
