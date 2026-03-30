# Automation Runbooks

## Overview

Runbooks in this section document step-by-step operational procedures for infrastructure deployment and configuration tasks. They are written to a handoff-ready standard — including prerequisites, variables, and sequential steps — so that any engineer can execute the procedure consistently without prior context.

Runbooks support repeatable delivery and reduce configuration drift in DevSecOps-adjacent workflows.

---

## Runbooks

| Runbook | Description | Platform |
|---|---|---|
| [windows-on-openshift-runbook.md](windows-on-openshift-runbook.md) | Windows Server 2022 VM deployment via OpenShift Virtualization using CDI upload, virtctl, and StorageClass configuration | OpenShift / CNV |

---

## Related

- [Automation Overview](../README.md) — Parent section covering automation structure, CrowdStrike API modules, and scripts.
- [Scripts](../scripts/README.md) — Python utilities for Sentinel alert enrichment and platform integration.
- [CrowdStrike API Modules](../crowdstrike/README.md) — PowerShell modules for CrowdStrike Falcon API operations.
