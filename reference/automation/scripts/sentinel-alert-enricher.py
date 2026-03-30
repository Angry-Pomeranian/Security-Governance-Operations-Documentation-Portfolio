"""
sentinel-alert-enricher.py

Queries Microsoft Sentinel for recent high/medium severity alerts, enriches each
alert with IP geolocation and basic threat context, then outputs a structured
triage report to stdout (and optionally a JSON file).

Usage:
    python sentinel-alert-enricher.py \
        --subscription-id <sub-id> \
        --resource-group <rg-name> \
        --workspace-name <workspace-name> \
        [--severity HIGH MEDIUM] \
        [--hours 24] \
        [--output report.json]

Requirements:
    pip install azure-mgmt-securityinsight azure-identity requests

Authentication:
    Uses DefaultAzureCredential — supports Azure CLI, Managed Identity,
    and service principal (AZURE_TENANT_ID, AZURE_CLIENT_ID, AZURE_CLIENT_SECRET).

    Required RBAC: Microsoft Sentinel Reader on the target workspace.
"""

import argparse
import json
import sys
from datetime import datetime, timedelta, timezone
from typing import Optional

import requests
from azure.identity import DefaultAzureCredential
from azure.mgmt.securityinsight import SecurityInsights
from azure.mgmt.securityinsight.models import AlertSeverity


# ---------------------------------------------------------------------------
# IP enrichment
# ---------------------------------------------------------------------------

def enrich_ip(ip_address: str) -> dict:
    """
    Fetch geolocation and basic context for an IP address using ip-api.com.
    Returns an empty dict if the lookup fails or the IP is private/loopback.
    """
    if not ip_address or _is_private_ip(ip_address):
        return {}

    try:
        response = requests.get(
            f"http://ip-api.com/json/{ip_address}",
            params={"fields": "status,country,regionName,city,org,as,query"},
            timeout=5,
        )
        response.raise_for_status()
        data = response.json()

        if data.get("status") != "success":
            return {}

        return {
            "country": data.get("country", ""),
            "region": data.get("regionName", ""),
            "city": data.get("city", ""),
            "org": data.get("org", ""),
            "asn": data.get("as", ""),
        }

    except requests.RequestException:
        return {}


def _is_private_ip(ip: str) -> bool:
    """Return True for RFC1918, loopback, and link-local addresses."""
    private_prefixes = (
        "10.", "172.16.", "172.17.", "172.18.", "172.19.",
        "172.20.", "172.21.", "172.22.", "172.23.", "172.24.",
        "172.25.", "172.26.", "172.27.", "172.28.", "172.29.",
        "172.30.", "172.31.", "192.168.", "127.", "169.254.",
    )
    return any(ip.startswith(prefix) for prefix in private_prefixes)


# ---------------------------------------------------------------------------
# Alert retrieval
# ---------------------------------------------------------------------------

def get_alerts(client: SecurityInsights, resource_group: str, workspace: str,
               severities: list[str], hours: int) -> list[dict]:
    """
    Retrieve alerts from Sentinel filtered by severity and time window.
    Returns a list of simplified alert dicts.
    """
    cutoff = datetime.now(timezone.utc) - timedelta(hours=hours)
    severity_filter = {s.upper() for s in severities}

    alerts = []

    for alert in client.alerts.list(resource_group, workspace):
        # Filter by severity
        alert_severity = (alert.severity or "").upper()
        if alert_severity not in severity_filter:
            continue

        # Filter by time window
        created = alert.time_generated
        if created is None or created < cutoff:
            continue

        # Extract IP entities from the alert's entities list
        ip_addresses = []
        if alert.entities:
            for entity in alert.entities:
                entity_dict = entity.additional_properties or {}
                ip = entity_dict.get("Address") or entity_dict.get("address")
                if ip:
                    ip_addresses.append(ip)

        alerts.append({
            "alert_id": alert.system_alert_id,
            "name": alert.alert_display_name,
            "severity": alert_severity,
            "status": alert.status,
            "created_utc": created.isoformat(),
            "product_name": alert.product_name or "",
            "description": (alert.description or "").strip()[:300],
            "tactics": list(alert.tactics or []),
            "ip_addresses": ip_addresses,
        })

    return sorted(alerts, key=lambda a: a["created_utc"], reverse=True)


# ---------------------------------------------------------------------------
# Report generation
# ---------------------------------------------------------------------------

def build_triage_report(alerts: list[dict]) -> list[dict]:
    """
    Enrich each alert with IP geolocation and build the triage report.
    """
    report = []

    for alert in alerts:
        enriched_ips = []
        for ip in alert["ip_addresses"]:
            geo = enrich_ip(ip)
            enriched_ips.append({"ip": ip, "geo": geo})

        report.append({
            **alert,
            "enriched_ips": enriched_ips,
            "triage_notes": _generate_triage_notes(alert, enriched_ips),
        })

    return report


def _generate_triage_notes(alert: dict, enriched_ips: list[dict]) -> str:
    """
    Generate simple triage notes based on alert attributes and enriched IPs.
    These are starting points for an analyst, not automated decisions.
    """
    notes = []

    if alert["severity"] == "HIGH":
        notes.append("High severity — investigate within 15 minutes.")

    for item in enriched_ips:
        geo = item.get("geo", {})
        country = geo.get("country", "")
        if country and country not in ("Australia", ""):
            notes.append(
                f"IP {item['ip']} geolocates to {geo.get('city', '')}, "
                f"{country} ({geo.get('org', 'unknown org')}) — verify if expected."
            )

    if "Ransomware" in alert["name"] or "Encryption" in alert["name"]:
        notes.append("Potential ransomware indicator — initiate ransomware response playbook.")

    if "CredentialAccess" in alert.get("tactics", []):
        notes.append("Credential access tactic detected — check for LSASS or SAM access.")

    if "Exfiltration" in alert.get("tactics", []):
        notes.append("Exfiltration tactic — review data transfer volume and destination.")

    if not notes:
        notes.append("Review alert entities and correlated events before closing.")

    return " ".join(notes)


def print_report(report: list[dict]) -> None:
    """Print a human-readable summary of the triage report to stdout."""
    width = 80
    print("=" * width)
    print("SENTINEL ALERT TRIAGE REPORT")
    print(f"Generated: {datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')}")
    print(f"Total alerts: {len(report)}")
    print("=" * width)

    for i, alert in enumerate(report, start=1):
        print(f"\n[{i}] {alert['name']}")
        print(f"    Severity : {alert['severity']}")
        print(f"    Status   : {alert['status']}")
        print(f"    Created  : {alert['created_utc']}")
        print(f"    Source   : {alert['product_name']}")

        if alert["tactics"]:
            print(f"    Tactics  : {', '.join(alert['tactics'])}")

        if alert["enriched_ips"]:
            for item in alert["enriched_ips"]:
                geo = item.get("geo", {})
                location = ", ".join(filter(None, [geo.get("city"), geo.get("country")]))
                org = geo.get("org", "")
                geo_str = f" — {location} / {org}" if location else " — private/unresolved"
                print(f"    IP       : {item['ip']}{geo_str}")

        print(f"    Notes    : {alert['triage_notes']}")
        print("-" * width)


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Enrich Microsoft Sentinel alerts with geolocation context."
    )
    parser.add_argument("--subscription-id", required=True, help="Azure subscription ID")
    parser.add_argument("--resource-group", required=True, help="Resource group name")
    parser.add_argument("--workspace-name", required=True, help="Sentinel workspace name")
    parser.add_argument(
        "--severity",
        nargs="+",
        default=["HIGH", "MEDIUM"],
        help="Severity levels to retrieve (default: HIGH MEDIUM)",
    )
    parser.add_argument(
        "--hours",
        type=int,
        default=24,
        help="Retrieve alerts from the last N hours (default: 24)",
    )
    parser.add_argument(
        "--output",
        default=None,
        help="Write JSON report to this file path (optional)",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    print(f"Authenticating to Azure subscription {args.subscription_id}...")
    credential = DefaultAzureCredential()
    client = SecurityInsights(credential, args.subscription_id)

    print(
        f"Retrieving {', '.join(args.severity)} alerts "
        f"from the last {args.hours} hours..."
    )
    alerts = get_alerts(
        client,
        args.resource_group,
        args.workspace_name,
        args.severity,
        args.hours,
    )

    if not alerts:
        print("No alerts matched the specified criteria.")
        sys.exit(0)

    print(f"Found {len(alerts)} alert(s). Enriching with IP geolocation...")
    report = build_triage_report(alerts)

    print_report(report)

    if args.output:
        with open(args.output, "w", encoding="utf-8") as f:
            json.dump(report, f, indent=2, default=str)
        print(f"\nJSON report written to: {args.output}")


if __name__ == "__main__":
    main()
