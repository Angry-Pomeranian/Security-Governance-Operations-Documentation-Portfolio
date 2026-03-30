# Edge CIS L1 and L2 Template Policy

## Overview

**Platform:** Windows
**Profile Type:** Device configuration profile (Microsoft Edge settings)

**Description:**
This policy applies CIS Benchmark Level 1 and Level 2 security baselines for Microsoft Edge on Windows 10 and later devices. 
It enforces hardened controls across browser sign in, data synchronization, extension governance, password management, privacy telemetry, and web platform security.

Password saving, import, and synchronization are blocked. Extension installation follows a **default deny** model.
Only explicitly approved extensions are permitted, with a subset force installed where required to maintain security controls. 
All other unapproved extensions are denied by default.

These settings are intended to apply to the managed **Work profile**. Personal profiles are expected to remain unaffected to preserve user privacy. 
This template is used to validate compatibility, usability, and support impact prior to wider rollout.

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

## Configuration Settings

### Microsoft Edge

This policy contains a comprehensive set of CIS aligned browser hardening controls applied at device and user scope.
Controls are grouped by enforcement domain to reflect CIS benchmark structure and operational intent.

---

### Identity and profile controls

* **Browser sign in:** Enabled for work accounts
* **Implicit sign in:** Enabled
* **Default work profile for external links:** Enabled
* **Automatic profile switching:** Enabled for managed work destinations
* **Guest mode:** Disabled
* **Ephemeral profiles:** Disabled
* **Profile creation via identity flyout:** Restricted
* **First run experience and splash screen:** Suppressed
* **Organization branding for work profile:** Enabled

**Risk addressed:** identity sprawl, profile misuse, unmanaged account access

---

### Sync and data protection

* **Browser synchronization:** Restricted
* **Excluded sync data types:** Passwords
* **Password manager:** saving, exporting, importing disabled
* **Autofill:** addresses and payment instruments disabled
* **Browser data import:** disabled for:

  * passwords
  * payment information
  * browser settings
  * home page configuration
  * form data
* **Delete legacy browser data on migration:** Disabled

**Risk addressed:** credential leakage, unmanaged data persistence, silent sync exfiltration

---

### Extension governance

* **External extension installation:** Blocked
* **Extension management:** Enabled with default deny
* **Explicit allow list:** Applied
* **Force installed extensions:** Applied where required
* **Removed extensions:** Explicitly enforced
* **InPrivate browsing enforcement:** Enabled and conditional

---

#### InPrivate mode enforcement

InPrivate browsing is permitted **only when required security extensions are installed and enabled**.
This ensures security monitoring and DLP coverage remain active during private browsing sessions.

**Required extensions for InPrivate mode:**

| Extension                | Extension ID                     | Enforcement |
| ------------------------ | -------------------------------- | ----------- |
| Microsoft Single Sign On | ppnbnpeolgkicgegkbkbjmhlideopiji | Required    |
| Proofpoint ZenWeb        | dioefchpekkdigjeiecepnlhpdcgnmml | Required    |

**Dependency note:**
Proofpoint ZenWeb requires an active **Proofpoint Data Security Workbench** subscription.

Rationale for inclusion:
The Proofpoint browser extension forms part of the broader Proofpoint DLP agent architecture referenced in Sentinel and Proofpoint documentation. Including this dependency here ensures browser level DLP coverage is documented consistently across security tooling.

---

#### Explicitly blocked extensions

| Extension             | Extension ID                     | Reason                                                    |
| --------------------- | -------------------------------- | --------------------------------------------------------- |
| Chrome Remote Desktop | inomeogfingihgjfjlpeplalcfajhgai | Remote access capability not permitted under CIS controls |

---

#### Approved and recommended extensions

The following extensions are approved but **not force installed**.
They may be installed by users where required for role based workflows.

| Extension          | Extension ID                     | Notes                                  |
| ------------------ | -------------------------------- | -------------------------------------- |
| FoxyProxy          | flcnoalcefgkhkinjkffipfdhglnpnem | Approved proxy management              |
| Dark Reader        | ifoakfbpdcdoeenechcleahebpibofpc | Approved accessibility                 |
| uBlock Origin Lite | cimighlppcgcoapaliogpjjdehbnofhn | Approved lightweight content filtering |

---

### Content and web platform restrictions

* **Mixed content loading:** Blocked
* **JavaScript JIT:** Blocked
* **File System API (write):** Blocked
* **File System API (read):** Restricted
* **Web Bluetooth:** Blocked
* **WebHID:** Blocked
* **Serial API:** Blocked
* **SharedArrayBuffers (non isolated):** Blocked
* **Insecure content exceptions:** Blocked
* **Geolocation default:** Blocked
* **Tracking prevention:** Enabled (Balanced)
* **Network prediction:** Disabled
* **Search suggestions:** Disabled
* **Translate:** Enabled

**Risk addressed:** browser based exploitation, hardware access abuse, fingerprinting, client side attacks

---

### Privacy, telemetry, and experimentation controls

* **Ads personalization:** Disabled
* **Browsing history sent to Microsoft:** Disabled
* **Experimentation and configuration service:** Disabled
* **Edge SERP telemetry:** Disabled
* **Wallet and shopping experiences:** Disabled
* **DALL E theme generation:** Disabled
* **Sidebar and consumer experiences:** Disabled
* **User feedback:** Disabled

**Risk addressed:** excessive telemetry, data leakage, consumer feature creep

---

### Download, protocol, and execution controls

* **ClickOnce:** Disabled
* **DirectInvoke:** Disabled
* **Auto launch protocols:** Disabled
* **HTTP authentication:** Restricted
* **Supported auth schemes:** NTLM and Negotiate only
* **OCSP and CRL checks:** Disabled for local trust anchors

**Risk addressed:** protocol abuse, drive by execution, legacy auth misuse

---

### SmartScreen and anti abuse controls

* **Microsoft Defender SmartScreen:** Enabled
* **PUA blocking:** Enabled
* **SmartScreen DNS requests:** Disabled
* **Bypass of SmartScreen prompts:** Blocked
* **Forced SmartScreen checks for trusted downloads:** Enabled
* **Website typo protection:** Enabled

---

## Notes

This template hardens Microsoft Edge for managed work browsing while minimizing credential exposure, data leakage, extension based attack surface, and browser abuse.

Expected user visible impacts include:

* inability to save, import, or export browser passwords
* inability to import browser data from other browsers
* blocked installation of unapproved extensions
* restricted InPrivate browsing unless required security extensions are present
* reduced consumer features and personalization

This behavior is intentional and aligns with CIS Level 1 and Level 2 security objectives.

---
