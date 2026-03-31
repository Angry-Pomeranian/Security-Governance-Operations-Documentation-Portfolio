# Case Study: SIEM Monitoring Foundation Deployment (Microsoft Sentinel)

**Domain:** Security Operations & SIEM Engineering
**Focus Areas:** SIEM Deployment · Log Ingestion Challenges · Detection Foundation · SOC Enablement
**Platform:** Microsoft Sentinel (Azure)
**Standard Alignment:** ISO/IEC 27001:2022 · NIST CSF (Detect/Respond)
**Status:** Implemented and Stabilised

---

## Overview

The organisation required a centralized SIEM capability to unify monitoring across identity, cloud, endpoint, and network systems. While security telemetry already existed across multiple platforms, it was fragmented, inconsistently ingested, and difficult to operationalize for investigation or reporting.

This case study documents the process of standing up Microsoft Sentinel as a SIEM platform from the ground up, with a focus on the **practical challenges of initial deployment**, including:

* Log source onboarding complexity
* Connector inconsistencies and ingestion failures
* Data normalization issues
* Detection content immaturity
* Lack of standardized operational workflows

The work transitioned the organisation from fragmented monitoring to a structured SIEM foundation capable of supporting both SOC operations and governance reporting.

---

## Context & Motivation

The need for a SIEM platform was driven by several operational gaps:

* **Fragmented monitoring workflows**
  Analysts were required to pivot across multiple tools (endpoint, cloud, email, network) to investigate a single event.

* **No centralized visibility layer**
  There was no unified platform to:

  * Correlate events
  * Track incidents
  * Perform consistent investigations

* **Inconsistent reporting**
  Leadership reporting and operational insights lacked consistency due to siloed data.

* **Growing cloud footprint**
  With increased use of AWS and SaaS platforms, log volume and complexity outpaced manual monitoring approaches.

---

## Security Challenge

The primary challenge was not just deploying a SIEM, but making it **actually usable and reliable**.

Key difficulties included:

* **Getting logs into Sentinel reliably**

  * Connectors appearing configured but not ingesting
  * Delays in data flow
  * Misconfigured permissions or roles

* **Inconsistent ingestion patterns**

  * Each data source had different setup requirements
  * No standard onboarding process

* **Unusable raw data**

  * Logs arriving in formats that were difficult to query
  * Field inconsistencies across sources

* **Lack of detection maturity**

  * No baseline analytics
  * No structured hunting queries
  * No correlation logic

* **Operational uncertainty**

  * Analysts unsure what data could be trusted
  * No clear triage workflows

---

## Assessment and Planning

### Key Findings

* **Data source onboarding was the biggest blocker**

  * AWS (CloudTrail, GuardDuty, S3) required multi-step setup:

    * Trails
    * Buckets
    * IAM roles
    * Connector configuration

* **Connector reliability varied**

  * Some connectors were near plug-and-play
  * Others required troubleshooting across multiple layers

* **No ingestion validation model**

  * No consistent method to confirm:

    * Logs are flowing
    * Logs are complete
    * Logs are queryable

* **Detection and hunting content did not exist**

  * SIEM had data (in some cases), but no usable intelligence

---

### Design Priorities

* **Get ingestion stable before detection**
* **Focus on high-value log sources first**
* **Standardize onboarding and validation**
* **Build detection content iteratively**
* **Design for analyst usability, not just data collection**

---

## Implementation Strategy

### 1. Prioritize High-Value Log Sources

Initial onboarding focused on:

* Identity (Entra ID sign-in logs)
* Cloud (AWS CloudTrail, GuardDuty)
* Endpoint (CrowdStrike)
* Email (Proofpoint)

This ensured early visibility into high-risk activity.

---

### 2. Connector Deployment and Troubleshooting

Each integration required:

* Reviewing documentation
* Validating permissions and roles
* Testing ingestion manually

Common issues encountered:

* Incorrect IAM role trust relationships (AWS)
* Misconfigured S3 bucket permissions
* Logs not being written where expected
* Connector showing “connected” but no data present

This phase required **significant troubleshooting and iteration**.

---

### 3. Ingestion Validation Model

A structured validation approach was introduced:

* Confirm log presence in Sentinel tables

* Validate:

  * Event timestamps
  * Expected volume
  * Field completeness

* Compare:

  * Source system logs vs Sentinel ingestion

This helped identify **silent failures early**.

---

### 4. Data Normalization and Query Usability

Early ingestion revealed:

* Inconsistent field naming
* Difficulty writing reusable queries

Actions taken:

* Standardized key fields where possible:

  * User identifiers
  * IP addresses
  * Event types

* Built baseline KQL queries to:

  * Explore data
  * Understand structure
  * Identify gaps

---

### 5. Detection and Hunting Content Development

Detection capability was built progressively:

* Initial focus:

  * Basic anomaly detection
  * High-risk activity patterns

* Expanded into:

  * Cloud activity monitoring (AWS API usage)
  * Identity anomalies (sign-in behaviour)
  * Endpoint alerts correlation

* Hunting queries developed to:

  * Explore unknown patterns
  * Validate detection logic

---

### 6. Workbook and Dashboard Development

Developed workbooks for:

* **Operational monitoring**

  * Ingestion health
  * Log volume trends

* **SOC visibility**

  * Incident trends
  * Alert distribution

* **Management reporting**

  * High-level security posture
  * Risk trends

---

### 7. SOC Workflow Enablement

Established basic operational processes:

* Triage workflows for alerts
* Investigation steps using Sentinel data
* Feedback loop:

  * Analyst findings → detection improvements

---

## Security Controls Implemented

* Centralized SIEM ingestion (Sentinel)
* Log collection across:

  * Identity, cloud, endpoint, and email systems
* Detection analytics for common threat scenarios
* Threat hunting queries for proactive analysis
* Workbooks for operational and governance visibility
* Runbooks for ingestion validation and triage processes

---

## Operational Impact

### Improved Visibility

* Single platform for cross-domain monitoring
* Reduced need to pivot between tools

---

### Increased Investigation Consistency

* Analysts followed repeatable workflows
* Reduced time spent gathering context

---

### Detection Maturity Growth

* Detection logic improved over time
* Hunting informed analytics tuning

---

### Foundation for Future Scaling

* New integrations became easier after initial patterns were established
* SIEM became a core operational platform

---

## Lessons Learned

* **Getting data in is the hardest part**
  SIEM value depends entirely on ingestion reliability

* **“Connected” does not mean working**
  Connectors must always be validated with real data

* **Start simple with detection**
  Complex analytics are not useful without understanding baseline data

* **Data structure matters more than volume**
  Poorly structured logs reduce detection effectiveness

* **SOC workflows must be built alongside the platform**
  Technology alone does not improve operations

---

## Key Takeaways

Building a SIEM foundation is not just a deployment task, it is an iterative engineering and operational process.

Success depends on:

* Reliable ingestion
* Usable data structures
* Incremental detection development
* Continuous feedback from SOC workflows

A stable foundation enables long-term detection maturity and operational effectiveness.

---
