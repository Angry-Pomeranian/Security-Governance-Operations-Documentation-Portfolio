# Browser Extension Control – Windows 11

## Overview

**Platform:** Windows
**Profile Type:** Administrative Templates + Custom OMA-URI

**Description:**
This policy standardizes **browser extension management** across **Google Chrome**, **Microsoft Edge**, and **Mozilla Firefox** on **Windows 11** devices.
It ensures only **approved security and productivity extensions** are automatically installed for Chrome and Edge, while also **ingesting the Firefox ADMX template** to enable Windows Single Sign-On (SSO) for managed enterprise logins.

The purpose of this configuration is to maintain **cross-browser consistency**, strengthen **endpoint security**, and ensure all browsers align with *company*’s compliance and identity management standards.
The policy is currently deployed to **production and kiosk pilot groups** to validate performance, user impact, and policy enforcement prior to full organization-wide rollout.

---

## Assignments

### Included Groups

| Group      | Status | Filter | Filter Mode |
| ---------- | ------ | ------ | ----------- |
| Test Group | Active | None   | None        |

### Excluded Groups

| Group        | Status |
| ------------ | ------ |
| *No results* |        |

### Scope Tags

| Selected Tags |
| ------------- |
| Default       |


---

| **Notes** | Extensions included: uBlock Origin Lite, Privacy Badger, Osprey, Malwarebytes Browser Guard, DuckDuckGo Tracker Protection, Bitwarden Password Manager.<br>*(Add FoxyProxy and AdBlock once verified.)* |

#### Additional Chrome Force-Installed Extensions  
| Setting | Value |
|----------|--------|
| Extension/App IDs and update URLs to be silently installed (Device) | `<ExtensionID>;<UpdateURL>` pairs for all approved extensions (example: `ddkjiahejlhfcafbddmgiahcphecmpfh;https://clients2.google.com/service/update2/crx`) |
| Configure the list of force-installed apps and extensions | Enabled |

---

### Microsoft Edge  
**Path:** Microsoft Edge → Extensions  

| Setting | Value |
|----------|--------|
| Configure extension management settings (Device) | Enabled |
| **Configuration JSON** | Same as Chrome JSON above |
| Force-installed extensions | uBlock Origin Lite, Privacy Badger, Osprey, Malwarebytes, DuckDuckGo, Bitwarden (plus FoxyProxy / AdBlock once verified) |

---

### Custom OMA-URI Settings  
| Name | Description | OMA-URI | Data Type | Value |
|------|-------------|----------|-----------|--------|
| Ingest Firefox ADMX | Ingests the Firefox ADMX template | `./Device/Vendor/MSFT/Policy/ConfigOperations/ADMXInstall/Firefox/Policy/Firefox` | String | *(Paste the full Firefox ADMX XML content here)* |
| Windows SSO (Firefox) | Enables Windows SSO for Microsoft/work/school accounts in Firefox | `./Device/Vendor/MSFT/Policy/Config/Firefox~Policy~firefox/WindowsSSO` | String | `<enabled/>` |

---

### Applicability Rules  
| Rule | Property | Value | Details |
|------|-----------|--------|----------|
| – | – | – | Applies to Windows 11 devices targeted by the assigned groups. |

---

## Notes  
This configuration guarantees **consistent browser extension enforcement** across Chrome, Edge, and Firefox in *company*’s managed environment.  

**Objectives:**  
- Auto-install and lock approved security/privacy extensions.  
- Enforce identical configurations in Edge and Chrome.  
- Enable Firefox Windows SSO for Microsoft/Entra ID accounts.  

**Approved Chrome IDs:**  
| Extension | ID |
|------------|----|
| uBlock Origin Lite | `ddkjiahejlhfcafbddmgiahcphecmpfh` |
| Privacy Badger | `pkehgijcmpdhfbdbbnkijodmdjhbjlgp` |
| Osprey: Browser Protection | `jmnpibhfpmpfjhhkmpadlbgjnbhpjgnd` |
| Malwarebytes Browser Guard | `ihcjicgdanjaechkgeegckofjjedodee` |
| DuckDuckGo Search & Tracker Protection | `bkdgflcldnnnapblkhphbgpggdiikppg` |
| Bitwarden Password Manager | `nngceckbapebfimnlniiiahkandclblb` |
| FoxyProxy | *(To be verified)* |
| AdBlock – block ads across the web | *(To be verified)* |

---

### Feedback Loop  
1. **Assumptions:**  
   - All listed extensions are sourced from the Chrome Web Store.  
   - `https://clients2.google.com/service/update2/crx` is valid for all update URLs.  
   - Firefox ADMX ingestion and `<enabled/>` value apply cleanly on Windows 11 Intune devices.  

2. **Potential Pitfalls:**  
   - Verify unlisted extension IDs (FoxyProxy, AdBlock).  
   - Duplicate extension enforcement across Chrome and Edge may cause policy conflicts if another profile controls extensions.  
   - Firefox ADMX requires a reboot to fully ingest.  

3. **Verification Steps:**  
   - **Chrome:** Visit `chrome://policy` → Confirm `ExtensionInstallForcelist` entries.  
   - **Edge:** Visit `edge://policy` → Confirm same entries.  
   - **Firefox:** Visit `about:policies` → Confirm WindowsSSO = true and ADMX applied.  
   - Intune Portal → Devices → Configuration Profiles → **Browser Extension Control – Windows 11** → Check **Device Status** and **Per-setting status**.  

---
