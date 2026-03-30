# Umbrella DNS Security Flow

## Overview

This diagram shows the full DNS query path through Cisco Umbrella — from a device making a DNS request through identity resolution, policy evaluation, and enforcement to the final allow/block/isolate outcome. It also shows the bypass prevention firewall layer and the roaming client on/off-network logic.

This reflects the implementation documented in [`reference/network-security/guides/umbrella/`](../reference/network-security/guides/umbrella/).

---

## DNS Query Flow

```mermaid
flowchart TD
    subgraph Device["Endpoint — On or Off Network"]
        Win[Windows Device\nUmbrella Roaming Client]
        Mac[macOS Device\nUmbrella Roaming Client]
        OnPrem[On-Premises Device\nInternal DNS → Forwarder]
    end

    subgraph NetworkDetect["On-Network Detection"]
        NetCheck{Roaming Client:\nOn-Network?}
        Win --> NetCheck
        Mac --> NetCheck
        NetCheck -->|Yes — corporate DNS detected| InternalDNS[Internal DNS Server\nForwards to Umbrella]
        NetCheck -->|No — roaming| UmbrellaResolver
        OnPrem --> InternalDNS
    end

    subgraph Resolver["Umbrella Resolver"]
        UmbrellaResolver[Umbrella DNS Resolver\n208.67.222.222 / 208.67.220.220]
        InternalDNS --> UmbrellaResolver
    end

    subgraph Identity["Identity Resolution"]
        IDCheck{Identity Type?}
        UmbrellaResolver --> IDCheck
        IDCheck -->|Roaming Computer| RoamingPolicy[Roaming Computer Policy]
        IDCheck -->|AD User via VA| ADPolicy[AD User or Group Policy]
        IDCheck -->|Network IP match| NetPolicy[Network Identity Policy]
        IDCheck -->|No match| DefaultPolicy[Default Policy]
    end

    subgraph PolicyEval["Policy Evaluation"]
        RoamingPolicy --> Eval
        ADPolicy --> Eval
        NetPolicy --> Eval
        DefaultPolicy --> Eval
        Eval[Evaluate:\nSecurity Categories · Content Categories\nDestination Lists · App Controls]
    end

    subgraph Outcome["Outcome"]
        Eval --> Decision{Action?}
        Decision -->|Allow| ReturnDNS[Return DNS Answer\nConnection proceeds]
        Decision -->|Block — security category| BlockPage[Return Block Page IP\n146.112.61.104]
        Decision -->|Block — content policy| BlockPage
        Decision -->|Proxy — risky domain| IntelProxy[Intelligent Proxy\nFull URL inspection\nSSL re-signed with Cisco root cert]
        IntelProxy -->|Clean| ReturnDNS
        IntelProxy -->|Malicious| BlockPage
    end

    subgraph Isolation["Isolation Layer — High-Risk Users"]
        BlockPage
        ReturnDNS --> IsoCheck{User in\nIsolation Policy?}
        IsoCheck -->|No| FreeAccess[Full browser access]
        IsoCheck -->|Tier 2| RestrictedIso[Isolated Browser\nUpload + Clipboard blocked]
        IsoCheck -->|Tier 3 — VAP or DLP alert| ReadOnlyIso[Isolated Browser\nRead-only — no upload, paste, download]
    end

    subgraph BypassPrevention["Firewall — Bypass Prevention Layer"]
        Firewall{Outbound Port 53\nFirewall Rule}
        FWAllow[Allow to\n208.67.222.222\n208.67.220.220]
        FWDeny[Deny — logged\nBypass attempt alert]
        Firewall -->|Destination = Umbrella| FWAllow
        Firewall -->|Any other destination| FWDeny
        FWAllow --> UmbrellaResolver
    end

    Device --> Firewall
```

---

## Related Documentation

- [`reference/network-security/guides/umbrella/deployment/dns-layer-security-setup-guide.md`](../reference/network-security/guides/umbrella/deployment/dns-layer-security-setup-guide.md) — DNS forwarder configuration and verification
- [`reference/network-security/guides/umbrella/administration/policy-management-and-precedence-guide.md`](../reference/network-security/guides/umbrella/administration/policy-management-and-precedence-guide.md) — Identity resolution order and policy evaluation
- [`reference/network-security/guides/umbrella/troubleshooting/dns-bypass-prevention-guide.md`](../reference/network-security/guides/umbrella/troubleshooting/dns-bypass-prevention-guide.md) — Firewall rules to enforce DNS routing
- [`reference/network-security/guides/umbrella/deployment/roaming-client-mass-deployment-guide.md`](../reference/network-security/guides/umbrella/deployment/roaming-client-mass-deployment-guide.md) — On-network detection and roaming client
