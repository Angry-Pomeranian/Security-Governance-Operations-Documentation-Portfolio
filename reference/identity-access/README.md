# Identity & Access

Implementation guides, policy definitions, and supporting scripts for identity security controls across Entra ID, MFA, passwordless authentication, and Conditional Access.

---

## Structure

```
identity-access/
├── guides/
│   ├── mfa/                          # MFA configuration and standards
│   └── passwordless/
│       ├── b2c/                      # Azure AD B2C passwordless
│       ├── microsoft-auth/           # Microsoft Authenticator setup
│       ├── passkey/                  # Passkey (FIDO2) deployment
│       ├── tap/                      # Temporary Access Pass
│       ├── whfb/                     # Windows Hello for Business
│       └── servers/                  # Passwordless for server access (PIM-based, 5-step)
└── policies/
    └── conditional-access/
        ├── byomd-app-protect/        # BYOD MAM/App Protection policies
        ├── browser-extensions/       # Browser extension control
        ├── disable-usb-v1/           # USB block policy (version 1)
        ├── disable-usb-v2/           # USB block policy (version 2)
        ├── intune-sync-config-refresh/  # Intune config refresh + Check-ConfigRefresh.ps1
        ├── mem-win10-chrome-cis/     # Chrome CIS L1/L2 via MEM
        ├── mem-win10-edge-cis/       # Edge CIS L1/L2 via MEM
        └── windows-hello/            # Windows Hello for Business policy
```

---

## Key Documents

| Path | Description |
|------|-------------|
| `guides/passwordless/servers/` | 5-step PIM-based passwordless rollout for servers |
| `guides/passwordless/tap/` | Temporary Access Pass provisioning |
| `guides/passwordless/whfb/` | Windows Hello for Business deployment |
| `policies/conditional-access/byomd-app-protect/` | MAM App Protection policy for BYOD |
| `policies/conditional-access/intune-sync-config-refresh/` | Intune config refresh with PowerShell validator |

---

## Related

- Sentinel data connector → `../../sentinel/Manual/Azure/Entra ID/`
- Browser CIS benchmark reference → `../endpoint-hardening/benchmarks/browsers/`
