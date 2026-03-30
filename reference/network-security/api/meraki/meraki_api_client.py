#!/usr/bin/env python3
"""
Cisco Meraki API v1 Security Client
====================================
Reference: https://developer.cisco.com/meraki/api-v1/

Covers:
  - Organisation, network, and device inventory
  - Event log retrieval and export
  - Client monitoring and investigation
  - L3 firewall rule management (read, block IP, VLAN isolation, restore)
  - Uplink and device status
  - Rate-limit handling (429 + Retry-After)
  - Automatic pagination (Link headers)

Usage:
  python3 meraki_api_client.py --action list-orgs
  python3 meraki_api_client.py --action list-networks --org-id 123456
  python3 meraki_api_client.py --action get-events --network-id L_XXX --timespan 3600
  python3 meraki_api_client.py --action block-ip --network-id L_XXX --ip 1.2.3.4
  python3 meraki_api_client.py --action isolate-vlan --network-id L_XXX --cidr 10.10.20.0/24

Environment variables:
  MERAKI_API_KEY    — required
  MERAKI_ORG_ID     — default org ID (optional, can be passed via --org-id)
  MERAKI_NETWORK_ID — default network ID (optional, can be passed via --network-id)
"""

import os
import sys
import json
import time
import logging
import argparse
from datetime import datetime, timezone
from typing import Optional

import requests

# ── Logging ───────────────────────────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)-8s  %(message)s",
    datefmt="%Y-%m-%dT%H:%M:%SZ",
)
log = logging.getLogger("meraki")

# ── Colour helpers ────────────────────────────────────────────────────────────
_SUPPORTS_COLOUR = sys.stdout.isatty()

def _c(colour: str, text: str) -> str:
    codes = {"green": "\033[92m", "yellow": "\033[93m", "red": "\033[91m", "cyan": "\033[96m"}
    return f"{codes.get(colour, '')}{text}\033[0m" if _SUPPORTS_COLOUR else text

def ok(msg: str)   -> None: print(_c("green",  f"[PASS] {msg}"))
def warn(msg: str) -> None: print(_c("yellow", f"[WARN] {msg}"))
def err(msg: str)  -> None: print(_c("red",    f"[FAIL] {msg}"))
def info(msg: str) -> None: print(_c("cyan",   f"[INFO] {msg}"))


# ── Meraki Client ─────────────────────────────────────────────────────────────

class MerakiClient:
    """
    Thin wrapper over the Meraki Dashboard API v1.

    Handles:
      - Authentication (X-Cisco-Meraki-API-Key header)
      - Rate limiting (429 → respect Retry-After → retry)
      - Pagination (Link: rel=next header-based)
      - Common security operations (inventory, events, clients, firewall rules)
    """

    BASE_URL = "https://api.meraki.com/api/v1"
    MAX_RETRIES = 6

    def __init__(self, api_key: str) -> None:
        if not api_key:
            raise ValueError("MERAKI_API_KEY is required but not set.")
        self._session = requests.Session()
        self._session.headers.update({
            "X-Cisco-Meraki-API-Key": api_key,
            "Content-Type": "application/json",
            "Accept": "application/json",
            "User-Agent": "meraki-security-client/1.0",
        })

    # ── Internal request helpers ──────────────────────────────────────────

    def _request(self, method: str, endpoint: str, **kwargs) -> dict | list | None:
        url = f"{self.BASE_URL}{endpoint}"
        for attempt in range(self.MAX_RETRIES):
            response = self._session.request(method, url, **kwargs)
            if response.status_code == 429:
                wait = int(response.headers.get("Retry-After", 2 ** attempt))
                warn(f"Rate limited (429). Waiting {wait}s before retry {attempt + 1}/{self.MAX_RETRIES}...")
                time.sleep(wait)
                continue
            if response.status_code == 204:
                return None
            if not response.ok:
                self._raise_for_status(response, endpoint)
            return response.json()
        raise RuntimeError(f"Exceeded {self.MAX_RETRIES} retries for {method} {endpoint}")

    def _paginate(self, endpoint: str, params: Optional[dict] = None) -> list:
        """Follow Link: rel=next headers until all pages are exhausted."""
        results: list = []
        url = f"{self.BASE_URL}{endpoint}"
        params = dict(params or {})

        while url:
            response = self._session.get(url, params=params)
            if response.status_code == 429:
                wait = int(response.headers.get("Retry-After", 2))
                warn(f"Rate limited during pagination. Waiting {wait}s...")
                time.sleep(wait)
                continue
            if not response.ok:
                self._raise_for_status(response, endpoint)
            data = response.json()
            if isinstance(data, list):
                results.extend(data)
            else:
                results.append(data)

            # Advance to next page
            link = response.headers.get("Link", "")
            url = None
            params = {}
            if "rel=next" in link:
                for part in link.split(","):
                    if "rel=next" in part:
                        url = part.split(";")[0].strip().strip("<>")
                        break

        return results

    @staticmethod
    def _raise_for_status(response: requests.Response, endpoint: str) -> None:
        code = response.status_code
        messages = {
            400: "Bad request — check parameters",
            401: "Unauthorised — verify MERAKI_API_KEY",
            403: "Forbidden — check account role and permissions",
            404: f"Not found — verify org/network/device ID in: {endpoint}",
            500: "Meraki server error — retry later",
        }
        detail = messages.get(code, response.text[:200])
        raise requests.HTTPError(f"[{code}] {detail}")

    # ── Organisation & Inventory ──────────────────────────────────────────

    def get_organizations(self) -> list:
        """List all accessible organisations."""
        return self._request("GET", "/organizations")

    def get_networks(self, org_id: str) -> list:
        """List all networks in an organisation."""
        return self._paginate(f"/organizations/{org_id}/networks")

    def get_devices(self, org_id: str) -> list:
        """List all devices in an organisation."""
        return self._paginate(f"/organizations/{org_id}/devices")

    def get_device_statuses(self, org_id: str) -> list:
        """Online/offline status for all devices in an organisation."""
        return self._paginate(f"/organizations/{org_id}/devices/statuses")

    def get_uplink_statuses(self, org_id: str) -> list:
        """MX appliance uplink status across an organisation."""
        return self._paginate(f"/organizations/{org_id}/uplinks/statuses")

    # ── Event Logs ────────────────────────────────────────────────────────

    def get_network_events(
        self,
        network_id: str,
        event_type: Optional[str] = None,
        client_mac: Optional[str] = None,
        device_serial: Optional[str] = None,
        timespan: int = 86400,
        per_page: int = 1000,
    ) -> list:
        """
        Retrieve network event log entries.

        Args:
            network_id:    Meraki network ID (e.g. L_123456789)
            event_type:    Filter by event type (e.g. "association", "firewall")
            client_mac:    Filter by client MAC address
            device_serial: Filter by device serial
            timespan:      Seconds to look back (max 604800 = 7 days)
            per_page:      Results per page (max 1000)
        """
        params: dict = {"timespan": timespan, "perPage": per_page}
        if event_type:
            params["includedEventTypes[]"] = event_type
        if client_mac:
            params["clientMac"] = client_mac
        if device_serial:
            params["deviceSerial"] = device_serial
        return self._paginate(f"/networks/{network_id}/events", params)

    # ── Clients ───────────────────────────────────────────────────────────

    def get_network_clients(self, network_id: str, timespan: int = 86400) -> list:
        """List clients seen on a network within the given timespan (seconds)."""
        params = {"timespan": timespan, "perPage": 1000}
        return self._paginate(f"/networks/{network_id}/clients", params)

    def get_device_clients(self, serial: str) -> list:
        """List clients currently connected to a specific device."""
        return self._request("GET", f"/devices/{serial}/clients")

    def get_client_detail(self, network_id: str, client_id: str) -> dict:
        """Get details for a specific client (by Meraki client ID or MAC)."""
        return self._request("GET", f"/networks/{network_id}/clients/{client_id}")

    # ── Firewall Rules ────────────────────────────────────────────────────

    def get_l3_firewall_rules(self, network_id: str) -> dict:
        """
        Retrieve current L3 firewall rules for an MX appliance.
        Returns dict with 'rules' key containing ordered list of rule objects.
        """
        return self._request("GET", f"/networks/{network_id}/appliance/firewall/l3FirewallRules")

    def update_l3_firewall_rules(
        self,
        network_id: str,
        rules: list,
        syslog_default_rule: bool = False,
    ) -> dict:
        """
        Replace the entire L3 firewall ruleset.

        WARNING: This replaces ALL existing rules. Always GET current rules
        first and prepend/modify before calling this method.

        Args:
            network_id:          Meraki network ID
            rules:               Ordered list of rule objects (first match wins)
            syslog_default_rule: Enable syslog on the implicit default allow rule
        """
        payload = {"rules": rules, "syslogDefaultRule": syslog_default_rule}
        return self._request(
            "PUT",
            f"/networks/{network_id}/appliance/firewall/l3FirewallRules",
            json=payload,
        )

    def block_ip(
        self,
        network_id: str,
        source_ip: str,
        comment: str = "Automated block",
    ) -> dict:
        """
        Prepend a DENY rule for a specific source IP to the existing ruleset.

        The block rule is inserted at position 1 (evaluated first). Existing
        rules are preserved. The implicit default rule is not modified.

        Args:
            network_id: Meraki network ID
            source_ip:  IP address or CIDR (e.g. "1.2.3.4" or "1.2.3.0/24")
            comment:    Rule description — include incident ID for audit trail
        """
        current = self.get_l3_firewall_rules(network_id)
        existing = [r for r in current.get("rules", []) if r.get("comment") != "Default rule"]

        if "/" not in source_ip:
            source_ip = f"{source_ip}/32"

        block_rule = {
            "comment": comment,
            "policy": "deny",
            "protocol": "any",
            "srcPort": "Any",
            "srcCidr": source_ip,
            "destPort": "Any",
            "destCidr": "Any",
            "syslogEnabled": True,
        }
        return self.update_l3_firewall_rules(network_id, [block_rule] + existing)

    def isolate_vlan(
        self,
        network_id: str,
        vlan_cidr: str,
        comment: str = "INCIDENT: VLAN isolated",
    ) -> dict:
        """
        Block all inbound and outbound traffic for a VLAN CIDR.

        Two DENY rules are prepended:
          1. deny src=Any dest=vlan_cidr  (inbound)
          2. deny src=vlan_cidr dest=Any  (outbound)

        Devices in the VLAN retain DHCP leases but lose all connectivity
        to other segments and the internet until the rules are removed.

        Args:
            network_id: Meraki network ID
            vlan_cidr:  VLAN subnet in CIDR notation (e.g. "10.10.20.0/24")
            comment:    Description — include incident ID for audit trail
        """
        current = self.get_l3_firewall_rules(network_id)
        existing = [r for r in current.get("rules", []) if r.get("comment") != "Default rule"]

        isolation_rules = [
            {
                "comment": f"{comment} — inbound",
                "policy": "deny",
                "protocol": "any",
                "srcPort": "Any",
                "srcCidr": "Any",
                "destPort": "Any",
                "destCidr": vlan_cidr,
                "syslogEnabled": True,
            },
            {
                "comment": f"{comment} — outbound",
                "policy": "deny",
                "protocol": "any",
                "srcPort": "Any",
                "srcCidr": vlan_cidr,
                "destPort": "Any",
                "destCidr": "Any",
                "syslogEnabled": True,
            },
        ]
        return self.update_l3_firewall_rules(network_id, isolation_rules + existing)

    def restore_firewall_rules(self, network_id: str, rules: list) -> dict:
        """
        Restore a previously saved ruleset. Pass the 'rules' list from a
        prior get_l3_firewall_rules() call.
        """
        return self.update_l3_firewall_rules(network_id, rules)

    # ── VLANs ─────────────────────────────────────────────────────────────

    def get_vlans(self, network_id: str) -> list:
        """List VLANs configured on an MX appliance."""
        return self._request("GET", f"/networks/{network_id}/appliance/vlans")


# ── CLI Interface ─────────────────────────────────────────────────────────────

def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        description="Cisco Meraki API v1 Security Client",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Actions:
  list-orgs           List accessible organisations
  list-networks       List networks in an organisation (--org-id)
  list-devices        List devices in an organisation (--org-id)
  device-statuses     Device online/offline status (--org-id)
  uplink-statuses     MX appliance uplink status (--org-id)
  list-vlans          List VLANs on a network (--network-id)
  get-events          Pull network event log (--network-id)
  get-clients         List clients on a network (--network-id)
  device-clients      List clients on a device (--serial)
  get-firewall-rules  Read L3 firewall rules (--network-id)
  block-ip            Block a source IP (--network-id --ip)
  isolate-vlan        Isolate a VLAN CIDR (--network-id --cidr)
  restore-firewall-rules  Restore rules from file (--network-id --rules-file)

Examples:
  python3 meraki_api_client.py --action list-orgs
  python3 meraki_api_client.py --action get-events --network-id L_XXX --event-type firewall
  python3 meraki_api_client.py --action block-ip --network-id L_XXX --ip 198.51.100.1 --comment "INCIDENT-042"
  python3 meraki_api_client.py --action isolate-vlan --network-id L_XXX --cidr 10.10.20.0/24
""",
    )

    p.add_argument("--action", required=True, help="Action to perform (see list above)")

    # Identity
    p.add_argument("--org-id",     default=os.environ.get("MERAKI_ORG_ID"),     help="Organisation ID")
    p.add_argument("--network-id", default=os.environ.get("MERAKI_NETWORK_ID"), help="Network ID")
    p.add_argument("--serial",     help="Device serial number")

    # Event filters
    p.add_argument("--event-type",  help="Event type filter (e.g. association, firewall)")
    p.add_argument("--client-mac",  help="Filter events by client MAC address")
    p.add_argument("--timespan",    type=int, default=86400, help="Lookback window in seconds (default: 86400)")

    # Firewall operations
    p.add_argument("--ip",         help="IP address or CIDR to block")
    p.add_argument("--cidr",       help="VLAN CIDR to isolate (e.g. 10.10.20.0/24)")
    p.add_argument("--comment",    default="Automated operation", help="Rule comment / incident reference")
    p.add_argument("--rules-file", help="JSON file containing firewall rules to restore")

    # Output
    p.add_argument("--output", "-o", help="Write JSON output to file instead of stdout")
    p.add_argument("--pretty", action="store_true", help="Pretty-print JSON output")
    p.add_argument("--quiet",  action="store_true", help="Suppress info messages")

    return p


def write_output(data, args) -> None:
    indent = 2 if args.pretty else None
    text = json.dumps(data, indent=indent, default=str)
    if args.output:
        with open(args.output, "w", encoding="utf-8") as f:
            f.write(text)
        ok(f"Output written to: {args.output}")
    else:
        print(text)


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    api_key = os.environ.get("MERAKI_API_KEY")
    if not api_key:
        err("MERAKI_API_KEY environment variable is not set.")
        return 1

    client = MerakiClient(api_key)

    try:
        action = args.action.lower().replace("_", "-")

        # ── Organisation & Inventory ──────────────────────────────────────
        if action == "list-orgs":
            data = client.get_organizations()
            if not args.quiet:
                for org in data:
                    info(f"Organisation: {org.get('name')}  ID: {org.get('id')}")
            write_output(data, args)

        elif action == "list-networks":
            if not args.org_id:
                err("--org-id is required")
                return 1
            data = client.get_networks(args.org_id)
            if not args.quiet:
                for net in data:
                    info(f"Network: {net.get('name')}  ID: {net.get('id')}  Type: {net.get('type')}")
            write_output(data, args)

        elif action == "list-devices":
            if not args.org_id:
                err("--org-id is required")
                return 1
            data = client.get_devices(args.org_id)
            if not args.quiet:
                info(f"Found {len(data)} device(s)")
            write_output(data, args)

        elif action == "device-statuses":
            if not args.org_id:
                err("--org-id is required")
                return 1
            data = client.get_device_statuses(args.org_id)
            if not args.quiet:
                online  = sum(1 for d in data if d.get("status") == "online")
                offline = sum(1 for d in data if d.get("status") == "offline")
                dormant = sum(1 for d in data if d.get("status") == "dormant")
                info(f"Devices — Online: {online}  Offline: {offline}  Dormant: {dormant}")
                for d in data:
                    if d.get("status") != "online":
                        warn(f"  {d.get('status').upper():8s}  {d.get('serial')}  {d.get('name')}")
            write_output(data, args)

        elif action == "uplink-statuses":
            if not args.org_id:
                err("--org-id is required")
                return 1
            data = client.get_uplink_statuses(args.org_id)
            write_output(data, args)

        elif action == "list-vlans":
            if not args.network_id:
                err("--network-id is required")
                return 1
            data = client.get_vlans(args.network_id)
            if not args.quiet:
                for vlan in data:
                    info(f"VLAN {vlan.get('id'):4}  {vlan.get('subnet'):20}  {vlan.get('name')}")
            write_output(data, args)

        # ── Event Logs ────────────────────────────────────────────────────
        elif action == "get-events":
            if not args.network_id:
                err("--network-id is required")
                return 1
            data = client.get_network_events(
                network_id=args.network_id,
                event_type=args.event_type,
                client_mac=args.client_mac,
                timespan=args.timespan,
            )
            if not args.quiet:
                info(f"Retrieved {len(data)} event(s) (timespan: {args.timespan}s)")
            write_output(data, args)

        # ── Clients ───────────────────────────────────────────────────────
        elif action == "get-clients":
            if not args.network_id:
                err("--network-id is required")
                return 1
            data = client.get_network_clients(args.network_id, args.timespan)
            if not args.quiet:
                info(f"Found {len(data)} client(s)")
            write_output(data, args)

        elif action == "device-clients":
            if not args.serial:
                err("--serial is required")
                return 1
            data = client.get_device_clients(args.serial)
            write_output(data, args)

        # ── Firewall Rules ────────────────────────────────────────────────
        elif action == "get-firewall-rules":
            if not args.network_id:
                err("--network-id is required")
                return 1
            data = client.get_l3_firewall_rules(args.network_id)
            rules = data.get("rules", [])
            if not args.quiet:
                info(f"Found {len(rules)} firewall rule(s)")
                for i, r in enumerate(rules[:20], 1):
                    policy = r.get("policy", "?").upper()
                    colour = "green" if policy == "ALLOW" else "red"
                    print(
                        f"  {i:3}. {_c(colour, policy):10}  "
                        f"src={r.get('srcCidr','Any'):25}  "
                        f"dst={r.get('destCidr','Any'):25}  "
                        f"# {r.get('comment','')}"
                    )
                if len(rules) > 20:
                    info(f"  ... and {len(rules) - 20} more (see output file)")
            write_output(data, args)

        elif action == "block-ip":
            if not args.network_id or not args.ip:
                err("--network-id and --ip are both required")
                return 1
            info(f"Blocking IP: {args.ip} on network: {args.network_id}")
            info(f"Comment: {args.comment}")
            data = client.block_ip(args.network_id, args.ip, args.comment)
            ok(f"Block rule applied. Ruleset now has {len(data.get('rules', []))} rule(s).")
            write_output(data, args)

        elif action == "isolate-vlan":
            if not args.network_id or not args.cidr:
                err("--network-id and --cidr are both required")
                return 1
            info(f"Isolating VLAN: {args.cidr} on network: {args.network_id}")
            warn("This will block ALL traffic to/from the specified VLAN CIDR.")
            data = client.isolate_vlan(args.network_id, args.cidr, args.comment)
            ok(f"VLAN isolation applied. Ruleset now has {len(data.get('rules', []))} rule(s).")
            write_output(data, args)

        elif action == "restore-firewall-rules":
            if not args.network_id or not args.rules_file:
                err("--network-id and --rules-file are both required")
                return 1
            with open(args.rules_file, "r", encoding="utf-8") as f:
                saved = json.load(f)
            rules = saved.get("rules", saved) if isinstance(saved, dict) else saved
            data = client.restore_firewall_rules(args.network_id, rules)
            ok(f"Ruleset restored. {len(rules)} rule(s) applied.")
            write_output(data, args)

        else:
            err(f"Unknown action: '{args.action}'. Run with --help for a list of valid actions.")
            return 1

        return 0

    except ValueError as exc:
        err(str(exc))
        return 1
    except requests.HTTPError as exc:
        err(f"HTTP error: {exc}")
        return 1
    except KeyboardInterrupt:
        warn("Interrupted by user.")
        return 130
    except Exception as exc:
        err(f"Unexpected error: {exc}")
        log.exception("Unhandled exception")
        return 1


if __name__ == "__main__":
    sys.exit(main())
