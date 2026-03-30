# CIS Google Chrome Benchmark

## Overview

This folder contains the CIS Google Chrome Benchmark v3.0.0 and extracted implementation notes for enterprise Chrome deployments. The benchmark defines Level 1 and Level 2 hardening controls covering browser configuration, extension policy, privacy settings, and update management.

Chrome is the most widely deployed enterprise browser in the Microsoft 365 ecosystem and requires deliberate hardening to close exposure around credential theft via extensions, man-in-the-browser attacks, and unsafe browsing behaviour.

---

## Contents

| File | Description |
|---|---|
| `CIS_Google_Chrome_Benchmark_v3.0.0.pdf` | Full CIS benchmark reference — all controls, rationale, and audit procedures |
| `benchmark-controls.md` | Extracted control implementation notes for enterprise deployment |

---

## CIS Levels

| Level | Description | Use Case |
|---|---|---|
| Level 1 | Foundational hygiene controls with minimal operational disruption | Default baseline for all managed endpoints |
| Level 2 | Strict configuration; some controls may affect usability or require user adjustment | High-assurance or regulated environments |

---

## Deployment Context

These benchmark controls are deployed via Microsoft Intune (MEM) using Chrome ADMX administrative templates. The Intune configuration profile for CIS Chrome Level 1 and Level 2 is documented in:

- [`../../conditional-access/mem-win10-chrome-cis/README.md`](../../conditional-access/mem-win10-chrome-cis/README.md) — Full Intune policy deployment, group assignments, and compliance settings.

---

## Key Hardening Areas

- **Safe Browsing** — enforce enhanced protection mode; disable user override of warnings
- **Password Manager** — disable built-in Chrome password manager (defer to enterprise PAM)
- **Extensions** — block unapproved extension installation via allowlist; see `../extensions/` for AppLocker approach
- **Automatic Updates** — enforce via Google Update policy; prevent end-user deferral
- **Data Collection** — disable crash reporting, metrics, and sync to personal Google accounts
- **Incognito Mode** — disable or restrict for managed devices

---

## Related

- [Intune CIS Chrome Deployment](../../conditional-access/mem-win10-chrome-cis/README.md)
- [Browser Extension Control](../extensions/README.md)
- [Edge Benchmark](../edge/README.md)
- [Firefox Benchmark](../firefox/README.md)
- [Endpoint Hardening Overview](../../../README.md)
