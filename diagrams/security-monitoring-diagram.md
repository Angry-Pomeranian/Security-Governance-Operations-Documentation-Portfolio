# Security Monitoring Architecture Diagram

## Overview

Shows the centralised security monitoring architecture: five log source categories flow through connectors into Microsoft Sentinel, where they feed detection analytics, threat hunting queries, and workbook dashboards consumed by the SOC. This is the detection and visibility layer documented throughout the Sentinel section of this portfolio.

---

## Architecture Diagram

```mermaid
flowchart TD
    Identity[Identity Logs\nEntra ID SigninLogs · AuditLogs · AADNonInteractive] --> Connectors[Connector and Ingestion Layer\nNative connectors · Azure Functions · Syslog CEF]
    Cloud[Cloud Security Logs\nAWS CloudTrail · GuardDuty · VPC Flow] --> Connectors
    Endpoint[Endpoint and EDR Logs\nCrowdStrike · Defender for Endpoint] --> Connectors
    Network[Network and Firewall Logs\nCisco Umbrella DNS · Meraki · Palo Alto · FortiGate] --> Connectors
    SaaS[SaaS Security Events\nProofpoint TAP · Microsoft 365 · Azure DevOps] --> Connectors

    Connectors --> SIEM[Microsoft Sentinel\nLog Analytics Workspace]
    SIEM --> Analytics[Detection Analytics Rules\nScheduled rules · ML behaviour analytics · Fusion]
    SIEM --> Hunting[Threat Hunting Queries\nKQL — MITRE ATT&CK mapped]
    SIEM --> Dashboards[Workbooks and Dashboards\n18+ platform dashboards]

    Analytics --> SOC[SOC Investigations\nIncident triage · Entity investigation · IR playbooks]
    Hunting --> SOC
    Dashboards --> SOC
```

---

## Related Documentation

- [`reference/sentinel/`](../reference/sentinel/) — All Sentinel deployment resources, queries, templates, and workbooks
- [`reference/sentinel/hunting/`](../reference/sentinel/hunting/) — KQL threat hunting content
- [`reference/sentinel/templates/`](../reference/sentinel/templates/) — Analytics rule ARM templates
- [`reference/sentinel/workbooks/`](../reference/sentinel/workbooks/) — Dashboard JSON files for all 18+ platforms
- [Sentinel Data Pipeline diagram](sentinel-data-pipeline.md) — Detailed version showing source-to-SOC pipeline components
