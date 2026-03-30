# Browser Extension Control

## Overview

This folder covers browser extension governance — policies and controls that determine which extensions can be installed and executed on managed endpoints. Uncontrolled browser extensions are a significant enterprise risk: they can inject content into web pages, harvest credentials, exfiltrate data, and establish C2 channels through the browser process.

Extension control complements CIS browser benchmarks by addressing the runtime application surface that benchmark policies alone cannot fully restrict.

---

## Contents

| File | Description |
|---|---|
| `applocker-using-intune.md` | AppLocker policy configuration via Microsoft Intune to restrict application and extension execution on Windows endpoints |

---

## Approach

Extension governance in this portfolio is implemented through two complementary layers:

**1. Browser policy (per-browser allowlists)**
Each browser supports an `ExtensionInstallAllowlist` / `ExtensionInstallBlocklist` policy, enforced via Intune ADMX templates:
- Chrome: `ExtensionInstallAllowlist` + `ExtensionInstallBlocklist = *`
- Edge: `ExtensionInstallAllowlist` + `ExtensionInstallBlocklist = *`
- Firefox: `Extensions.Install` allowlist via `policies.json`

**2. AppLocker via Intune**
AppLocker enforces application control rules at the OS level using publisher rules, path rules, and hash rules. When deployed via Intune configuration profiles, AppLocker provides a fallback enforcement layer that operates independently of browser policy settings.

---

## Security Relevance

| Threat | How Uncontrolled Extensions Enable It |
|---|---|
| Credential harvesting | Extensions with DOM access can capture form inputs including passwords |
| Phishing page injection | Malicious extensions inject fake login forms into legitimate pages |
| Data exfiltration | Extensions can read page content and POST it to external servers |
| C2 via browser | Extensions communicate with attacker infrastructure using allowed HTTPS channels |
| Session token theft | Extensions with `cookies` permission can steal authenticated session tokens |

Extension control is an ASD Essential Eight **Application Control** (Maturity Level 1–3) requirement, and contributes to NIST SP 800-53 CM-7 (Least Functionality).

---

## Related

- [Chrome Benchmark](../chrome/README.md)
- [Edge Benchmark](../edge/README.md)
- [Firefox Benchmark](../firefox/README.md)
- [Browser Extensions Conditional Access Policy](../../conditional-access/browser-extensions/README.md)
- [Endpoint Hardening Overview](../../../README.md)
