# Case Study: Drafting AI Governance, Risk & Compliance Policies

**Domain:** Security Governance & Compliance  
**Focus Areas:** AI Acceptable Use · Responsible AI · Risk Assessment · Vendor Governance · Data Classification  
**Standard Alignment:** ISO/IEC 42001:2023 · ISO/IEC 27001:2022  
**Status:** Completed

---

## Overview

As AI tools became increasingly embedded in everyday business operations — from productivity assistants and code generation to vendor-supplied machine learning pipelines — it became clear that the organisation's existing information security policies were not equipped to address the unique risks these technologies introduced.

This case study documents the process of researching, drafting, and operationalising a suite of AI Governance, Risk and Compliance (GRC) policies from the ground up, covering acceptable use, responsible AI principles, risk assessment, vendor governance, and data classification as it applies to AI systems.

The work was largely self-driven. There was no existing internal framework to inherit, no predecessor policies to update, and limited industry precedent to draw from at the time of drafting — making this one of the more open-ended and challenging governance exercises undertaken.

---

## Context & Motivation

The trigger for this work was a combination of factors converging at once:

- **Staff adoption of AI tools was outpacing policy.** Employees were using publicly available AI assistants — including large language models — for work tasks without any formal guidance on what was and wasn't appropriate. This created immediate data handling risks, particularly around what information was being submitted as prompts.
- **Vendors were embedding AI into existing products.** Tools the organisation already used were quietly introducing AI-powered features, sometimes with unclear data processing agreements. This created supply chain and third-party risk exposure that didn't fit neatly into existing vendor assessment processes.
- **Regulatory and standards landscape was shifting.** ISO/IEC 42001:2023 had been published, and it was becoming clear that AI governance would eventually be a formal audit consideration. Getting ahead of that was preferable to scrambling reactively.
- **There was no playbook.** Unlike drafting a password policy or an incident response procedure — where mature templates and frameworks abound — AI governance was genuinely emerging territory. Most available guidance was either too high-level to be actionable or too narrowly focused on specific tools or sectors.

---

## Challenges

### 1. No Established Internal or Industry Framework to Reference

The most significant challenge was the absence of a usable starting point. While ISO/IEC 42001 provided a structural foundation, it operates at a management system level — it defines *what* an AI management system should address, not *how* an organisation with limited AI maturity should practically implement controls.

Other publicly available frameworks at the time — including the NIST AI Risk Management Framework and the EU AI Act draft guidance — were either US-centric, not yet finalised, or required significant translation to be applicable to a smaller organisation without a dedicated AI function.

This meant that a significant portion of the early work was research and synthesis rather than drafting. Understanding what questions the policies even needed to answer required mapping out how AI was actually being used or could be used across the organisation — a process that itself surfaced risks that hadn't been formally identified.

The approach taken was to anchor the policy suite to existing information security principles (confidentiality, integrity, availability, and accountability) and extend them into the AI context, rather than treating AI governance as an entirely separate discipline. This made the policies more coherent with existing controls and easier for stakeholders to understand.

### 2. The AI Landscape Was Changing Faster Than Policy Could Keep Up

A recurring tension throughout the drafting process was the question of specificity versus durability. A policy that named specific tools or model providers would become outdated as the market evolved. A policy that was entirely technology-agnostic risked being too vague to provide meaningful guidance.

For example, when drafting the acceptable use policy, early drafts included references to specific categories of AI tools. By the time the policy went through review cycles, new categories of tools had emerged that didn't cleanly fit the original taxonomy.

The resolution was to adopt a principles-based drafting approach with defined categories rather than named tools, paired with a living reference document (maintained separately from the policy itself) that listed approved, conditionally approved, and prohibited tool categories. This allowed the policy to remain stable while the reference document could be updated more frequently without triggering a full policy review cycle.

Version control and review cadence also became important. The policy suite was designed with a six-month initial review cycle — shorter than the organisation's standard annual cycle — to allow for rapid iteration as the landscape evolved.

### 3. Balancing Security Controls Against Business Productivity

This was arguably the most politically sensitive challenge. AI tools were delivering genuine productivity benefits, and blanket restrictions would have generated significant pushback — and likely just driven usage underground rather than eliminating it.

The challenge was designing controls that were meaningful from a risk perspective without being so restrictive that they became unworkable in practice. This required engaging with business stakeholders early in the drafting process to understand how AI tools were actually being used and what value they were delivering.

Several specific tensions emerged:

- **Data sensitivity vs. tool functionality.** Many AI tools deliver the most value when given rich context — which is exactly the kind of context that creates data handling risk. The policy needed to define clear data classification thresholds for what could and couldn't be submitted to AI systems, without making those thresholds so conservative that they rendered the tools useless.
- **Productivity tooling vs. shadow IT.** Staff were using AI tools that IT had not approved and in some cases was not aware of. Simply prohibiting unapproved tools was unlikely to be effective. The policy instead established a lightweight approval pathway — a defined process by which staff or teams could request assessment and conditional approval of new tools — which channelled the demand constructively.
- **Speed of AI feature rollout vs. vendor assessment timelines.** Vendors were pushing AI features into existing products faster than standard vendor reassessment processes could handle. A specific addendum to the vendor governance policy was required to address mid-contract AI feature additions and establish the organisation's right to opt out of or disable AI features pending assessment.

---

## What Was Developed

### AI Acceptable Use Policy

Defined the conditions under which staff may use AI tools for work-related purposes. Key components included:

- A taxonomy of AI tool categories (generative AI, decision-support AI, automated processing tools) with corresponding use conditions
- Explicit prohibitions — including submitting personal information, commercially sensitive data, or client data to non-approved AI systems
- Guidance on prompt hygiene and the risk of inadvertent data disclosure through conversational context
- Acknowledgement requirements, ensuring staff confirmed they understood the policy prior to using approved tools
- A process for requesting approval of new tools, including minimum information requirements for assessment

### Responsible AI Use Policy

Where the acceptable use policy addressed *what* was permitted, the responsible AI policy addressed *how* AI should be used responsibly — covering areas that are harder to enforce technically but important to establish as organisational norms:

- Transparency requirements — staff were expected to disclose when AI had been used to produce work product in contexts where this was material
- Human oversight obligations — AI outputs in certain categories (security assessments, legal or compliance documents, communications to external parties) required human review before being acted upon or distributed
- Prohibition on using AI to make consequential decisions without human review, particularly in areas touching on people management, access control changes, or financial approvals
- Guidance on AI-generated content and the risk of hallucinations being treated as factual

### AI Risk Assessment Framework

Established a structured approach to assessing AI-related risks, both for tools being considered for adoption and for AI features embedded in existing systems. The framework drew on the organisation's existing risk management methodology but extended it with AI-specific risk categories:

- **Data risk** — what data is ingested, stored, or used for training; where it goes; and whether it can be retrieved or disclosed
- **Output risk** — the consequences of incorrect, biased, or hallucinated outputs in the context of how the tool is being used
- **Dependency risk** — reliance on AI systems for functions that would create operational impact if the AI became unavailable or degraded
- **Transparency risk** — whether the AI system's decision-making process is explainable and auditable to the degree required
- **Regulatory risk** — alignment with applicable privacy legislation (particularly the Australian Privacy Act and the Privacy Amendment (Notifiable Data Breaches) Act), sector-specific obligations, and emerging AI regulation

Each risk category was mapped to a rating scale and combined into an overall AI Risk Rating, which determined the level of governance controls required.

### Vendor AI Governance Policy

This was one of the more complex areas to address, because vendor AI risk doesn't follow a simple approval/rejection model. A vendor tool might be approved for general use but have AI features that are not approved, or the AI features might be acceptable for some data classifications but not others.

The policy established:

- A requirement for vendors to disclose AI capabilities — including planned future AI features — as part of the procurement and renewal process
- A defined set of contractual requirements for vendors whose tools involve AI processing of organisational data, including data retention limitations, prohibition on using organisational data for model training without explicit consent, and breach notification obligations specific to AI-related incidents
- An assessment process for AI features added to existing vendor products mid-contract, including a defined timeframe for the vendor to provide required information and the organisation's remediation options if requirements weren't met
- Classification of vendors into AI risk tiers based on the nature of their AI use, with tier-appropriate oversight requirements

### Data Classification for AI Contexts

Existing data classification policy used a standard tiered model. The challenge was that these classifications didn't cleanly translate to AI contexts — a document might be classified at one level, but the act of submitting it as a prompt to an external AI system created a different and potentially higher-risk exposure.

The work involved extending the classification framework with AI-specific handling guidance:

- Each classification tier was annotated with explicit AI handling rules — whether data at that classification could be submitted to cloud-based AI tools, on-premise AI tools only, or not to AI systems at all
- A concept of **prompt sensitivity** was introduced — recognising that even if individual data elements were low-classification, a prompt that combined multiple elements (role, project, counterparty, context) could collectively constitute a higher-classification disclosure
- Guidance was developed for handling AI-generated outputs — particularly around how to classify AI outputs that were derived from or contained elements of sensitive inputs

---

## Outcomes & Observations

The policy suite provided the organisation with a defensible governance position on AI use for the first time — moving from an environment where AI use was effectively uncontrolled to one with defined boundaries, oversight mechanisms, and accountability.

Practically, the most immediate impact was on the vendor management process. The vendor AI governance policy resulted in several vendors being asked to provide additional information about their AI implementations, and in at least one case led to the organisation opting out of an AI feature that didn't meet data handling requirements.

The acceptable use policy, once communicated, also surfaced the extent of existing AI tool usage that had been taking place outside IT visibility — which provided useful data for the risk assessment process.

**Key observations for others undertaking similar work:**

- **Start with use cases, not theory.** The most useful input to the drafting process was understanding how AI was actually being used, not how it theoretically might be used. Informal conversations with staff across different functions surfaced use cases that wouldn't have been anticipated from a purely top-down approach.
- **Anchor to existing frameworks where possible.** Treating AI governance as an extension of existing information security and privacy obligations — rather than a separate discipline — produced more coherent and more readily accepted policies.
- **Build in flexibility by design.** The split between stable policy documents and more frequently updated reference documents (approved tool lists, vendor AI tiers) was one of the more practically useful structural decisions. It allowed the governance framework to evolve without requiring formal policy review every time a tool or vendor changed.
- **Expect the landscape to keep moving.** Even at the point of finalisation, the policies were already under pressure from new developments. Governance in this space is not a project with an end date — it requires ongoing attention and a willingness to revisit assumptions.

---

## Standards & Frameworks Referenced

| Reference | Relevance |
|-----------|-----------|
| [ISO/IEC 42001:2023](https://www.iso.org/standard/42001) | AI management system requirements — structural foundation for the governance framework |
| [ISO/IEC 27001:2022](https://www.iso.org/standard/27001) | Information security management — basis for extending existing controls to AI contexts |
| [NIST AI Risk Management Framework](https://www.nist.gov/system/files/documents/2023/01/26/AI%20RMF%201.0.pdf) | Risk categorisation reference |
| Australian Privacy Act 1988 | Data handling obligations for AI inputs and outputs involving personal information |
| Privacy Amendment (Notifiable Data Breaches) Act 2017 | Breach notification obligations in AI incident scenarios |

---

*This case study documents practical implementation experience. Organisational identifiers, client data, commercially sensitive information, and specific vendor names have been omitted.*
