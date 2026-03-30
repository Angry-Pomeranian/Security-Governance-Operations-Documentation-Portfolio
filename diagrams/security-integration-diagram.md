# Security Integration Architecture Diagram

## Overview

Shows how the five security tool categories (identity, endpoint, email/web, network, cloud) are integrated through API and connector layers into the central SIEM, with outputs feeding SOC operations and governance reporting. This reflects the integrations documented across the portfolio's reference section.

---

## Architecture Diagram

```mermaid
flowchart TD
    IdentityTools[Identity Security Tools\nMicrosoft Entra ID · Intune] --> Integration[API and Connector Integration Layer\nAzure native connectors · Logic Apps · Azure Functions]
    EndpointTools[Endpoint Security Tools\nCrowdStrike Falcon] --> Integration
    EmailTools[Email Security Platforms\nProofpoint TAP · Proofpoint ITM] --> Integration
    NetworkTools[Network Security Platforms\nCisco Umbrella · Meraki] --> Integration
    CloudTools[Cloud Security Platforms\nAWS CloudTrail · GuardDuty · VPC Flow] --> Integration

    Integration --> Normalize[Data Normalisation and Mapping\nCEF · Syslog · Custom table schemas]
    Normalize --> Monitoring[Microsoft Sentinel\nLog Analytics Workspace]
    Monitoring --> SOC[SOC Operations\nAlerts · Investigations · Hunting]
    Monitoring --> Governance[Governance and Security Reporting\nWorkbooks · Scheduled reports]
```

---

## Related Documentation

- [`reference/automation/crowdstrike/`](../reference/automation/crowdstrike/) — CrowdStrike API integration modules
- [`reference/email-security/api/proofpoint/`](../reference/email-security/api/proofpoint/) — Proofpoint TAP Azure Function pipeline
- [`reference/network-security/api/meraki/`](../reference/network-security/api/meraki/) — Cisco Meraki API integration
- [`reference/sentinel/manual/`](../reference/sentinel/manual/) — Manual connector guides for all platforms
- [`reference/sentinel/workbooks/`](../reference/sentinel/workbooks/) — Governance dashboards per platform
