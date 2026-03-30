# Cloud Telemetry Ingestion Architecture Diagram

## Overview

High-level view of the AWS-to-Sentinel telemetry pipeline. AWS log sources are forwarded via S3/SQS transport to Sentinel connector scripts, ingested into Log Analytics, and surfaced through cloud-specific detection rules and dashboards.

For the detailed implementation including all PowerShell connector scripts, CloudFormation templates, and step-by-step connector guides, see [`reference/sentinel/`](../reference/sentinel/).

---

## Architecture Diagram

```mermaid
flowchart TD
    CloudTrail[AWS CloudTrail] --> Transport[Cloud Storage and Queue Transport\nS3 · SQS · Lambda]
    GuardDuty[AWS GuardDuty] --> Transport
    VPCFlow[AWS VPC Flow Logs] --> Transport
    CloudWatch[AWS CloudWatch Logs] --> Transport

    Transport --> Connectors[Ingestion Connector Layer\nPowerShell automation scripts]
    Connectors --> SIEM[Microsoft Sentinel\nLog Analytics Workspace]

    SIEM --> Detection[Cloud Detection and Hunting\nKQL analytics · Hunting queries]
    SIEM --> Dashboards[Cloud Monitoring Dashboards\nWorkbook JSON]
    Detection --> SOC[Security Operations Team]
    Dashboards --> SOC
```

---

## Related Documentation

- [`reference/sentinel/automate-deployment/`](../reference/sentinel/automate-deployment/) — PowerShell connector automation scripts
- [`reference/sentinel/manual/aws/`](../reference/sentinel/manual/aws/) — Manual connector onboarding guides (CloudTrail, GuardDuty)
- [`reference/sentinel/workbooks/`](../reference/sentinel/workbooks/) — Dashboard JSON files
- [Sentinel Data Pipeline diagram](sentinel-data-pipeline.md) — Detailed version of this diagram with all source types and sub-components
