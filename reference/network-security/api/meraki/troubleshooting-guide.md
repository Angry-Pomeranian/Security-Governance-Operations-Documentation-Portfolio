# Cisco Meraki API v1 — Troubleshooting Guide

## Quick Reference

| Symptom | Most Likely Cause | Jump to |
|---|---|---|
| `401 Unauthorized` | Bad or missing API key | [§1 Authentication errors](#1-authentication-errors) |
| `403 Forbidden` | Insufficient account role | [§2 Permission errors](#2-permission-errors) |
| `404 Not Found` | Wrong organisation/network/device ID | [§3 Resource not found](#3-resource-not-found) |
| `429 Too Many Requests` | Rate limit exceeded | [§4 Rate limiting](#4-rate-limiting) |
| Empty response / missing data | Pagination not handled | [§5 Pagination issues](#5-pagination-issues) |
| Firewall rules not applying | Full ruleset replace caveat | [§6 Firewall rule issues](#6-firewall-rule-issues) |
| Slow or timeout errors | Large dataset / network latency | [§7 Performance issues](#7-performance-issues) |
| Python `ModuleNotFoundError` | Dependencies not installed | [§8 Setup issues](#8-setup-issues) |

---

## 1. Authentication Errors

### `401 Unauthorized`

**Cause:** The API key in the `X-Cisco-Meraki-API-Key` header is invalid, expired, or missing.

**Checks:**

```bash
# Verify the environment variable is set
echo $MERAKI_API_KEY

# Test the key directly with curl
curl -s -H "X-Cisco-Meraki-API-Key: $MERAKI_API_KEY" \
    https://api.meraki.com/api/v1/organizations | python3 -m json.tool
```

**Resolution:**

1. Confirm `MERAKI_API_KEY` is exported in your shell or `.env` file.
2. Check the key has not been revoked: `Meraki Dashboard → My Profile → API access`.
3. API keys are tied to the **user account** that generated them. If the account was deactivated or the key was regenerated, the old key is invalid.
4. Generate a new key if needed and update your secrets store.

---

### API key works from curl but not from the script

1. Confirm there are no leading/trailing spaces in the environment variable:
   ```python
   import os; print(repr(os.environ.get("MERAKI_API_KEY")))
   ```
2. If using a `.env` file, confirm `python-dotenv` is installed and `load_dotenv()` is called before the first API call.

---

## 2. Permission Errors

### `403 Forbidden`

**Cause:** The API key is valid but the associated account does not have permission to perform the requested operation.

**Common scenarios:**

| Operation | Required role |
|---|---|
| `GET /organizations` | Organisation Administrator |
| `GET /networks` | Network Reader (minimum) |
| `GET /networks/{id}/events` | Network Reader |
| `PUT /l3FirewallRules` | Network Administrator |
| `POST /networks/{id}/appliance/vlans` | Network Administrator |

**Resolution:**

1. Check the account's role: `Meraki Dashboard → Organisation → Administrators → [account name]`
2. For read-only integrations, assign **Network Reader** at the organisation level.
3. For incident response automations that update firewall rules, assign **Network Administrator**.
4. If using a service account, verify it has the required role on the **correct scope** (organisation vs individual network).

---

## 3. Resource Not Found

### `404 Not Found`

**Cause:** The organisation ID, network ID, or device serial in the request path does not exist or is not accessible to the API key's account.

**Checks:**

```bash
# Confirm you can see the organisation
python3 meraki_api_client.py --action list-orgs

# Confirm you can see the target network
python3 meraki_api_client.py --action list-networks --org-id YOUR_ORG_ID
```

**Common mistakes:**

| Mistake | Example wrong value | Fix |
|---|---|---|
| Organisation ID vs Network ID confusion | Using `L_123456` as an org ID | Org IDs are numeric strings like `123456`; network IDs start with `L_` or `N_` |
| Stale IDs from old environment | Hardcoded network ID in `.env` | Re-run `list-networks` to refresh the current ID |
| Wrong region | Using a network from a different Meraki region | Meraki is a global platform; IDs are unique — confirm with `list-networks` |
| Typos in serial numbers | `Q2KN-XXX-XXX` vs `Q2KN-XXXX-XXXX` | Copy-paste serials from `list-devices` output |

---

## 4. Rate Limiting

### `429 Too Many Requests`

**Cause:** The default rate limit is 10 requests/second per organisation. Burst requests or parallel threads hitting the same organisation will trigger 429 responses.

**Response headers to check:**
```
Retry-After: 2
```

**Script handling:** The included `meraki_api_client.py` automatically respects `Retry-After` and retries up to 6 times with exponential backoff. If you are seeing persistent 429s:

1. Check for parallel invocations of the script against the same organisation.
2. Reduce `per_page` for list endpoints to slow iteration.
3. Add a fixed delay between sequential API calls:
   ```python
   import time
   time.sleep(0.15)  # ~7 req/s sustained
   ```
4. For high-throughput use cases, contact Meraki support to discuss rate limit increases.

**Monitoring rate limit hits:**
```bash
python3 meraki_api_client.py --action get-events \
    --network-id L_XXX --timespan 3600 2>&1 | grep "Rate limited"
```

---

## 5. Pagination Issues

### Getting fewer results than expected / missing recent events

**Cause:** Meraki list endpoints return paginated results. If pagination is not handled, only the first page of results is returned.

**Symptoms:**
- Event export returns exactly 100 or 1000 records (matching the `perPage` limit)
- Client list appears truncated
- Device inventory appears incomplete

**Resolution:**

The `meraki_api_client.py` script handles pagination automatically via `Link: rel=next` headers. If you are calling the API directly:

```python
def get_all_pages(session, url, params=None):
    results = []
    params = dict(params or {})
    while url:
        resp = session.get(url, params=params)
        resp.raise_for_status()
        results.extend(resp.json())
        link = resp.headers.get("Link", "")
        url, params = None, {}
        if "rel=next" in link:
            for part in link.split(","):
                if "rel=next" in part:
                    url = part.split(";")[0].strip().strip("<>")
                    break
    return results
```

**Tip:** For event logs, also check `timespan` — the maximum is 604800 (7 days). For longer windows, paginate across multiple time windows.

---

## 6. Firewall Rule Issues

### Rules applied but not appearing in the Dashboard

**Cause:** The Meraki Dashboard may take 30–60 seconds to reflect API-applied rule changes. The API response confirms the change was accepted.

**Resolution:** Wait 60 seconds and refresh the Dashboard view under `Security & SD-WAN → Firewall`.

---

### Firewall rule changes wiped existing rules

**Cause:** `PUT /l3FirewallRules` **replaces the entire ruleset**, not just the modified rule. If the `rules` array in the request body only contains the new rule, all other rules are deleted.

**Prevention:** Always GET the current rules before updating:

```python
# Safe pattern — always preserve existing rules
current = client.get_l3_firewall_rules(network_id)
existing_rules = current.get("rules", [])
existing_rules = [r for r in existing_rules if r.get("comment") != "Default rule"]

new_rule = { ... }  # your new rule
all_rules = [new_rule] + existing_rules  # prepend, don't replace

client.update_l3_firewall_rules(network_id, all_rules)
```

**Recovery:** If rules were accidentally wiped, check the Meraki Dashboard change log:
`Organisation → Change log` — this shows previous rule states and the API call that made the change. You cannot roll back via the API, but you can manually recreate rules from the change log.

---

### Block rule is not blocking traffic

**Cause:** Meraki L3 firewall rules are evaluated **top-down; first match wins**. If a broader ALLOW rule exists above the DENY rule, the ALLOW rule matches first and traffic is permitted.

**Checks:**
```bash
python3 meraki_api_client.py --action get-firewall-rules --network-id L_XXX --pretty
```

Verify the DENY rule appears at position 1 in the output. If not, the update did not place it first — re-run the `block-ip` action.

---

### `400 Bad Request` when updating firewall rules

**Cause:** Invalid rule schema. Common mistakes:

| Field | Common error | Correct value |
|---|---|---|
| `protocol` | `"TCP"` | `"tcp"` (lowercase) |
| `srcPort` | `""` (empty string) | `"Any"` |
| `srcCidr` | `"1.2.3.4"` (no mask) | `"1.2.3.4/32"` |
| `policy` | `"block"` | `"deny"` |

**Valid policy values:** `"allow"` or `"deny"` (lowercase).
**Valid protocol values:** `"tcp"`, `"udp"`, `"icmp"`, `"any"`.
**Port values:** number string like `"443"`, range like `"8000-8080"`, or `"Any"`.

---

## 7. Performance Issues

### Slow event retrieval for large networks

**Cause:** Paginating through thousands of events with `perPage=100` requires many round trips.

**Resolution:** Use the maximum `perPage=1000` for event queries:
```bash
python3 meraki_api_client.py --action get-events --network-id L_XXX --timespan 86400
# The client uses perPage=1000 by default
```

---

### Connection timeout on large organisation inventories

**Cause:** The `GET /organizations/{orgId}/devices` endpoint for very large organisations can be slow.

**Resolution:** Use per-network queries if org-wide queries time out:
```bash
# Per-network device query
for network_id in $(python3 meraki_api_client.py --action list-networks --org-id 123456 | jq -r '.[].id'); do
    python3 meraki_api_client.py --action get-clients --network-id $network_id --quiet
done
```

---

## 8. Setup Issues

### `ModuleNotFoundError: No module named 'requests'`

```bash
pip3 install requests
# or within a virtual environment:
python3 -m venv .venv && source .venv/bin/activate
pip install requests
```

---

### `json.decoder.JSONDecodeError`

**Cause:** The API returned a non-JSON response (usually an error page or a maintenance redirect).

**Resolution:**
```python
response = session.get(url)
print(response.status_code, response.headers.get("Content-Type"))
print(response.text[:500])  # inspect raw response
```

If the API is returning HTML, Meraki may be experiencing an outage. Check: https://status.meraki.net

---

## 9. Meraki Platform Checks

### API not responding / 5xx errors

1. Check Meraki platform status: **https://status.meraki.net**
2. Verify the API endpoint is reachable:
   ```bash
   curl -v https://api.meraki.com/api/v1/organizations \
       -H "X-Cisco-Meraki-API-Key: $MERAKI_API_KEY" 2>&1 | head -50
   ```
3. If behind a corporate proxy, ensure `api.meraki.com` is allowlisted.

### Confirming API is enabled for the organisation

```
Meraki Dashboard → Organisation → Settings → Dashboard API access
```
Must be set to: **Enable access to the Cisco Meraki Dashboard API**

---

## Related

- [Implementation Guide](implementation-guide.md) — Full authentication and rate limit handling reference.
- [Operational Playbook](operational-playbook.md) — Step-by-step procedures for security operations.
- [Python Client Script](meraki_api_client.py) — Source for the `meraki_api_client.py` script referenced above.
