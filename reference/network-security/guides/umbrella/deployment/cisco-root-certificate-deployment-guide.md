# Cisco Root Certificate Deployment Guide — Cisco Umbrella

## Overview

When Umbrella's Intelligent Proxy performs SSL inspection on HTTPS traffic, it re-signs the TLS certificate for inspected sites using Cisco's root certificate. Devices that do not trust this certificate will display certificate errors for any HTTPS site that Umbrella inspects.

Certificate errors are one of the most common post-deployment support issues. This guide covers deploying the Cisco Umbrella root certificate to all platforms before enabling SSL inspection.

**When this guide is needed:**
- Umbrella Intelligent Proxy is enabled (or planned)
- Devices are showing TLS certificate warnings after Umbrella activation
- You are deploying to a mixed Windows/Mac/Chromebook environment

---

## Download the Certificate

1. Log in to `https://dashboard.umbrella.com`
2. Navigate to **Admin → Root Certificate**
3. Click **Download Certificate**
4. Save as `Cisco_Umbrella_Root_CA.cer` (DER format) or `Cisco_Umbrella_Root_CA.pem` (PEM format)
   - Windows: use `.cer` (DER)
   - macOS: use `.cer` or `.pem`
   - Linux / Firefox: use `.pem`

**Verify the certificate before deploying:**
```bash
openssl x509 -in Cisco_Umbrella_Root_CA.pem -text -noout | grep -E "Subject:|Issuer:|Not After"
```

Confirm the Subject shows `Cisco Umbrella` and the expiry date is in the future.

---

## Windows — Deploy via Group Policy

GPO deployment pushes the certificate to the Windows certificate store on all domain-joined machines. This covers Internet Explorer, Edge, Chrome, and most Windows applications automatically.

### Step 1 — Stage the Certificate

Copy `Cisco_Umbrella_Root_CA.cer` to a network share accessible by domain computers:
```
\\dc01\NETLOGON\Certs\Cisco_Umbrella_Root_CA.cer
```

### Step 2 — Create a Certificate Distribution GPO

1. **Group Policy Management Console → [target OU or domain] → Create GPO**
2. Name: `Umbrella Root Certificate Distribution`
3. Edit the GPO:
   - Navigate to: `Computer Configuration → Policies → Windows Settings → Security Settings → Public Key Policies → Trusted Root Certification Authorities`
4. Right-click → **Import**
5. Browse to `\\dc01\NETLOGON\Certs\Cisco_Umbrella_Root_CA.cer`
6. Complete the wizard — place in **Trusted Root Certification Authorities**

### Step 3 — Apply and Verify

On a test machine:
```cmd
gpupdate /force
```

Verify the certificate is in the store:
```cmd
certmgr.msc
```
Navigate to: **Trusted Root Certification Authorities → Certificates** — look for `Cisco Umbrella Root CA`.

Or via PowerShell:
```powershell
Get-ChildItem -Path Cert:\LocalMachine\Root | Where-Object { $_.Subject -like "*Umbrella*" }
```

Expected output:
```
Thumbprint                               Subject
----------                               -------
ABCDEF1234567890...                      CN=Cisco Umbrella Root CA, O=Cisco
```

### Step 4 — Verify HTTPS Works After Certificate Push

Open a browser and navigate to any HTTPS site. If Intelligent Proxy is active and the certificate is trusted, there should be no certificate warning. Check the certificate chain in the browser:
- Click the padlock → View Certificate
- The issuing CA should show `Cisco Umbrella Root CA` for inspected sites

---

## macOS — Deploy via MDM (JAMF / Intune)

macOS requires a configuration profile to install certificates in the system keychain. Manual installation only affects the current user keychain and does not cover all apps.

### JAMF — Certificate Profile

1. **JAMF Pro → Computers → Configuration Profiles → New**
2. **General:** Name: `Cisco Umbrella Root Certificate`
3. **Certificate payload → Configure:**
   | Field | Value |
   |---|---|
   | Certificate Name | `Cisco Umbrella Root CA` |
   | Certificate (upload) | `Cisco_Umbrella_Root_CA.cer` |
   | Allow apps access to private key | No (this is a root CA — no private key) |
4. Scope: All managed Macs
5. **Save and deploy**

### Intune — Trusted Certificate Profile (macOS)

1. **Intune Admin Center → Devices → Configuration Profiles → Create → macOS**
2. Profile type: **Trusted certificate**
3. Upload `Cisco_Umbrella_Root_CA.cer`
4. Assign to macOS device group
5. Deploy

### Verify on macOS

```bash
# List trusted root certificates
security find-certificate -a -c "Cisco Umbrella" /Library/Keychains/System.keychain
```

Or via the UI:
1. Open **Keychain Access**
2. Keychain: **System**
3. Category: **Certificates**
4. Search for `Cisco Umbrella` — it should show as **Trusted**

**macOS-specific issue — Privacy Preferences Policy Control (PPPC):**
Umbrella's roaming client on macOS requires FDA (Full Disk Access) and network extension permissions. Without these, the client may fail to intercept DNS queries even if the certificate is installed. Deploy a PPPC profile:

```xml
<!-- PPPC profile for Umbrella Roaming Client -->
<key>PayloadType</key>
<string>com.apple.TCC.configuration-profile-policy</string>
<key>Services</key>
<dict>
    <key>SystemPolicyAllFiles</key>
    <array>
        <dict>
            <key>Allowed</key>
            <true/>
            <key>CodeRequirement</key>
            <string>identifier "com.opendns.osx.RoamingClient"</string>
            <key>IdentifierType</key>
            <string>bundleID</string>
        </dict>
    </array>
</dict>
```

Deploy this PPPC profile alongside the certificate profile.

---

## Google Chrome — Enterprise Policy Deployment

Chrome on Windows reads from the Windows certificate store automatically — no additional Chrome-specific configuration is needed if the GPO certificate deployment (above) is complete.

Chrome on macOS reads from the macOS System Keychain — the JAMF/Intune certificate profile (above) covers this.

**Chrome enterprise policy (additional trust if needed):**
If Chrome still shows certificate errors despite OS-level trust, deploy a Chrome policy:

**Via Intune (Windows):**
1. **Intune → Devices → Configuration Profiles → Create → Windows → Administrative Templates**
2. Search for `CertificateTransparencyEnforcementDisabledForCas`
3. Add the Cisco Umbrella root CA SHA-256 hash to the exclusion list

**Via Chrome ADMX template (GPO):**
1. Download Chrome ADMX templates from Google
2. In Group Policy: `Computer Configuration → Administrative Templates → Google → Google Chrome → Certificate Management`
3. Configure `Additional CA certificates`: add the Cisco Umbrella Root CA

---

## Mozilla Firefox — Certificate Deployment

Firefox uses its own certificate store and does **not** read from the Windows or macOS system certificate store by default. The root certificate must be pushed via Firefox enterprise policy.

### Firefox via Enterprise Policy (Windows — GPO)

1. Download the Firefox ADMX templates: `https://github.com/mozilla/policy-templates`
2. Copy ADMX files to `C:\Windows\SYSVOL\sysvol\{domain}\Policies\PolicyDefinitions`
3. In Group Policy: `Computer Configuration → Administrative Templates → Firefox → Certificates`
4. Enable: **Install Certificates**
5. Add:
   | Field | Value |
   |---|---|
   | URL/Path | `\\dc01\NETLOGON\Certs\Cisco_Umbrella_Root_CA.cer` (or a web URL hosting the cert) |
   | Fingerprint | SHA-256 fingerprint of the cert (from `openssl x509 -fingerprint -sha256`) |

### Firefox via `policies.json` (macOS / Linux)

Create or edit `/Library/Application Support/Mozilla/policies.json` (macOS) or `/etc/firefox/policies/policies.json` (Linux):

```json
{
  "policies": {
    "Certificates": {
      "Install": [
        "/Library/Application Support/Cisco/Umbrella/Cisco_Umbrella_Root_CA.cer"
      ]
    }
  }
}
```

Deploy this file via MDM (JAMF/Intune) or a shell script run at device setup.

### Verify in Firefox

1. Open Firefox → **Settings → Privacy & Security → View Certificates**
2. **Authorities** tab → search for `Cisco`
3. Confirm `Cisco Umbrella Root CA` is listed with `Trust: Web` checked

---

## Chromebook (Chrome OS) — Enterprise Certificate Deployment

Chromebooks managed via Google Workspace or Intune for Chromebooks:

### Google Workspace Admin Console

1. **Admin Console → Devices → Networks → Certificates → Add Certificate**
2. Upload `Cisco_Umbrella_Root_CA.cer`
3. For use with: **Wi-Fi**, **VPN**, and **Web** (check all three)
4. Scope: target the appropriate organisational unit
5. Click **Save**

Chromebooks enrolled in the domain will receive the certificate at next policy sync (typically within 15 minutes).

**Verify on Chromebook:**
1. Open Chrome → `chrome://certificate-manager` (or `Settings → Privacy → Manage Certificates`)
2. **Authorities** tab → search for `Cisco Umbrella`

---

## Verifying the Certificate on Any Platform

Once deployed, perform an end-to-end test:

1. Enable the Intelligent Proxy for a test domain in Umbrella (**Policies → Management → Security Settings → Intelligent Proxy**)
2. Open a browser on a test device and navigate to the domain
3. Click the padlock → View Certificate
4. The certificate issuer should show `Cisco Umbrella Root CA` rather than the site's normal CA
5. No certificate warning should be displayed

If a certificate warning appears:
- Confirm the certificate is in the correct store (System/Root, not User store)
- Confirm the certificate has not expired
- Check if the browser uses a separate certificate store (Firefox)
- Check if the device is actually using Umbrella's Intelligent Proxy — not all domains are proxied

---

## Related

- [Roaming Client Mass Deployment Guide](roaming-client-mass-deployment-guide.md) — Deploy the Umbrella client alongside the certificate.
- [Roaming Client Troubleshooting Guide](../troubleshooting/roaming-client-troubleshooting-guide.md) — Diagnosing Unencrypted / Unprotected states that relate to certificate issues.
- [Unexpected Blocks Troubleshooting Guide](../troubleshooting/unexpected-blocks-troubleshooting-guide.md) — When SSL inspection causes false positive blocks.
