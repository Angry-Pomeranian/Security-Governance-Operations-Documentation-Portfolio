# CIS Mozilla Firefox ESR Benchmark

## Overview

This folder contains the CIS Mozilla Firefox 102 ESR Benchmark v1.0.0 (archived) and extracted implementation notes. The benchmark defines hardening controls for Firefox in enterprise environments using Extended Support Release (ESR) builds, which are the standard Firefox variant for managed endpoints due to their longer support lifecycle.

Firefox is commonly deployed alongside Chrome/Edge in mixed-browser environments or as the default browser in Linux-based workstations. The ESR track receives security patches without feature updates, making it more suitable for policy-controlled enterprise deployments.

---

## Contents

| File | Description |
|---|---|
| `CIS_Mozilla_Firefox_102_ESR_Benchmark_v1.0.0.ARCHIVE.pdf` | CIS Firefox 102 ESR benchmark — all controls, rationale, and audit procedures (archived) |
| `benchmark-controls.md` | Extracted control implementation notes for enterprise deployment |

---

## Archive Note

Firefox 102 ESR reached end of life in September 2023. This benchmark is retained for:
- Reference and audit trail for environments that were hardened against this version
- Controls that remain applicable to current Firefox ESR releases (many controls are version-agnostic)

**For new deployments:** Target the current Firefox ESR release. The CIS benchmark for the current ESR version should be obtained from the CIS website. Core hardening principles — disabling telemetry, enforcing update policy, restricting extension installation, and managing about:config settings — remain consistent across ESR versions.

---

## Deployment Context

Firefox policy is enforced via one of two mechanisms:

- **Windows Group Policy / Intune ADMX** — Firefox provides an ADMX template (`firefox.admx`) that can be imported into Group Policy or Intune for centrally managed policy settings.
- **`policies.json`** — A JSON configuration file placed in the Firefox installation directory (`distribution/policies.json`) that is loaded at startup and enforces policy without requiring Group Policy.

Key policies to configure:
- `DisableTelemetry` — prevent usage data collection
- `DisableFirefoxAccounts` — block sync to personal Mozilla accounts
- `ExtensionSettings` — control extension installation via allowlist/blocklist
- `DisablePrivateBrowsing` — restrict inPrivate mode on managed endpoints
- `OverrideFirstRunPage` / `OverridePostUpdatePage` — suppress onboarding pages

---

## Related

- [Chrome Benchmark](../chrome/README.md)
- [Edge Benchmark](../edge/README.md)
- [Browser Extension Control](../extensions/README.md)
- [Endpoint Hardening Overview](../../../README.md)
