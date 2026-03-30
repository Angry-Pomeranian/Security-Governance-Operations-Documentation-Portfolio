# Sentinel Data Pipeline

## Overview

This diagram shows the end-to-end Microsoft Sentinel data ingestion pipeline as implemented in this portfolio — from AWS and Azure/SaaS log sources through connector deployment and ingestion into Log Analytics, to analytics rules, hunting content, workbooks, and SOC response.

This reflects the actual content in [`reference/sentinel/`](../reference/sentinel/): the AWS automation scripts, CloudFormation templates, manual connector guides, KQL hunting queries, and workbook JSON files.

---

## Architecture Diagram

```mermaid
flowchart TD
    subgraph AWS["AWS Log Sources"]
        CT[AWS CloudTrail]
        GD[AWS GuardDuty]
        VPC[AWS VPC Flow Logs]
        CW[AWS CloudWatch Logs]
    end

    subgraph AzureSaaS["Azure / SaaS Log Sources"]
        EntraID[Microsoft Entra ID\nSign-in & Audit Logs]
        M365[Microsoft 365\nOffice Activity]
        DevOps[Azure DevOps]
        PP[Proofpoint TAP\nClick & Message Events]
        Umbrella[Cisco Umbrella\nDNS Events]
    end

    subgraph Transport["AWS Transport Layer"]
        S3[S3 Bucket]
        SQS[SQS Queue]
        Lambda[CloudWatch Lambda\nForwarder]
    end

    subgraph Connectors["Connector Layer"]
        AWSCT[CloudTrail Connector\nConfigAwsConnector.ps1]
        AWSGD[GuardDuty Connector\nConfigGuardDutyDataConnector.ps1]
        AWSVPC[VPC Flow Connector\nConfigVpcFlowDataConnector.ps1]
        AWSCW[CloudWatch Connector\nConfigCloudWatchDataConnector.ps1]
        AzureConn[Azure Native Connectors\nDiagnostic Settings / Office Conn]
        PPConn[Proofpoint TAP Connector\nAzure Function + Logic App]
        UmbrellaConn[Cisco Umbrella Connector]
    end

    subgraph Sentinel["Microsoft Sentinel — Log Analytics Workspace"]
        LA[Log Analytics Ingestion]
        Analytics[Analytics Rules\nScheduled / ML Behaviour]
        Hunting[Hunting Queries\nKQL — MITRE ATT&CK aligned]
        Workbooks[Workbooks / Dashboards\n18+ platform dashboards]
        Watchlists[Watchlists\nDeployment tracker · Allow lists]
    end

    subgraph SOC["Security Operations"]
        Incidents[Incident Queue]
        Investigate[Investigation — Timeline · Entity]
        IR[IR Playbooks\nISO 27001 · NIST 800-61]
    end

    CT --> S3
    GD --> S3
    VPC --> S3
    CW --> Lambda

    S3 --> SQS
    SQS --> AWSCT
    SQS --> AWSGD
    SQS --> AWSVPC
    Lambda --> AWSCW

    EntraID --> AzureConn
    M365 --> AzureConn
    DevOps --> AzureConn
    PP --> PPConn
    Umbrella --> UmbrellaConn

    AWSCT --> LA
    AWSGD --> LA
    AWSVPC --> LA
    AWSCW --> LA
    AzureConn --> LA
    PPConn --> LA
    UmbrellaConn --> LA

    LA --> Analytics
    LA --> Hunting
    LA --> Workbooks
    LA --> Watchlists

    Analytics --> Incidents
    Hunting --> Incidents
    Workbooks --> Incidents
    Incidents --> Investigate
    Investigate --> IR
```

---

## Related Documentation

- [`reference/sentinel/automate-deployment/`](../reference/sentinel/automate-deployment/) — PowerShell scripts that configure each AWS connector (`ConfigAwsConnector.ps1`, `ConfigGuardDutyDataConnector.ps1`, etc.)
- [`reference/sentinel/manual/`](../reference/sentinel/manual/) — Manual connector setup guides (AWS, Azure, Cisco Umbrella, Proofpoint TAP)
- [`reference/sentinel/hunting/`](../reference/sentinel/hunting/) — KQL threat hunting queries
- [`reference/sentinel/workbooks/`](../reference/sentinel/workbooks/) — Dashboard JSON for 18+ platforms
- [`reference/sentinel/templates/`](../reference/sentinel/templates/) — ARM templates for analytics rules and ML behaviour analytics
- [`reference/email-security/api/proofpoint/`](../reference/email-security/api/proofpoint/) — Proofpoint TAP Azure Function pipeline
