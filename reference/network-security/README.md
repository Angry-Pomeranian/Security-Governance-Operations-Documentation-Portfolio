# Network Security

Implementation guides and API reference for network access control, DNS security, and network infrastructure.

---

## Structure

```
network-security/
├── README.md                         # This file — 802.1X/ClearPass/Palo Alto guide
├── guides/
│   ├── cisco-umbrella-gui-guide.md   # Cisco Umbrella DNS security GUI walkthrough
│   └── umbrella/                     # Cisco Umbrella operations guide suite (11 guides)
│       ├── README.md                 # Suite index and architecture overview
│       ├── deployment/               # Onboarding, DNS setup, roaming client, certificates
│       ├── administration/           # Policy precedence, destination lists, AD integration
│       ├── troubleshooting/          # Client states, unexpected blocks, DNS bypass prevention
│       └── reporting/                # Activity Search, dashboards, client reporting
└── api/
    └── meraki/                       # Meraki API integration reference
```

---

## Related

- Sentinel Cisco Umbrella connector → `../../sentinel/Manual/Cisco/Umbrella/`
- Sentinel Cisco workbooks → `../../sentinel/workbooks/Cisco/`

---

# Enterprise Network Security Implementation Guide

## 802.1X, ClearPass, SEPMAN, Palo Alto SSL Decryption, and Microsoft 365 EDL

---

# 1. 802.1X Network Access Control

## What 802.1X Does

**802.1X is a network access control protocol that ensures only authenticated devices and users can connect to the network.**

When a device connects to a switch or wireless network:

1. The device must authenticate.
2. The authentication request is sent to an authentication server (RADIUS).
3. If successful, the device is allowed onto the network and assigned a VLAN or role.

This prevents **unauthorised devices from accessing internal resources**.

IEEE defines 802.1X as a port based network access control mechanism for authentication of devices before granting LAN access.

---

## 802.1X Architecture

Three components exist:

| Component             | Function                                     |
| --------------------- | -------------------------------------------- |
| Supplicant            | The device requesting access (laptop, phone) |
| Authenticator         | Switch or wireless controller                |
| Authentication Server | RADIUS server such as ClearPass              |

Authentication typically uses **EAP-TLS certificates**.

---

## Basic 802.1X Deployment Steps

### Step 1 Configure Switch

Example concept (vendor commands vary).

Enable 802.1X on access ports.

Example:

```
interface ethernet 1/1
authentication port-control auto
dot1x pae authenticator
```

Configure RADIUS server.

```
radius-server host CLEARPASS-IP key SECRETKEY
```

---

### Step 2 Configure VLAN assignment

ClearPass can dynamically assign VLANs.

Example mapping:

| Device Type      | VLAN            |
| ---------------- | --------------- |
| Corporate device | Corporate VLAN  |
| Guest            | Guest VLAN      |
| Unknown          | Quarantine VLAN |

---

### Step 3 Configure Device Certificates

Devices authenticate using certificates issued by your internal PKI or endpoint security system.

This is where **SEPMAN** integrates.

---

# 2. ClearPass Configuration

## What ClearPass Does

**Aruba ClearPass is a Network Access Control (NAC) platform that manages authentication, authorization, and device profiling.**

It acts as the **RADIUS authentication server** for 802.1X.

ClearPass can also:

• Assign VLANs
• Enforce device posture checks
• Integrate with Active Directory
• Identify device types

Official documentation describes ClearPass as a **policy manager for network access enforcement**.

---

## ClearPass Setup Process

### Step 1 Integrate with Active Directory

Navigate:

```
Administration
External Servers
Active Directory
```

Add domain controller.

Required fields:

| Field    | Example         |
| -------- | --------------- |
| Domain   | company.local   |
| Username | service account |
| Password | password        |

Test connection.

---

### Step 2 Add Network Devices

Navigate:

```
Configuration
Network
Devices
```

Add switches and wireless controllers.

Fields:

| Field                | Example     |
| -------------------- | ----------- |
| IP address           | Switch IP   |
| RADIUS shared secret | Secret key  |
| Vendor type          | Aruba/Cisco |

---

### Step 3 Create Authentication Method

Navigate:

```
Configuration
Authentication
Methods
```

Create **EAP-TLS authentication**.

This allows certificate based device authentication.

---

### Step 4 Create Enforcement Policies

Navigate:

```
Configuration
Enforcement
Policies
```

Example rule:

| Condition             | Action          |
| --------------------- | --------------- |
| AD group = Staff      | Assign VLAN 10  |
| Device type = Unknown | Quarantine VLAN |
| Guest account         | Guest VLAN      |

---

# 3. SEPMAN Endpoint Certificate Management

SEPMAN is used to **manage endpoint certificates and posture verification**.

Devices require certificates for **EAP-TLS authentication**.

---

## SEPMAN Configuration Steps

### Step 1 Deploy Root Certificate

Install enterprise CA certificate on endpoints.

This ensures devices trust the authentication infrastructure.

---

### Step 2 Issue Client Certificates

Certificates must include:

• Client authentication usage
• Device identity
• Valid certificate chain

Example certificate properties:

| Property   | Value                 |
| ---------- | --------------------- |
| EKU        | Client Authentication |
| Key length | 2048 or higher        |
| Issuer     | Enterprise CA         |

---

### Step 3 Deploy Certificates to Endpoints

Methods:

• Intune
• Group Policy
• Endpoint security platform

---

### Step 4 Configure Supplicant

Devices must use **EAP-TLS** authentication.

Windows configuration example:

```
Network Adapter
Authentication
Enable IEEE 802.1X
Authentication Method: Smart Card or Certificate
```

---

# 4. Palo Alto SSL Decryption

## Why SSL Decryption Is Required

Most internet traffic is encrypted with HTTPS.

Without SSL decryption, malicious traffic hidden inside encryption cannot be inspected.

Palo Alto describes SSL Forward Proxy as allowing inspection of encrypted traffic while maintaining user security.

---

## SSL Decryption Types

| Type                   | Purpose                             |
| ---------------------- | ----------------------------------- |
| SSL Forward Proxy      | Inspect outbound HTTPS traffic      |
| SSL Inbound Inspection | Inspect traffic to internal servers |

In most enterprises you implement **SSL Forward Proxy**.

---

# Step 1 Import Decryption Certificate

Navigate:

```
Device
Certificates
```

Create or import:

**Forward Trust Certificate**

Set as:

```
Forward Trust
```

Also create:

```
Forward Untrust Certificate
```

---

# Step 2 Configure Decryption Profile

Navigate:

```
Objects
Decryption Profile
```

Example configuration:

| Setting                    | Value   |
| -------------------------- | ------- |
| Block expired certificates | Enabled |
| Block unsupported ciphers  | Enabled |
| Block weak protocols       | Enabled |

---

# Step 3 Create Decryption Policies

Navigate:

```
Policies
Decryption
```

Example policies:

### No Decrypt Banking

| Setting          | Value              |
| ---------------- | ------------------ |
| Source Zone      | Internal           |
| Destination Zone | Internet           |
| URL Category     | Financial Services |
| Action           | No Decrypt         |

---

### Decrypt HTTPS

| Setting          | Value    |
| ---------------- | -------- |
| Source Zone      | Internal |
| Destination Zone | Internet |
| URL Category     | All      |
| Action           | Decrypt  |

---

### Catch-All No Decrypt

| Setting          | Value      |
| ---------------- | ---------- |
| Source Zone      | Internal   |
| Destination Zone | Internet   |
| Action           | No Decrypt |

---

# Viewing Decryption Logs

Navigate:

```
Monitor
Logs
Decryption
```

This shows:

• decrypted sessions
• failures
• certificate errors

---

# 5. Microsoft 365 Worldwide EDL

Decrypting Microsoft 365 traffic often causes issues and high firewall load.

Palo Alto provides a **Microsoft 365 External Dynamic List (EDL)**.

EDLs automatically download trusted endpoint lists.

---

## What an External Dynamic List Is

An EDL is a **live list of IP addresses, URLs, or domains retrieved from an external source and used by firewall policy rules**.

Palo Alto documentation describes EDLs as automated policy objects that update threat or allow lists dynamically.

---

## Configure Microsoft 365 EDL

Navigate:

```
Objects
External Dynamic Lists
Add
```

Configure:

| Field            | Value                       |
| ---------------- | --------------------------- |
| Name             | O365 Worldwide              |
| Type             | URL                         |
| Source           | Microsoft 365 endpoint list |
| Update Frequency | Hourly or Daily             |

Example source:

```
https://saasedl.paloaltonetworks.com/feeds/m365/worldwide/any/all/url
```

---

## Use EDL in Security Policy

Navigate:

```
Policies
Security
```

Example rule:

| Setting     | Value      |
| ----------- | ---------- |
| Source      | Internal   |
| Destination | O365 EDL   |
| Action      | Allow      |
| Decryption  | No Decrypt |

---

# Final Architecture Summary

A complete enterprise flow works like this:

1 Device connects to switch
2 802.1X requests authentication
3 ClearPass validates device identity
4 SEPMAN verifies certificate posture
5 Device receives VLAN assignment
6 Traffic passes to firewall
7 Firewall applies SSL decryption
8 EDL rules allow trusted services such as Microsoft 365
9 Threat intelligence and inspection protect the network

This layered model ensures:

• only trusted devices join the network
• encrypted threats can be inspected
• trusted cloud services remain functional

---
