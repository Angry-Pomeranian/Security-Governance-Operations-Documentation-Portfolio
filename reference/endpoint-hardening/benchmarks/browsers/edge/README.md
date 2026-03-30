# CIS Microsoft Edge Benchmark

## Overview

This folder contains two CIS benchmarks for Microsoft Edge in enterprise environments:

- **CIS Microsoft Edge Benchmark v4.0.0** — General policy hardening for Edge across all deployment models.
- **CIS Microsoft Intune for Edge Benchmark v1.0.0** — MEM-specific control mappings for organisations deploying Edge policy via Intune configuration profiles.

Edge is Microsoft's default browser and is tightly integrated with Entra ID and Microsoft 365. Hardening Edge reduces credential exposure, restricts unsanctioned data flows, and enforces security defaults aligned with the broader Microsoft security stack.

---

## Contents

| File | Description |
|---|---|
| `CIS_Microsoft_Edge_Benchmark_v4.0.0.pdf` | Full CIS Edge benchmark — all controls, rationale, and audit procedures |
| `CIS_Microsoft_Intune_for_Edge_Benchmark_v1.0.0.pdf` | Intune-specific control guidance for MEM-managed Edge deployments |
| `benchmark-controls.md` | Extracted control implementation notes for enterprise deployment |

---

## CIS Levels

| Level | Description | Use Case |
|---|---|---|
| Level 1 | Foundational hygiene controls with minimal operational disruption | Default baseline for all managed endpoints |
| Level 2 | Strict configuration; some controls may affect usability or require user adjustment | High-assurance or regulated environments |

---

## Deployment Context

These benchmark controls are deployed via Microsoft Intune (MEM) using Edge ADMX administrative templates. The Intune configuration profile for CIS Edge Level 1 and Level 2 is documented in:

- [`../../conditional-access/mem-win10-edge-cis/README.md`](../../conditional-access/mem-win10-edge-cis/README.md) — Full Intune policy deployment, group assignments, and compliance settings.

---

## Key Hardening Areas

- **SmartScreen** — enforce Microsoft Defender SmartScreen for phishing/malware URL blocking
- **Password Manager** — disable Edge built-in password manager; enforce enterprise credential store
- **Extensions** — restrict to allowlisted extensions via ExtensionInstallAllowlist policy
- **Sync** — disable sync to personal Microsoft accounts; enforce enterprise profile isolation
- **InPrivate Mode** — disable or restrict for managed devices
- **Autofill** — disable form autofill and payment method saving
- **Data Collection** — disable diagnostic data, feedback, and usage telemetry

---

## Related

- [Intune CIS Edge Deployment](../../conditional-access/mem-win10-edge-cis/README.md)
- [Browser Extension Control](../extensions/README.md)
- [Chrome Benchmark](../chrome/README.md)
- [Firefox Benchmark](../firefox/README.md)
- [Endpoint Hardening Overview](../../../README.md)
