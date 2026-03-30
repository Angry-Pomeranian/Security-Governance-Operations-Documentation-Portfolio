# CIS Windows Benchmarks

## Overview

This folder contains CIS benchmark PDFs for Windows Server (2012 R2 through 2025) and Windows 10/11 via Microsoft Intune. These benchmarks provide the hardening baseline for Windows endpoints and servers in enterprise environments, covering local security policies, account policies, auditing, Windows Firewall, service configuration, and registry settings.

The Intune-specific benchmarks (`CIS_Microsoft_Intune_for_Windows_10` and `11`) map CIS controls to MEM configuration profiles for cloud-managed device fleets.

---

## Benchmarks Available

| Benchmark | Version | Status |
|---|---|---|
| CIS Microsoft Windows Server 2025 | v2.0.0 | Current |
| CIS Microsoft Windows Server 2022 | v5.0.0 | Current |
| CIS Microsoft Windows Server 2019 Stand-alone | v3.0.0 | Current |
| CIS Microsoft Windows Server 2016 | v4.0.0 | Current |
| CIS Microsoft Windows Server 2012 R2 | v3.0.0 | Archived |
| CIS Microsoft Intune for Windows 11 | v4.0.0 | Current |
| CIS Microsoft Intune for Windows 10 | v4.0.0 | Current |

---

## Hardening Scope

| Category | Controls |
|---|---|
| Account Policies | Password complexity, history, minimum age, lockout threshold and duration |
| Local Policies | User rights assignment, security options, UAC configuration |
| Auditing | Object access, logon events, privilege use, policy changes, account management |
| Windows Firewall | Domain/Private/Public profile rules; default inbound block |
| Services | Disable unused services (e.g. Remote Registry, Print Spooler on non-print servers) |
| Registry | Secure registry permissions; disable legacy protocols (NTLM, LM, SMBv1) |
| Network | Restrict anonymous enumeration, disable NetBIOS over TCP/IP where possible |

---

## Intune Deployment

The Intune benchmarks (`Windows 10` and `Windows 11`) translate CIS controls into Intune configuration profile settings using the Settings Catalog and Endpoint Security policies. These profiles are deployed via MEM and complement Conditional Access policies for device compliance.

See [`../../conditional-access/`](../../conditional-access/) for deployed Intune configuration profiles that reference these baselines.

---

## Related

- [CIS Benchmark Converter Script](../../scripts/README.md) — Python utility for extracting and converting CIS benchmark PDFs to Excel/CSV/JSON for gap analysis and reporting.
- [Conditional Access Policies](../../conditional-access/) — Intune profiles deploying CIS-aligned baselines.
- [RHEL Benchmarks](../rhel/) — Linux OS hardening benchmarks.
- [Endpoint Hardening Overview](../../../README.md)
