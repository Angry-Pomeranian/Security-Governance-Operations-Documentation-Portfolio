# Query Reference Guide

## traffic_CL Versions

| #               | Query Name                             | Purpose                                                                                              | When to Use                                                                                          | Output                                                                          |
| --------------- | -------------------------------------- | ---------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| **traffic_CL-1** | App summary for a set of servers       | Counts application types (PAN App-IDs) used by specified servers for internet traffic.               | To see what kinds of traffic are leaving your servers and spot unusual apps.                         | One row per application with a connection count.                                |
| **traffic_CL-2** | Deep-dive by application(s)            | Shows detailed connection records for chosen application(s).                                         | To investigate who’s talking to where and on what ports for a specific app like `ssl`.               | Time, source/destination IPs, ports, rule, app, action, device.                 |
| **traffic_CL-3** | Quick distincts                        | Lists unique values for a given field (e.g., Destination IPs).                                       | To see all unique public IPs or other fields without duplicates.                                     | List of distinct values for the chosen column.                                  |
| **traffic_CL-4** | Watchlist join for server names        | Adds human-friendly server names from a Sentinel watchlist.                                          | To avoid manual Excel VLOOKUP; see server names directly in Sentinel results.                        | All logs with extra `ServerName` column from watchlist.                         |
| **traffic_CL-5** | Correlate firewall flows with Defender | Matches firewall logs with Defender network events to find the process/service creating the traffic. | When you have an IP in firewall logs but want to know the originating process (e.g., `outlook.exe`). | Process name, command line, remote details matched to firewall destination IPs. |
| **CSL-1**        | App summary                            | Same as traffic_CL-1 but for `CommonSecurityLog` schema.                                             | When PAN logs are ingested into Sentinel in standard format.                                         | One row per application protocol with a count.                                  |
| **CSL-2**        | Deep-dive by app(s)                    | Same as traffic_CL-2 but for `CommonSecurityLog` schema.                                             | For app-specific investigations in standard schema logs.                                             | Detailed log entries for selected applications.                                 |
| **CSL-3**        | URL visibility                         | Shows URLs/hostnames from URL Filtering logs in Sentinel.                                            | To know exactly what sites the traffic is hitting (beyond IPs).                                      | Time, source/destination IP, hostname, request URL, app, rule.                  |
| **Panorama-1**   | By rule + IP list                      | Filters Panorama Monitor logs by a specific security rule and source IPs.                            | Quick in-console check of multiple IPs in one rule.                                                  | Log view in Panorama web UI.                                                    |
| **Panorama-2**   | By rule only                           | Filters Panorama Monitor logs by a specific rule.                                                    | Quick check of all traffic hitting one security rule.                                                | Log view in Panorama web UI.                                                    |

---

## traffic_CL-1 — App Summary for a Set of Servers

```kusto
let ServerIPs = dynamic([
  "10.0.0.1",
  "10.0.0.2"
]);
traffic_CL
| where TimeGenerated > ago(7d)
| where SourceAddress_s in (ServerIPs)
| where Action_s =~ "allow"
| where isnotempty(DestinationAddress_s)
| where ipv4_is_private(DestinationAddress_s) == false
| summarize applicationCount = count() by Application_s
| order by applicationCount desc
````

**Purpose:** Count types of applications used to talk to the internet.
**Use case:** Spot unexpected outbound apps from specific servers.

---

## traffic\_CL-2 — Deep-Dive by Application(s)

```kusto
let ServerIPs = dynamic([
  "10.0.0.1",
  "10.0.0.2"
]);
let TargetApps = dynamic(["ssl"]);
traffic_CL
| where TimeGenerated > ago(7d)
| where SourceAddress_s in (ServerIPs)
| where Action_s =~ "allow"
| where ipv4_is_private(DestinationAddress_s) == false
| where tolower(Application_s) in (TargetApps)
| project TimeGenerated, SourceAddress_s, DestinationAddress_s, Application_s,
          SourcePort_d, DestinationPort_d, Protocol_s, Action_s, DeviceName_s, Rule_s
| order by TimeGenerated desc
```

**Purpose:** Show detailed records for chosen app(s).
**Use case:** Investigate destinations, ports, and rules for a specific application.

---

## traffic\_CL-3 — Quick Distincts

```kusto
let ServerIPs = dynamic(["10.0.0.1","10.0.0.2"]);
traffic_CL
| where TimeGenerated > ago(7d)
| where SourceAddress_s in (ServerIPs)
| where Action_s =~ "allow"
| where ipv4_is_private(DestinationAddress_s) == false
| distinct DestinationAddress_s
```

**Purpose:** List unique values for a chosen field.
**Use case:** Identify all unique public IPs your servers contacted.

---

## traffic\_CL-4 — Watchlist Join for Server Names

> Requires a watchlist named `ServerMap` with columns `IP` and `ServerName`.

```kusto
let ServerMap = _GetWatchlist('ServerMap') | project IP=tostring(SearchKey), ServerName;
traffic_CL
| where TimeGenerated > ago(7d)
| where Action_s =~ "allow"
| lookup kind=leftouter ServerMap on $left.SourceAddress_s == $right.IP
| project TimeGenerated, ServerName, SourceAddress_s, DestinationAddress_s, Application_s, Rule_s
```

**Purpose:** Add server names directly in query results.
**Use case:** Remove manual Excel/VLOOKUP step.

---

## traffic\_CL-5 — Correlate Firewall Flows with Defender

```kusto
let Flows =
traffic_CL
| where TimeGenerated > ago(7d)
| where Action_s =~ "allow"
| where ipv4_is_private(DestinationAddress_s) == false
| project FlowTime=TimeGenerated, SrcIP=tostring(SourceAddress_s), DstIP=tostring(DestinationAddress_s);
DeviceNetworkEvents
| where Timestamp > ago(7d)
| where isnotempty(RemoteIP)
| join kind=innerunique (Flows | distinct DstIP) on $left.RemoteIP == $right.DstIP
| project Timestamp, DeviceName, InitiatingProcessFileName, InitiatingProcessCommandLine,
          LocalIP, RemoteIP, RemoteUrl, Protocol
| order by Timestamp desc
```

**Purpose:** Find the process/service behind a connection.
**Use case:** See which executable initiated traffic found in firewall logs.

---

## CommonSecurityLog Equivalents

### CSL-1 — App Summary

```kusto
let ServerIPs = dynamic(["10.0.0.1","10.0.0.2"]);
CommonSecurityLog
| where TimeGenerated > ago(7d)
| where SourceIP in (ServerIPs)
| where DeviceAction =~ "allow"
| where ipv4_is_private(DestinationIP) == false
| summarize applicationCount = count() by ApplicationProtocol
| order by applicationCount desc
```

### CSL-2 — Deep-Dive by App(s)

```kusto
let ServerIPs = dynamic(["10.0.0.1","10.0.0.2"]);
let TargetApps = dynamic(["ssl"]);
CommonSecurityLog
| where TimeGenerated > ago(7d)
| where SourceIP in (ServerIPs)
| where DeviceAction =~ "allow"
| where ipv4_is_private(DestinationIP) == false
| where tolower(ApplicationProtocol) in (TargetApps)
| project TimeGenerated, SourceIP, DestinationIP, ApplicationProtocol,
          SourcePort, DestinationPort, Protocol, DeviceAction, DeviceName, RuleName
| order by TimeGenerated desc
```

### CSL-3 — URL Visibility

```kusto
CommonSecurityLog
| where TimeGenerated > ago(7d)
| where isnotempty(RequestURL) or isnotempty(DestinationHostName)
| project TimeGenerated, SourceIP, DestinationIP, DestinationHostName, RequestURL, ApplicationProtocol, RuleName
| order by TimeGenerated desc
```

---

## Panorama Filter Snippets

**By rule + IP list**

```
(rule eq '<Your_Rule_Name>') and (src eq '10.0.0.1' or src eq '10.0.0.2')
```

**By rule only**

```
(rule eq '<Your_Rule_Name>')
```

---

## Notes

* Swap `Action_s`/`DeviceAction`, `Application_s`/`ApplicationProtocol`, `Rule_s`/`RuleName` to match your schema.
* Prefer `ipv4_is_private()` over manual 10./172./192. checks.
* Keep server IP lists in a Watchlist to avoid editing queries.
