# Case Study: Endpoint and Browser Hardening Using CIS Benchmarks & Extension Governance

**Domain:** Endpoint Security & Configuration Management
**Focus Areas:** Browser Hardening · CIS Benchmark Implementation · Extension Governance · Data Exfiltration Control
**Standard Alignment:** ISO/IEC 27001:2022 · CIS Critical Security Controls · CIS Benchmarks (Chrome & Edge)
**Status:** Implemented and Operationalised

---

## Overview

Modern enterprise environments rely heavily on web browsers as the primary interface for SaaS platforms, administrative portals, and internal tools. This creates a significant attack surface at the endpoint level, where misconfigurations, unmanaged extensions, and inconsistent browser behaviour introduce real risks — data exfiltration, session hijacking, and malware delivery being the most common.

This case study documents how I implemented a structured browser hardening program across managed endpoints, using CIS benchmarks for Google Chrome and Microsoft Edge as a baseline, alongside a governance model for browser extension control.

The focus was not just on technical enforcement via Microsoft Intune and enterprise policies, but on making browser behaviour actually align with broader security controls: data classification, Conditional Access, and acceptable use. Getting those to work together required more thought than the technical configuration itself.

---

## Context & Motivation

The need for browser hardening came from a few things converging at once.

Browsers had effectively become the new endpoint perimeter. With the majority of business applications accessed via browser, traditional endpoint controls alone weren't cutting it. At the same time, users were installing extensions without any visibility or approval process, which was introducing risks around data scraping, credential harvesting, and unvetted third-party code running inside the browser context.

On top of that, browser configurations across devices were all over the place. Without enforced baselines, settings varied enough that there were real gaps in secure transport enforcement, content handling, and script execution. From an ISO 27001 standpoint, controls around secure configuration (Annex A 8.9), web filtering (8.23), and access control required stronger enforcement at the browser layer than we had.

---

## Challenges

### 1. Translating CIS Benchmarks into Enforceable Policies

CIS benchmarks are detailed and well-structured, but they are not deployment-ready out of the box. The challenge was mapping those recommendations into enforceable settings via Intune and enterprise browser policies, which meant working across the Intune Settings Catalog, ADMX-backed Administrative Templates, and registry-based configurations depending on the control.

Not every CIS recommendation made sense to enforce as-is. Some were overly restrictive for environments where specific SaaS workflows depend on browser behaviour that a strict CIS implementation would block. The approach I took was categorising controls into three buckets: enforce unconditionally, enforce conditionally pending business validation, and not applicable because it breaks required functionality. The goal was a baseline that was secure-by-default without breaking core workflows.

### 2. Extension Management Without Breaking Productivity

Extensions were the highest-risk vector and also the thing people were most resistant to locking down. Password managers, sales tooling, dev utilities — there were legitimate use cases that had to be accommodated, which meant a blanket block wasn't realistic.

Chrome and Edge behave differently here too. Chrome allows forced installs and allowlisting by extension ID, but Incognito behaviour requires the user to manually enable extensions, which caused issues. Edge has tighter Microsoft ecosystem integration but still has extension dependencies.

The solution was a controlled allowlist model: block all extensions by default, allow only approved ones via enterprise policy using extension IDs, and introduce a formal review process for new extension requests that covered security review, privacy assessment, and business justification. This brought extension governance in line with existing vendor risk processes rather than treating it as a separate thing.

### 3. Interaction with Conditional Access and Device Compliance

Browser behaviour had a direct impact on Conditional Access outcomes, which was not immediately obvious until we started seeing authentication failures. The main issues were unmanaged browsers bypassing controls, Incognito/InPrivate contexts breaking extension-dependent authentication flows, and SSO extensions not being active when needed.

The mitigation was enforcing a managed browser requirement (Edge preferred, Chrome with enterprise policies enforced), configuring required extensions including SSO and security tooling, and providing user guidance that actually explained why Incognito might fail rather than just expecting users to figure it out.

### 4. Balancing Security Controls with Real-World Usage

Aggressive hardening breaks things, and broken things get bypassed. The clipboard restriction controls were a good example: they prevent data leakage, but they also impacted on-call workflows where people needed to paste things quickly under pressure. URL handling policies that restricted link opening to managed browsers had to be aligned with mobile and BYOD policies too.

The approach was staged rollout: pilot group, feedback loop, gradual enforcement. Controls that generated legitimate friction went back to the drawing board. Exceptions were permitted where justified, but documented and tracked rather than just quietly allowed.

---

## What Was Implemented

### CIS-Based Browser Hardening Baseline

For both Chrome and Edge, the baseline covered enforcing secure transport where applicable, disabling high-risk features, controlling download behaviour, popups, redirects, and JavaScript execution where relevant. Deployment was via Intune configuration profiles and Administrative Templates.

### Extension Governance Model

A default-deny posture with an approved extension allowlist. Security-critical extensions and SSO integrations were force-installed via enterprise policy. Review criteria included data access permissions, vendor reputation, privacy policy analysis, and business necessity.

### Integration with Endpoint and Identity Controls

Browser hardening was integrated with Intune compliance policies (only compliant devices allowed access), Conditional Access (enforced managed device and browser requirements), and data protection controls including App Protection Policies for mobile contexts.

### User Communication

Clear communication about what changed and why made a material difference to adoption. Users who understood the reasoning behind restrictions were significantly less likely to try to work around them. Guidance covered extension requests, browser usage expectations, and troubleshooting common issues like Incognito authentication failures.

---

## Outcomes

Reduced risk of malicious extensions, data exfiltration via browser, and inconsistent endpoint configurations. Increased visibility into extension usage and browser-based risk exposure. Conditional Access reliability improved because browser posture was now consistent and predictable.

From an ISO 27001 perspective, the work directly supported secure configuration management, access control enforcement, web usage governance, and data protection mechanisms.

**Key observations:**

Browsers are a control plane, not just an application. In SaaS-heavy environments, treating browser security as a first-class concern is not optional. Extensions are a major blind spot without governance, and governance without enforcement is just a document. User experience matters: controls that disrupt real workflows will be bypassed one way or another, so designing for usability is not a concession, it is a security requirement.

---

*Organisational identifiers, client data, and commercially sensitive information have been omitted.*
