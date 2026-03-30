# MEM - Win10+ - Chrome CIS L1 & L2

## Overview

**Platform:** Windows 10 and later
**Profile Type:** Administrative Templates

**Description:**
This policy applies the **CIS Benchmark Level 1 and Level 2 configuration baselines** for **Google Chrome** on **Windows 10 and later** devices. It enforces secure browser configurations aligned with CIS recommendations — including restrictions on **data sharing, extension management, password storage, and insecure content access**.

The purpose of this pilot is to validate compatibility and user experience across a representative device group before organization-wide rollout. Findings from this phase will help refine final baseline values to balance **security, usability, and compliance** within *company*’s managed environment.

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

### Security & Network

| Setting                                                                    | Value                                                                              |
| -------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| Cross-origin HTTP Authentication prompts                                   | Disabled                                                                           |
| Disable Certificate Transparency enforcement (Legacy CAs)                  | Disabled                                                                           |
| Disable Certificate Transparency enforcement (subjectPublicKeyInfo hashes) | Disabled                                                                           |
| Disable Certificate Transparency enforcement (URLs)                        | Disabled                                                                           |
| Disable saving browser history                                             | Enabled: Browser history saved                                                     |
| DNS interception checks enabled                                            | Enabled                                                                            |
| Enable component updates in Google Chrome                                  | Enabled                                                                            |
| Enable globally scoped HTTP auth cache                                     | Disabled                                                                           |
| Enable online OCSP/CRL checks                                              | Disabled                                                                           |
| Enable security warnings for command-line flags                            | Enabled                                                                            |
| Enable third party software injection blocking                             | Enabled                                                                            |
| Safe Browsing Protection Level                                             | Enabled: Safe Browsing is always active in the standard mode                       |
| Enforces managed extensions to use Enterprise Hardware Platform API        | Disabled                                                                           |
| Ephemeral profile                                                          | Disabled                                                                           |
| Import autofill form data from default browser on first run                | Disabled                                                                           |
| Import homepage from default browser on first run                          | Disabled: homepage isn’t imported on first run                                     |
| Import search engines from default browser on first run                    | Disabled                                                                           |
| Bypass HSTS policy check list                                              | Disabled                                                                           |
| Origins/hostnames excluded from insecure origin restrictions               | Disabled                                                                           |
| Suppress lookalike domain warnings                                         | Disabled                                                                           |
| Suppress unsupported OS warning                                            | Disabled                                                                           |
| URLs exposing local IPs in WebRTC                                          | Disabled                                                                           |
| Allow Google Cast connections on all IPs                                   | Disabled                                                                           |
| Allow queries to a Google time service                                     | Enabled                                                                            |
| Allow the audio sandbox to run                                             | Enabled                                                                            |
| Ask where to save each file before downloading                             | Enabled                                                                            |
| Continue running background apps when Chrome is closed                     | Disabled                                                                           |
| Control SafeSites adult content filtering                                  | Disabled                                                                           |
| Determine availability of variations                                       | Enable all variations                                                              |
| Require Site Isolation for every site                                      | Enabled                                                                            |
| Enforce Google SafeSearch                                                  | Disabled                                                                           |
| Notify users that relaunch/restart is required                             | Enabled                                                                            |
| Proxy settings                                                             | Enabled: "ProxyMode":"system"                                                      |
| Require online OCSP/CRL checks for local trust anchors                     | Not Configured: (leave unset)                                                      |
| Set time period for update notifications                                   | Enabled: 64800000 (18 hours – Balanced-aggressive)                                 |
| Control use of insecure content exceptions                                 | Enabled: Do not allow any site to load mixed content                               |
| Control use of the WebUSB API                                              | Enabled: Do not allow any site to request access to USB devices via the WebUSB API |
| Control use of Web Bluetooth API                                           | Not Configured: (leave unset)                                                      |
| Allow remote debugging                                                     | Disabled: users are not allowed to use remote debugging                            |
| Supported authentication schemes                                           | Unset: employs all 4 schemes (basic, digest, ntlm, negotiate)                      |
| Auto-update check period override                                          | Enabled: Set to 295 (10 hours)                                                     |
| Update policy override                                                     | Enabled: Always allow updates                                                      |
| Enable TLS Encrypted ClientHello                                           | Enabled                                                                            |
| Insecure Hashes in TLS Handshakes                                          | Disabled                                                                           |
| Enable strict MIME type checking for worker scripts                        | Enabled                                                                            |
| Enable Renderer App Container                                              | Enabled                                                                            |

---

### Privacy & Data Protection

| Setting                                                        | Value                                                                |
| -------------------------------------------------------------- | -------------------------------------------------------------------- |
| Disable synchronization of data with Google                    | Enabled                                                              |
| Keep browsing data when creating enterprise profile by default | Enabled                                                              |
| Disable saving browser history                                 | Enabled: Browser history saved                                       |
| Enable deleting browser and download history                   | Disabled: browser history and download history can't be deleted      |
| Enable URL-keyed anonymized data collection                    | Disabled                                                             |
| Enable reporting of usage and crash-related data               | Disabled                                                             |
| Control how Chrome Cleanup reports data to Google              | Disabled                                                             |
| Safe Browsing for trusted sources                              | Disabled                                                             |
| Allow reporting of domain reliability related data             | Disabled                                                             |
| Disable proceeding from the Safe Browsing warning page         | Enabled                                                              |
| Allow proceeding from SSL warning page                         | Enabled: lets users click through SSL warning pages                  |
| Default cookies setting                                        | Enabled: Keep cookies for the duration of the session                |
| Block third party cookies                                      | Disabled: Allows third-party cookies (least private)                 |
| Default geolocation setting                                    | Enabled: Do not allow any site to track the users' physical location |
| Default sensors setting                                        | Enabled: Allow sites to access sensors                               |
| Default clipboard setting                                      | Enabled: Allow sites to ask the user to grant clipboard permission   |

---

### Authentication & Sign-in

| Setting                                                       | Value                                                  |
| ------------------------------------------------------------- | ------------------------------------------------------ |
| Allow automatic sign-in to Microsoft cloud identity providers | Enabled: Enable Microsoft® cloud authentication        |
| Browser sign-in settings                                      | Enabled: Disabled browser sign-in                      |
| Enable saving passwords to the password manager               | Disabled (all versions)                                |
| Import saved passwords from default browser on first run      | Disabled                                               |
| List of types excluded from synchronization                   | Enabled: Passwords & extensions are excluded from sync |
| Ephemeral profile                                             | Disabled                                               |
| Enable guest mode in browser                                  | Disabled: no guest profiles                            |
| Incognito mode availability                                   | Enabled: Incognito mode available (enabled)            |

---

### Extensions & Plugins

| Setting                                                            | Value                                               |
| ------------------------------------------------------------------ | --------------------------------------------------- |
| Blocks external extensions from being installed                    | Enabled                                             |
| Configure allowed app/extension types                              | Enabled: extension, hosted_app, platform_app, theme |
| Configure extension installation blocklist                         | Enabled: *                                          |
| Configure native messaging blocklist                               | Enabled: *                                          |
| Control Manifest v2 extension availability                         | Enabled: Set to Forced Only                         |
| Control availability of extensions unpublished on Chrome Web Store | Disabled: unpublished on Chrome Web Store disabled  |
| Configure the list of force-installed apps and extensions          | Enabled                                             |
| Control Manifest v2 extension availability                         | Enabled: Set to Forced Only                         |

---

### Remote Access & Assistance

| Setting                                                                            | Value                            |
| ---------------------------------------------------------------------------------- | -------------------------------- |
| Allow remote access connections to this machine                                    | Disabled                         |
| Allow remote users to interact with elevated windows in remote assistance sessions | Disabled                         |
| Configure required domain names for remote access clients                          | Enabled: company.com,            |
| Enable curtaining of remote access hosts                                           | Disabled                         |
| Enable firewall traversal from remote access host                                  | Disabled                         |
| Enable relay servers for remote access host                                        | Disabled                         |
| Enable or disable PIN-less authentication for remote access hosts                  | Disabled                         |

---

### User Interface & Content

| Setting                                               | Value                                                         |
| ----------------------------------------------------- | ------------------------------------------------------------- |
| Enable Translate                                      | Enabled: True – provides translation toolbar and context menu |
| Enable AutoFill for addresses                         | Disabled: AutoFill disabled                                   |
| Enable AutoFill for credit cards                      | Disabled: AutoFill disabled                                   |
| Enable alternate error pages                          | Disabled                                                      |
| Enable Google Search Side Panel                       | Disabled                                                      |
| Enable First-Party Sets                               | Disabled                                                      |
| Enable Google Cloud Print proxy                       | Disabled                                                      |
| Allow websites to query for available payment methods | Disabled                                                      |
| Allow user feedback                                   | Disabled                                                      |
| Enable or disable spell checking web service          | Disabled                                                      |
| Enable search suggestions                             | Disabled: False turns off search suggestions                  |
| Enable network prediction                             | Disabled: Do not predict actions on any network connection    |
| Suppress unsupported OS warning                       | Disabled                                                      |
| Allow local file access to file:// URLs in PDF Viewer | Disabled                                                      |

---

### API and Hardware Access

| Setting                                                                     | Value                                                                               |
| --------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| Control use of the Serial API                                               | Enabled: Do not allow any site to request access to serial ports via the Serial API |
| Control use of the WebUSB API                                               | Enabled: Do not allow any site to request access to USB devices via the WebUSB API  |
| Allow file or directory picker APIs to be called without prior user gesture | Disabled                                                                            |
| Allow or deny audio capture                                                 | Enabled: Users get prompted for audio capture access                                |
| Allow or deny video capture                                                 | Enabled: Users get prompted for video capture access                                |
| Allow or deny screen capture                                                | Not Configured: (leave unset)                                                       |
| Default Window Management permission                                        | Enabled: Denies permission on all sites by default                                  |
| Block Window Management permission on these sites                           | Not Configured: (leave unset)                                                       |
| Allow clipboard on these sites                                              | Enabled: [*.]company.com                                                            |
| Block clipboard on these sites                                              | Enabled: [*.]deepseek.com                                                           |

---

### Performance & Updates

| Setting                                  | Value                                              |
| ---------------------------------------- | -------------------------------------------------- |
| Determine the availability of variations | Enable all variations                              |
| Set disk cache size, in bytes            | Enabled: 250609664                                 |
| Auto-update check period override        | Enabled: Set to 295 (10 hours)                     |
| Update policy override                   | Enabled: Always allow updates                      |
| Set time period for update notifications | Enabled: 64800000 (18 hours – Balanced-aggressive) |
| Enable component updates in Chrome       | Enabled                                            |

---

## Notes

This configuration enforces **CIS Level 1 and 2 baselines** for Google Chrome on Windows 10+ within *company*. It ensures security hardening through controlled updates, strict permissions, and minimized user override capability.
---
