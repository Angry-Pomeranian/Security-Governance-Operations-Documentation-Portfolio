# Roaming Client Mass Deployment Guide — Cisco Umbrella

## Overview

The Umbrella Roaming Client (now part of Cisco Secure Client) extends DNS protection to devices operating off the corporate network. Cisco's official documentation covers single-machine installs; this guide covers mass deployment at scale via Microsoft Intune, Group Policy, and JAMF.

**What the roaming client does:**
- Intercepts all DNS queries on the device and routes them through Umbrella
- Activates when the device is off-network (no corporate DNS detected)
- On-network: detects the internal DNS resolver and deactivates (network identity handles on-premises traffic)
- Reports device identity to Umbrella, enabling per-device policy and reporting

---

## Pre-Deployment Requirements

Before deploying, download the pre-configured installer from the Umbrella dashboard:

1. **Deployments → Roaming Computers → Roaming Client → Download**
2. The installer is pre-seeded with your organisation's **OrgID** and **fingerprint** — do not use a generic installer
3. Available packages:
   | Platform | Package type |
   |---|---|
   | Windows | `.msi` (preferred for mass deployment) |
   | macOS | `.pkg` |

Note the OrgID and fingerprint — you will need these for registry-based or plist-based configuration if deploying via script.

---

## Windows Deployment via Microsoft Intune

### Method 1 — Win32 App Deployment (MSI)

This is the recommended method for most Intune environments.

**Step 1 — Prepare the installer:**
1. Download the `.msi` from the Umbrella dashboard (as above)
2. Convert to Intune Win32 format using the Microsoft Win32 Content Prep Tool:
   ```cmd
   IntuneWinAppUtil.exe -c C:\UmbrellaClient -s UmbrellaRoamingClient.msi -o C:\IntunePackages
   ```
   This creates `UmbrellaRoamingClient.intunewin`

**Step 2 — Add the app in Intune:**
1. **Intune Admin Center → Apps → All Apps → Add → Windows app (Win32)**
2. Upload the `.intunewin` file
3. Configure:
   | Field | Value |
   |---|---|
   | Name | `Cisco Umbrella Roaming Client` |
   | Publisher | `Cisco Systems` |
   | Install command | `msiexec /i UmbrellaRoamingClient.msi /quiet /norestart` |
   | Uninstall command | `msiexec /x {ProductCode} /quiet /norestart` |
   | Install behaviour | System |
   | Device restart behaviour | App install may force a restart |
   | Operating system architecture | 64-bit |
   | Minimum OS | Windows 10 1809 or later |

4. **Detection rules:**
   - Rule type: Registry
   - Key path: `HKEY_LOCAL_MACHINE\SOFTWARE\OpenDNS\ERC`
   - Value name: `ORG_ID`
   - Detection method: Key exists

5. **Assignments:**
   - Required: target the device group (e.g. `All Windows Devices` or a staged group)
   - Do not use Available — Umbrella should not be optional

**Step 3 — Monitor deployment:**
- Intune Admin Center → Devices → Monitor → App install status
- Filter by app name to see per-device install status
- Allow 24 hours for devices to check in; laptops that are offline will install on next sync

---

### Method 2 — PowerShell Script Deployment (fallback)

Use this if Win32 app deployment is not available or for scripted environments.

```powershell
# Deploy-UmbrellaRoamingClient.ps1
# Run as SYSTEM via Intune Scripts or MECM

$InstallerPath = "\\fileserver\umbrella\UmbrellaRoamingClient.msi"
$LogPath = "C:\ProgramData\Cisco\Umbrella\Deploy.log"

# Silent install
Start-Process -FilePath "msiexec.exe" `
    -ArgumentList "/i `"$InstallerPath`" /quiet /norestart /log `"$LogPath`"" `
    -Wait -NoNewWindow

# Verify installation
$OrgID = Get-ItemProperty -Path "HKLM:\SOFTWARE\OpenDNS\ERC" -Name "ORG_ID" -ErrorAction SilentlyContinue
if ($OrgID) {
    Write-Output "Umbrella Roaming Client installed. OrgID: $($OrgID.ORG_ID)"
} else {
    Write-Output "ERROR: Umbrella Roaming Client installation may have failed."
    exit 1
}
```

Deploy via **Intune → Devices → Scripts → Add → Windows PowerShell script**.

---

## Windows Deployment via Group Policy

Use GPO when Intune is not in use or for domain-joined devices.

### Step 1 — Stage the MSI on a Network Share

Place the MSI in a share accessible to all target computers:
```
\\dc01\NETLOGON\Umbrella\UmbrellaRoamingClient.msi
```

Permissions: `Domain Computers` — Read (computers install software, not users).

### Step 2 — Create a GPO for Software Installation

1. **Group Policy Management Console → [target OU] → Create GPO → Edit**
2. Navigate to: `Computer Configuration → Policies → Software Settings → Software Installation`
3. Right-click → **New → Package**
4. Browse to `\\dc01\NETLOGON\Umbrella\UmbrellaRoamingClient.msi`
5. Deployment method: **Assigned** (installs at next computer startup, no user interaction)
6. Close the GPO editor

**Important:** Use the UNC path, not a local path. The installation runs as SYSTEM before user login and must reach the share.

### Step 3 — Force GPO Application

On test machines:
```cmd
gpupdate /force
shutdown /r /t 0
```

After restart, the MSI will install during the startup sequence (before the login screen). Check the Application event log for MSI installer events.

### Step 4 — Verify Installation via Registry

```cmd
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\OpenDNS\ERC" /v ORG_ID
```

Expected output:
```
HKEY_LOCAL_MACHINE\SOFTWARE\OpenDNS\ERC
    ORG_ID    REG_SZ    7654321
```

The OrgID should match your Umbrella organisation.

---

## macOS Deployment via JAMF

### Step 1 — Upload the PKG to JAMF

1. **JAMF Pro → Computers → Management Settings → Packages → New**
2. Upload `UmbrellaRoamingClient.pkg`
3. Name: `Cisco Umbrella Roaming Client vX.X.X`
4. Category: `Security`

### Step 2 — Create a Policy for Deployment

1. **JAMF Pro → Computers → Policies → New**
2. General tab:
   | Field | Value |
   |---|---|
   | Name | `Deploy Cisco Umbrella Roaming Client` |
   | Trigger | `Recurring Check-In` |
   | Frequency | `Once per computer` |
3. Packages tab:
   - Add the uploaded package
   - Action: `Install`
4. Scope tab:
   - Target: Smart Group for macOS devices without Umbrella installed
   - Create a Smart Group: **Computers → Smart Computer Groups → New**
     - Criteria: `Application Title` — `Does Not Have` — `Cisco Umbrella Roaming Client.app`
5. Click **Save**

### Step 3 — Verify Deployment on macOS

Check the Umbrella client status in the menu bar — the Umbrella icon should appear with "Protected" status.

Command-line verification:
```bash
# Check if Umbrella launch daemon is running
launchctl list | grep -i opendns

# Check registered org ID
defaults read /Library/Application\ Support/OpenDNS/ERC/OrgInfo.plist OrgID
```

---

## Cisco Secure Client Migration

If the client is migrating from the legacy Umbrella Roaming Client to the newer **Cisco Secure Client** (formerly AnyConnect with Umbrella module):

### Key Differences

| Feature | Legacy Roaming Client | Cisco Secure Client + Umbrella Module |
|---|---|---|
| Deployment package | Separate Umbrella installer | Unified Cisco Secure Client with modules |
| Co-existence with VPN | Potential conflicts | Native integration |
| Management | Umbrella dashboard only | Cisco Secure Client management + Umbrella |
| macOS support | Full | Full |
| Windows support | Full | Full |

### Migration Steps

1. Do not uninstall the legacy client before deploying Secure Client — the Secure Client installer will remove the legacy client automatically
2. Download the Secure Client pre-deployment package from Umbrella: **Admin → Integrations → Cisco Secure Client**
3. The Secure Client package must include the **Umbrella Roaming Security module**
4. Deploy Secure Client using the same Intune/GPO/JAMF methods above
5. After deployment: verify in the Umbrella dashboard that devices show **Secure Client** as the agent type (Deployments → Roaming Computers)

**Common migration issue:** After deploying Secure Client, old roaming client entries in the Umbrella dashboard may remain as "Inactive". These clean up automatically after 7 days of no activity — do not delete manually until the new Secure Client entries are confirmed Active.

---

## Post-Deployment Verification

| Check | Method | Expected result |
|---|---|---|
| Device appears in Umbrella dashboard | Deployments → Roaming Computers | Status: Active, Agent: Protected |
| Device uses Umbrella DNS off-network | `nslookup -type=txt debug.opendns.com` from off-network | Returns org ID |
| Correct policy applies | Policy Tester with roaming identity | Correct policy name in result |
| Block page works | `nslookup internetbadguys.com` off-network | Returns `146.112.61.104` |

---

## Troubleshooting Mass Deployment

| Symptom | Likely cause | Fix |
|---|---|---|
| MSI installs but device not appearing in Umbrella | OrgID not embedded (wrong installer) | Re-download installer from dashboard; it embeds OrgID at download time |
| GPO install fails silently | Share permissions deny computer account | Grant `Domain Computers` Read on the share |
| macOS device shows `Unprotected` | Full Disk Access not granted to Umbrella | Deploy PPPC profile via MDM granting FDA to `com.opendns.osx.RoamingClient` |
| Client status stuck `Inactive` | Device not checking in | Check if device has network connectivity; re-register via `scutil --dns` check |
| Secure Client conflict with existing VPN | Module order conflict | Ensure Umbrella module is last in Secure Client module list |

---

## Related

- [New Client Onboarding Checklist](new-client-onboarding-checklist.md) — Full onboarding sequence.
- [Cisco Root Certificate Deployment Guide](cisco-root-certificate-deployment-guide.md) — Certificate push required for SSL inspection.
- [Roaming Client Troubleshooting Guide](../troubleshooting/roaming-client-troubleshooting-guide.md) — Diagnosing client states post-deployment.
