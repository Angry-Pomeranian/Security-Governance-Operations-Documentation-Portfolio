# Case Study: SIEM Monitoring Foundation Deployment (Microsoft Sentinel)

**Domain:** Security Operations & SIEM Engineering
**Focus Areas:** SIEM Deployment · Log Ingestion Challenges · Detection Foundation · SOC Enablement
**Platform:** Microsoft Sentinel (Azure)
**Standard Alignment:** ISO/IEC 27001:2022 · NIST CSF (Detect/Respond)
**Status:** Implemented and Stabilised

---

## Overview

The organisation needed a centralised SIEM capability to unify monitoring across identity, cloud, endpoint, and network systems. Security telemetry already existed across multiple platforms, but it was fragmented, inconsistently ingested, and difficult to actually use for investigation or reporting.

This case study documents the process of standing up Microsoft Sentinel from scratch, with an honest focus on what that actually involves: getting connectors to work reliably, dealing with data that arrives in formats you can't query, building detection content incrementally, and making the platform something analysts actually trust rather than something that generates noise.

---

## Context & Motivation

Analysts were pivoting between multiple tools to investigate a single event, which was slow and inconsistent. There was no unified platform for correlating events, tracking incidents, or producing consistent reporting. Leadership visibility was poor because data was siloed. And with an expanding AWS and SaaS footprint, log volume and complexity had outpaced any manual monitoring approach.

The goal was a platform that could do all of this. The reality was that getting there required significantly more troubleshooting than the documentation suggests.

---

## Security Challenge

The primary challenge was not deploying Sentinel. That part is straightforward. The challenge was making it actually usable and reliable, which turned out to be a much longer process than expected.

Connectors would show as connected but not ingest data. Logs would arrive in formats that were difficult to query without significant normalisation work. Detection content could not be built meaningfully until the data structure was understood. And analysts could not trust the platform until there was a clear model for validating that what they were seeing was complete and current.

The specific issues that caused the most time:

**Ingestion reliability.** AWS connector setup (CloudTrail, GuardDuty, S3) required working across trails, bucket configuration, IAM role trust relationships, and connector settings simultaneously. Any one of those being misconfigured meant logs appeared to be configured but weren't flowing. The "connected" status in the connector UI is not a reliable indicator of working ingestion. Every source needs to be validated with real data.

**Inconsistent source formats.** Each log source had different field naming conventions and event structures. Writing a query that worked across sources required understanding those differences upfront, which required spending time just exploring and mapping data before any detection work could happen.

**No baseline detection maturity.** The SIEM had data (eventually), but no usable intelligence. Analytics rules, hunting queries, and correlation logic all had to be built from scratch, which meant prioritising what mattered most before writing anything.

---

## Implementation

### Prioritisation

Onboarding sequence was determined by risk and investigation value, not connector availability. Identity (Entra ID sign-in logs) and cloud (AWS CloudTrail, GuardDuty) were first because those sources had the highest concentration of interesting events. Endpoint (CrowdStrike) and email (Proofpoint) followed.

### Connector Deployment and Troubleshooting

Every integration required reviewing documentation, validating permissions, and testing ingestion manually before treating it as done. Common issues included incorrect IAM role trust relationships for AWS sources, misconfigured S3 bucket permissions, logs not being written to expected paths, and connectors showing connected status without actual data flow. Iteration was required on most sources.

### Ingestion Validation Model

A structured validation approach was introduced rather than relying on connector status indicators. Checks included confirming log presence in Sentinel tables, validating event timestamps and expected volume, confirming field completeness, and comparing source system logs against Sentinel ingestion to identify gaps. This caught silent failures that would otherwise have produced blind spots in detection.

```kql
// Check last ingest time per table to identify stale sources
union withsource=TableName *
| summarize LastEvent = max(TimeGenerated) by TableName
| where LastEvent < ago(2h)
| order by LastEvent asc
```

### Data Normalisation and Query Usability

Early ingestion revealed field inconsistencies that made cross-source queries difficult. Effort was put into standardising key fields where possible (user identifiers, IP addresses, event types) and building baseline KQL queries to explore data structure and identify gaps before building detection logic on top of it.

### Detection and Hunting Content

Detection was built progressively rather than trying to build everything at once. Initial focus was basic anomaly detection and high-risk activity patterns. Expanded into cloud activity monitoring for AWS API usage, identity anomaly detection for unusual sign-in behaviour, and endpoint alert correlation. Hunting queries were developed to explore unknown patterns and validate that detection logic was firing correctly.

### Workbooks and Dashboards

Workbooks were built for three distinct audiences: operational monitoring (ingestion health, log volume trends), SOC visibility (incident trends, alert distribution), and management reporting (high-level posture, risk trends). Keeping these separate rather than trying to build one dashboard for everyone made each more useful.

### SOC Workflow Enablement

Basic operational processes were established alongside the platform: triage workflows for alerts, investigation steps using Sentinel data, and a feedback loop from analyst findings back into detection improvements. The detection tuning cycle became useful once analysts were actually working in the platform regularly.

---

## Outcomes

Single platform for cross-domain monitoring, with reduced need to pivot between tools during investigations. Analysts could follow repeatable workflows with consistent access to the context they needed. Detection logic improved over time as hunting informed analytics tuning. New integrations became progressively easier after the initial patterns and validation model were established.

**Key observations:**

Getting data in reliably is the hardest part of a SIEM deployment. Detection maturity cannot scale until ingestion is stable. Connected does not mean working — validation with real data is the only reliable check. Start simple with detection. Complex analytics built on poorly understood data structure are worse than simple queries built on data you trust. SOC workflows have to be built alongside the platform, not after it. Technology does not improve operations on its own.

---

*Organisational identifiers, client data, and commercially sensitive information have been omitted.*
