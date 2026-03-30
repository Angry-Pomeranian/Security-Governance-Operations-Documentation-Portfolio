# Conditional Access Policies Repository

## Overview

This repository contains a curated collection of Azure Conditional Access policies that I have either:

* Implemented previously in production environments, or
* Built and tested within lab and sandbox tenants for validation and learning purposes

The goal of this repository is to provide reusable, well understood Conditional Access examples that can be referenced, adapted, or deployed by others without needing to start from scratch.

## Policies

### Authentication Methods Policies

| Folder | Policy | Type |
|---|---|---|
| [authentication-method-tap](authentication-method-tap/README.md) | Entra ID – AuthN – Temporary Access Pass | Authentication Methods |
| [authentication-method-microsoft-authenticator](authentication-method-microsoft-authenticator/README.md) | Entra ID – AuthN – Microsoft Authenticator | Authentication Methods |
| [fido2-security-key](fido2-security-key/README.md) | Entra ID – AuthN – FIDO2 Security Key | Authentication Methods |
| [windows-hello](windows-hello/README.md) | Windows – AuthN – Windows Hello | Intune Config Profile |

### Conditional Access Policies

| Folder | Policy | Scope |
|---|---|---|
| [phishing-resistant-mfa-enforcement](phishing-resistant-mfa-enforcement/README.md) | Entra ID – CA – Phishing-Resistant MFA (All Apps) | All users, all apps |
| [pim-server-access](pim-server-access/README.md) | Entra ID – CA – PIM Server Access (Phishing-Resistant) | PIM-eligible users, Azure Management |

### Device & App Protection Policies

| Folder | Policy | Type |
|---|---|---|
| [byomd-app-protect](byomd-app-protect/README.md) | Intune BYOMD App Protection | App Protection Policy |
| [browser-extensions](browser-extensions/README.md) | Browser Extension Control – Windows 11 | Intune Config Profile |
| [disable-usb-v1](disable-usb-v1/README.md) | Disable USB (Device Install Restrictions) | Intune Config Profile |
| [disable-usb-v2](disable-usb-v2/README.md) | Disable USB V2 (Removable Storage) | Intune Config Profile |
| [intune-sync-config-refresh](intune-sync-config-refresh/README.md) | Intune Sync Config Refresh | Runbook / Config |
| [mem-win10-chrome-cis](mem-win10-chrome-cis/README.md) | Windows 10 – Chrome CIS Benchmark | Intune Config Profile |
| [mem-win10-edge-cis](mem-win10-edge-cis/README.md) | Windows 10 – Edge CIS Benchmark | Intune Config Profile |

---

## Scope

The policies in this repository may cover scenarios such as:

* User and group based access controls
* Device compliance and Intune integration
* MFA enforcement and authentication strength
* Session controls and sign in risk handling
* Lab based testing of new Conditional Access features

Each policy reflects a real world use case or a controlled test scenario rather than theoretical examples.

## Data Safety and Sanitisation

All files in this repository have been reviewed to ensure that:

* No Personally Identifiable Information (PII) is present
* No tenant specific identifiers, secrets, or credentials are included
* No Data Loss Prevention (DLP) sensitive content remains

Any names, IDs, or references that could be tied to a real tenant or individual have been removed or replaced with generic placeholders.

Because of this, the raw policy files can be safely downloaded and reused as templates in other environments.

## Usage Notes

* Policies should be reviewed and adjusted before deployment to production
* Always test Conditional Access changes in a lab or pilot group first
* Some policies may depend on licensing, Intune compliance, or identity protection features being enabled

This repository is intended as a reference and starting point, not a drop in production guarantee.

## Disclaimer

These policies are provided as examples only.
You are responsible for validating their impact, compatibility, and security implications within your own tenant.

---
