# Proofpoint AI Governance Flow

## Overview

This diagram maps the end-to-end AI governance architecture using the Proofpoint Information and Cloud Security (ICS) platform. It covers the full lifecycle: discovering shadow AI tools via CASB, detecting sensitive data submissions via the Data Security Workbench, restricting access via the Isolation Console, adapting controls using TAP risk data, and auto-remediating via TRAP.

This reflects the nine-guide suite documented in [`reference/email-security/guides/proofpoint/ai-governance/`](../reference/email-security/guides/proofpoint/ai-governance/).

---

## Architecture Diagram

```mermaid
flowchart TD
    subgraph Discovery["Visibility & Discovery"]
        CASB[Proofpoint CASB\nApp Discovery]
        OAuth[OAuth Audit\nToken Inventory]
        AppTiers[App Tier Classification\nApproved · Tolerated · Review · Block]
        CASB --> OAuth
        CASB --> AppTiers
    end

    subgraph AITools["AI Tool Landscape"]
        Approved[Approved Tools\nCopilot for M365\nGitHub Copilot Enterprise]
        Tolerated[Tolerated Tools\nChatGPT · Claude · Perplexity]
        Blocked[Blocked Tools\nDNS / CASB block applied]
    end

    AppTiers --> Approved
    AppTiers --> Tolerated
    AppTiers --> Blocked

    subgraph Detection["Detection & Prevention"]
        Agent[Endpoint Agent\nBrowser Extension]
        Trigger[GenAI Prompt Submit\nTrigger]
        Classifiers[Data Classifiers\nPII · Credentials · Source Code · IP]
        DLPRule[DLP Rules\nAlert · Block · Redact]
        Agent --> Trigger
        Trigger --> Classifiers
        Classifiers --> DLPRule
    end

    subgraph Isolation["Isolation Console"]
        Tier2[Tier 2 — Restricted\nUpload + Clipboard blocked]
        Tier3[Tier 3 — Read-Only\nFull isolation for high-risk users]
    end

    subgraph Investigation["Investigation & Response"]
        Workbench[Data Security Workbench\nAlert Queue]
        Timeline[User Activity Timeline\nFile open → paste → submit chain]
        CASBCorr[CASB Correlation\nOAuth token check]
        IsoLog[Isolation Session Logs]
        Verdict[Verdict\nFP · Accidental · Intentional · Critical]
        TRAP[TRAP Auto-Pull\nRemove from all inboxes]
        Workbench --> Timeline
        Timeline --> CASBCorr
        Timeline --> IsoLog
        CASBCorr --> Verdict
        IsoLog --> Verdict
        Verdict --> TRAP
    end

    subgraph Adaptive["Adaptive Controls"]
        TAP[TAP — VAP List\nUser Risk Score]
        RiskGroup[High-Risk User Group\ngenai-high-risk-users]
        StepUp[Isolation Step-Up\nAuto-assign Tier 3]
        TAP --> RiskGroup
        DLPRule --> RiskGroup
        RiskGroup --> StepUp
        StepUp --> Tier3
    end

    Tolerated --> Agent
    Approved --> Agent
    DLPRule --> Workbench
    Workbench --> RiskGroup

    Tolerated --> Tier2
    Approved --> Tier2

    TAP --> Tier3
```

---

## Related Documentation

- [`reference/email-security/guides/proofpoint/ai-governance/README.md`](../reference/email-security/guides/proofpoint/ai-governance/README.md) — Suite overview and implementation sequence
- [`visibility/shadow-ai-discovery-casb.md`](../reference/email-security/guides/proofpoint/ai-governance/visibility/shadow-ai-discovery-casb.md) — CASB discovery and OAuth audit
- [`detection/detecting-sensitive-data-in-ai-prompts.md`](../reference/email-security/guides/proofpoint/ai-governance/detection/detecting-sensitive-data-in-ai-prompts.md) — Agent, trigger, and classifier setup
- [`detection/controlling-ai-site-access-via-isolation.md`](../reference/email-security/guides/proofpoint/ai-governance/detection/controlling-ai-site-access-via-isolation.md) — Isolation tier configuration
- [`governance/adaptive-ai-access-controls.md`](../reference/email-security/guides/proofpoint/ai-governance/governance/adaptive-ai-access-controls.md) — TAP VAP → Isolation step-up
