# Impossible Travel + Suspicious Login — Incident Response Pipeline

End-to-end technical implementation for detecting, investigating, and responding to an impossible travel event correlated with suspicious endpoint activity. Covers the full lifecycle from KQL detection through automated containment.

**Scenario:** A user account produces two successful sign-ins within two hours from geographic locations that are physically impossible to travel between. Activity is cross-correlated against endpoint telemetry and user risk scoring to determine whether the event represents a genuine account compromise.

**Environment:** Microsoft Sentinel (`ws-prod-sentinel-01` / `corp-sentinel-rg`) · Microsoft Entra ID (`corp.onmicrosoft.com`) · CrowdStrike Falcon · Microsoft Intune · Azure Logic Apps

---

## 1. Detection Engineering

Three layered KQL queries: impossible travel calculation, risk event enrichment, and cross-source device correlation. Run in Microsoft Sentinel Log Analytics or as hunting queries.

### 1.1 KQL Query: Impossible Travel Detection

Calculates travel speed between consecutive successful sign-ins for the same user within a two-hour window. Flags sessions where physical travel would require exceeding 900 km/h.

```kql
// Impossible Travel Detection
// Tables: SigninLogs
// Run frequency: Hourly | Look-back: 24h
let ExcludedPrefixes = dynamic(["10.", "172.16.", "172.17.", "172.18.", "192.168."]);
SigninLogs
| where TimeGenerated > ago(24h)
| where ResultType == 0
| where not(IPAddress has_any (ExcludedPrefixes))
| where isnotempty(LocationDetails.geoCoordinates.latitude)
| extend
    Lat       = toreal(LocationDetails.geoCoordinates.latitude),
    Lon       = toreal(LocationDetails.geoCoordinates.longitude),
    Country   = tostring(LocationDetails.countryOrRegion),
    City      = tostring(LocationDetails.city),
    MFAMethod = tostring(AuthenticationDetails[0].authenticationMethod),
    MFAResult = tostring(AuthenticationDetails[0].authenticationStepResultDetail),
    DeviceId  = tostring(DeviceDetail.deviceId)
| sort by UserPrincipalName asc, TimeGenerated asc
| serialize
| extend
    PrevTime    = prev(TimeGenerated, 1),
    PrevLat     = prev(Lat, 1),
    PrevLon     = prev(Lon, 1),
    PrevCountry = prev(Country, 1),
    PrevCity    = prev(City, 1),
    PrevIP      = prev(IPAddress, 1),
    PrevUser    = prev(UserPrincipalName, 1)
| where UserPrincipalName == PrevUser
| extend
    TimeDiffHours = datetime_diff('minute', TimeGenerated, PrevTime) / 60.0,
    DistanceKm    = geo_distance_2points(PrevLon, PrevLat, Lon, Lat) / 1000.0
| where TimeDiffHours > 0 and TimeDiffHours <= 2
| extend SpeedKmh = DistanceKm / TimeDiffHours
| where SpeedKmh > 900
| project
    TimeGenerated,
    UserPrincipalName,
    CurrentIP      = IPAddress,
    CurrentCountry = Country,
    CurrentCity    = City,
    PreviousIP     = PrevIP,
    PreviousCountry = PrevCountry,
    PreviousCity   = PrevCity,
    TimeDiffHours  = round(TimeDiffHours, 2),
    DistanceKm     = round(DistanceKm, 0),
    SpeedKmh       = round(SpeedKmh, 0),
    MFAMethod,
    MFAResult,
    DeviceId,
    AppDisplayName,
    ConditionalAccessStatus
| order by SpeedKmh desc
```

**Key output fields:** `UserPrincipalName`, `CurrentCountry`, `PreviousCountry`, `DistanceKm`, `SpeedKmh`, `MFAResult`, `ConditionalAccessStatus`

---

### 1.2 KQL Query: Risky Sign-in Enrichment

Correlates impossible travel events from `AADUserRiskEvents` with sign-in log detail to surface MFA bypass, Conditional Access policy failures, and device compliance state.

```kql
// Risky Sign-in Enrichment
// Tables: SigninLogs, AADUserRiskEvents
// Run frequency: Hourly | Look-back: 24h
let RiskyUsers =
    AADUserRiskEvents
    | where TimeGenerated > ago(24h)
    | where RiskLevel in ("high", "medium")
    | where RiskEventType =~ "impossibleTravel"
    | project UserId, RiskLevel, RiskEventType, RiskDetail;
SigninLogs
| where TimeGenerated > ago(24h)
| where ResultType == 0
| extend
    MFAMethod      = tostring(AuthenticationDetails[0].authenticationMethod),
    MFAResult      = tostring(AuthenticationDetails[0].authenticationStepResultDetail),
    CAPolicyName   = tostring(ConditionalAccessPolicies[0].displayName),
    CAPolicyResult = tostring(ConditionalAccessPolicies[0].result),
    DeviceCompliant = tostring(DeviceDetail.isCompliant),
    DeviceManaged  = tostring(DeviceDetail.isManaged),
    OS             = tostring(DeviceDetail.operatingSystem),
    Country        = tostring(LocationDetails.countryOrRegion)
| join kind=inner RiskyUsers on UserId
| project
    TimeGenerated,
    UserPrincipalName,
    IPAddress,
    Country,
    RiskLevel,
    RiskEventType,
    RiskDetail,
    MFAMethod,
    MFAResult,
    CAPolicyName,
    CAPolicyResult,
    DeviceCompliant,
    DeviceManaged,
    OS,
    AppDisplayName,
    ClientAppUsed
| order by TimeGenerated desc
```

**Triage focus:** `CAPolicyResult == "failure"` with `MFAResult != "MFA successfully completed"` is the highest-priority combination — it indicates a sign-in that bypassed both risk-based CA and MFA.

---

### 1.3 KQL Query: Cross-source Device Correlation

Joins sign-in logs with Defender for Endpoint device telemetry (`DeviceInfo`) to detect cases where a device is showing active local telemetry while its associated account signs in from a foreign country — indicating either stolen credentials or session hijacking.

```kql
// Cross-source Device Correlation — Sign-in vs Endpoint Telemetry
// Tables: SigninLogs, DeviceInfo
// Run frequency: Hourly | Look-back: 24h
let ForeignSignins =
    SigninLogs
    | where TimeGenerated > ago(24h)
    | where ResultType == 0
    | extend
        SigninCountry = tostring(LocationDetails.countryOrRegion),
        DeviceId      = tostring(DeviceDetail.deviceId)
    | where SigninCountry != "Australia"
    | where isnotempty(DeviceId)
    | project SigninTime = TimeGenerated, UserPrincipalName, SigninCountry, SigninIP = IPAddress, DeviceId;
DeviceInfo
| where TimeGenerated > ago(24h)
| project
    TelemetryTime = TimeGenerated,
    DeviceId      = AadDeviceId,
    DeviceName,
    OSPlatform,
    PublicIP,
    LoggedOnUsers
| join kind=inner ForeignSignins on DeviceId
| extend TimeDiffMinutes = abs(datetime_diff('minute', SigninTime, TelemetryTime))
| where TimeDiffMinutes <= 60
| project
    SigninTime,
    TelemetryTime,
    TimeDiffMinutes,
    UserPrincipalName,
    SigninCountry,
    SigninIP,
    DeviceName,
    OSPlatform,
    DevicePublicIP = PublicIP,
    LoggedOnUsers,
    FlagReason = "Device active locally while account signed in from foreign country"
| order by SigninTime desc
```

**Interpretation:** A match with `TimeDiffMinutes < 30` is a strong indicator of credential theft — the device is physically elsewhere while an attacker uses the account remotely.

---

## 2. Sentinel Analytics Rule

Scheduled analytics rule that runs the impossible travel detection query hourly and creates a High-severity incident when triggered. Deploy via ARM template using the repository template at `../reference/sentinel/templates/arm/ScheduledRuleARM.json`.

### 2.1 Deployment Parameters

Populate `ScheduledRule.parametersARM.json` with the following values before deploying:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "location": {
      "value": "australiaeast"
    },
    "workspaceName": {
      "value": "ws-prod-sentinel-01"
    },
    "ruleDisplayName": {
      "value": "Impossible Travel with Suspicious Endpoint Activity"
    },
    "ruleDescription": {
      "value": "Detects successful sign-ins for the same user from two geographic locations within 2 hours where the implied travel speed exceeds 900 km/h. Correlated against AADUserRiskEvents for impossible travel risk classification."
    },
    "query": {
      "value": "let ExcludedPrefixes = dynamic([\"10.\", \"172.16.\", \"172.17.\", \"172.18.\", \"192.168.\"]); SigninLogs | where TimeGenerated > ago(2h) | where ResultType == 0 | where not(IPAddress has_any (ExcludedPrefixes)) | where isnotempty(LocationDetails.geoCoordinates.latitude) | extend Lat = toreal(LocationDetails.geoCoordinates.latitude), Lon = toreal(LocationDetails.geoCoordinates.longitude), Country = tostring(LocationDetails.countryOrRegion), City = tostring(LocationDetails.city), MFAMethod = tostring(AuthenticationDetails[0].authenticationMethod), MFAResult = tostring(AuthenticationDetails[0].authenticationStepResultDetail), DeviceId = tostring(DeviceDetail.deviceId) | sort by UserPrincipalName asc, TimeGenerated asc | serialize | extend PrevTime = prev(TimeGenerated, 1), PrevLat = prev(Lat, 1), PrevLon = prev(Lon, 1), PrevCountry = prev(Country, 1), PrevIP = prev(IPAddress, 1), PrevUser = prev(UserPrincipalName, 1) | where UserPrincipalName == PrevUser | extend TimeDiffHours = datetime_diff('minute', TimeGenerated, PrevTime) / 60.0, DistanceKm = geo_distance_2points(PrevLon, PrevLat, Lon, Lat) / 1000.0 | where TimeDiffHours > 0 and TimeDiffHours <= 2 | extend SpeedKmh = DistanceKm / TimeDiffHours | where SpeedKmh > 900 | project TimeGenerated, UserPrincipalName, CurrentIP = IPAddress, CurrentCountry = Country, PreviousIP = PrevIP, PreviousCountry = PrevCountry, DistanceKm = round(DistanceKm, 0), SpeedKmh = round(SpeedKmh, 0), MFAMethod, MFAResult, DeviceId, AppDisplayName, ConditionalAccessStatus"
    },
    "queryFrequency": {
      "value": "PT1H"
    },
    "queryPeriod": {
      "value": "PT2H"
    },
    "severity": {
      "value": "High"
    },
    "suppressionDuration": {
      "value": "PT1H"
    },
    "suppressionEnabled": {
      "value": false
    },
    "tactics": {
      "value": ["InitialAccess", "CredentialAccess", "LateralMovement"]
    },
    "triggerOperator": {
      "value": "GreaterThan"
    },
    "triggerThreshold": {
      "value": 0
    },
    "ruleId": {
      "value": "a3f2c1d4-8e5b-4f7a-9c6d-2b1e4f8a3c7d"
    }
  }
}
```

### 2.2 Entity Mapping

Configure the following entity mappings in the Sentinel analytics rule UI after deployment (or add to the ARM template `entityMappings` property):

| Entity Type | Identifier | Column |
|---|---|---|
| Account | FullName | UserPrincipalName |
| IP | Address | CurrentIP |
| IP | Address | PreviousIP |

### 2.3 Incident Grouping

| Setting | Value |
|---|---|
| Group alerts into incidents | Enabled |
| Group by entity | Account (UserPrincipalName) |
| Grouping window | 5 hours |
| Re-open closed incident | Enabled |

### 2.4 ARM Deployment Command

```powershell
# Deploy analytics rule to Sentinel workspace
az deployment group create `
  --resource-group corp-sentinel-rg `
  --template-file reference/sentinel/templates/arm/ScheduledRuleARM.json `
  --parameters reference/sentinel/templates/arm/ScheduledRule.parametersARM.json `
  --name "impossible-travel-rule-deployment"

# Verify deployment
az security alert list `
  --resource-group corp-sentinel-rg `
  --query "[?contains(name, 'a3f2c1d4')]"
```

---

## 3. Investigation Workflow

Step-by-step triage procedure from initial Sentinel alert through cross-tool evidence collection. Complete each step in order; document findings in the associated ServiceNow ticket.

### 3.1 Initial Alert Triage (Sentinel)

- [ ] Navigate to **Microsoft Sentinel** → **Incidents** → filter by `High` severity and `Status = New`
- [ ] Open the impossible travel incident and review the **Entities** panel — confirm `Account` and `IP` entities are populated
- [ ] Click the `Account` entity → **View full details** → note `UserPrincipalName`, `UserId`, and `AAD ObjectId`
- [ ] Click **Investigate** → open the investigation graph → check for related incidents on the same account in the past 7 days
- [ ] Set incident status to `Active` and assign to yourself before proceeding

### 3.2 Sign-in Log Analysis (Entra ID)

- [ ] Navigate to **Microsoft Entra ID** → **Monitoring** → **Sign-in logs**
- [ ] Filter: `User = <UserPrincipalName>`, `Date = Last 24 hours`, `Status = Success`
- [ ] Sort by **Date** ascending — identify the two sign-ins that triggered the impossible travel calculation
- [ ] For each sign-in, record:

| Field | Sign-in 1 | Sign-in 2 |
|---|---|---|
| Time (UTC) | | |
| IP Address | | |
| Country / City | | |
| Application | | |
| MFA Method | | |
| MFA Result | | |
| CA Policy Applied | | |
| CA Policy Result | | |
| Device (if joined) | | |

- [ ] Export sign-in logs for both events: **Download** → CSV
- [ ] Check **Risky sign-ins** tab — confirm whether Identity Protection raised an `ImpossibleTravel` risk event

### 3.3 IP Reputation Check

For each source IP from Section 3.2:

- [ ] **Microsoft Defender Threat Intelligence (MDTI):** Navigate to [security.microsoft.com](https://security.microsoft.com) → **Threat intelligence** → **Intel explorer** → search IP
  - Record: Reputation score, associated threat actors, hosting provider, ASN
- [ ] **VirusTotal:** Search IP — note malicious / suspicious vendor detections
- [ ] **AbuseIPDB:** Note abuse confidence score and report history
- [ ] Document whether the IP matches known VPN/proxy infrastructure (common in legitimate travel scenarios vs. attacker use)

**Decision point:** If IP 2 (the foreign sign-in) resolves to a residential ISP with no threat intelligence hits, this may be a genuine travel event. If it resolves to a cloud provider, hosting company, or known proxy service, treat as high-probability compromise.

### 3.4 Device Compliance Check (Intune)

- [ ] Navigate to **Microsoft Intune admin center** → **Devices** → **All devices**
- [ ] Search for the device name from the sign-in log `DeviceDetail.displayName` field
- [ ] Record device compliance state, last check-in time, and OS version
- [ ] Confirm whether the device is **Hybrid Azure AD joined**, **Azure AD registered**, or **unregistered**
- [ ] If device is unregistered on the suspicious sign-in, it is not a managed corporate device — escalate containment priority

```powershell
# Check device compliance state via Microsoft Graph
Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"

$DeviceName = "CORP-LT-0421"
Get-MgDeviceManagementManagedDevice -Filter "deviceName eq '$DeviceName'" |
    Select-Object DeviceName, ComplianceState, LastSyncDateTime, OperatingSystem,
                  ManagementAgent, AzureAdRegistered, EnrolledDateTime
```

### 3.5 CrowdStrike Falcon — Host Pivot

- [ ] Navigate to **CrowdStrike Falcon** → **Investigate** → **Event Search**
- [ ] Search for the device name or hostname from the sign-in log
- [ ] Record: sensor version, last seen time, containment status, assigned policy group
- [ ] Navigate to **Investigate** → **Host Timeline** → enter hostname → set time window to ±2 hours around each suspicious sign-in time
- [ ] Review timeline for: new process executions, network connections to foreign IPs, credential access events, persistence mechanisms (scheduled tasks, registry run keys)
- [ ] Flag any processes spawned by `lsass.exe`, `winlogon.exe`, or Office applications during the window

---

## 4. CrowdStrike Falcon Queries

FQL queries for Falcon Event Search. Set the time range to cover the sign-in window (±2 hours) and filter by the affected hostname.

### 4.1 Process Activity at Sign-in Time

Captures all process executions on the endpoint during the suspicious sign-in window. Use to identify post-exploitation tooling or lateral movement preparation.

```
event_simpleName=ProcessRollup2
+ ComputerName=CORP-LT-0421
+ event_platform=Win
```

**Refine if needed — flag high-risk process names:**

```
event_simpleName=ProcessRollup2
+ ComputerName=CORP-LT-0421
+ FileName IN (mimikatz.exe, procdump.exe, psexec.exe, wce.exe, sharphound.exe, bloodhound.exe, cobalt_strike.exe, meterpreter.exe, rubeus.exe, secretsdump.py)
```

### 4.2 Network Connections

Outbound network connections from the device during the window. Identifies C2 beaconing, data exfiltration, or lateral movement via SMB/RDP.

```
event_simpleName=NetworkConnectIP4
+ ComputerName=CORP-LT-0421
```

**Filter for external connections only (exclude RFC 1918):**

```
event_simpleName=NetworkConnectIP4
+ ComputerName=CORP-LT-0421
+ RemoteAddressIP4!=10.*
+ RemoteAddressIP4!=172.16.*
+ RemoteAddressIP4!=192.168.*
```

### 4.3 Credential Access Indicators

Detects attempts to read LSASS memory or load credential harvesting modules — the most common post-exploitation step after an account compromise provides initial access.

```
event_simpleName IN (LsassCallerAudit, SuspiciousCredentialModuleLoad)
+ ComputerName=CORP-LT-0421
```

**LSASS read by non-system process:**

```
event_simpleName=LsassCallerAudit
+ ComputerName=CORP-LT-0421
+ GrantedAccess_decimal>=16
```

### 4.4 Persistence Mechanisms

Scheduled task creation and registry run key writes — common persistence techniques used immediately after initial access.

```
event_simpleName IN (ScheduledTask, RegGenericValueUpdate)
+ ComputerName=CORP-LT-0421
+ (FileName=schtasks.exe OR TargetObject=*\\CurrentVersion\\Run*)
```

### 4.5 Host Timeline — UI Steps

1. In Falcon console, navigate to **Investigate** → **Host Timeline**
2. Enter hostname: `CORP-LT-0421`
3. Set **Start** to 1 hour before the earliest suspicious sign-in time
4. Set **End** to 1 hour after the latest suspicious sign-in time
5. Filter event types: `Process`, `Network`, `User Activity`, `Detections`
6. Export timeline as CSV for case record: **Actions** → **Export**
7. Note any CrowdStrike detections raised during the window — these appear with a shield icon and detection severity rating

### 4.6 Findings Documentation

Record findings from CrowdStrike in the following format before proceeding to response actions:

| Check | Finding | Severity |
|---|---|---|
| Process activity at sign-in time | | |
| External network connections | | |
| LSASS/credential access | | |
| Persistence mechanisms detected | | |
| Active CrowdStrike detections | | |
| Device last seen time vs sign-in time | | |

---

## 5. Response Actions

Containment and remediation steps. Execute in order — account containment first, then Conditional Access enforcement, then device isolation if endpoint compromise is confirmed.

### 5.1 Revoke Active Sessions and Disable Account

Immediately invalidates all active refresh tokens and optionally disables the account pending investigation.

```powershell
# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All"

# Set target user
$UserUPN = "j.smith@corp.onmicrosoft.com"

# Step 1: Revoke all refresh tokens (forces re-authentication on all sessions)
Invoke-MgInvalidateUserRefreshToken -UserId $UserUPN
Write-Host "[+] Refresh tokens revoked for $UserUPN"

# Step 2: Confirm revocation timestamp
$User = Get-MgUser -UserId $UserUPN -Property "DisplayName,SignInSessionsValidFromDateTime,AccountEnabled"
Write-Host "[+] Sessions valid from: $($User.SignInSessionsValidFromDateTime)"

# Step 3: Disable account (if compromise confirmed or pending further review)
Update-MgUser -UserId $UserUPN -AccountEnabled:$false
Write-Host "[+] Account disabled: $UserUPN"

# Step 4: Confirm account state
Get-MgUser -UserId $UserUPN -Property "DisplayName,AccountEnabled,SignInSessionsValidFromDateTime" |
    Select-Object DisplayName, AccountEnabled, SignInSessionsValidFromDateTime
```

**Note:** Token revocation takes effect within 60–90 seconds. The user will be signed out of all active sessions including Exchange Online, SharePoint, and Teams.

### 5.2 Block Sign-in from Suspicious Country via Conditional Access

Creates a named location for the attacker's country and applies a Conditional Access policy to block sign-ins from it for the affected user.

```powershell
Connect-MgGraph -Scopes "Policy.ReadWrite.ConditionalAccess", "Policy.Read.All"

# Step 1: Create a named location for the suspicious country
$CountryCode = "RU"  # Replace with the attacker's country ISO code from Section 3.2
$LocationParams = @{
    "@odata.type" = "#microsoft.graph.countryNamedLocation"
    DisplayName   = "BLOCKED-Suspicious-Country-IR-$(Get-Date -Format 'yyyyMMdd')"
    CountriesAndRegions = @($CountryCode)
    IncludeUnknownCountriesAndRegions = $false
}
$NamedLocation = New-MgIdentityConditionalAccessNamedLocation -BodyParameter $LocationParams
Write-Host "[+] Named location created: $($NamedLocation.Id)"

# Step 2: Create a Conditional Access policy blocking the location for the affected user
$CAParams = @{
    DisplayName = "IR-BLOCK-Impossible-Travel-$(Get-Date -Format 'yyyyMMdd')"
    State       = "enabled"
    Conditions  = @{
        Users = @{
            IncludeUsers = @("j.smith@corp.onmicrosoft.com")
        }
        Locations = @{
            IncludeLocations = @($NamedLocation.Id)
        }
    }
    GrantControls = @{
        Operator          = "OR"
        BuiltInControls   = @("block")
    }
}
New-MgIdentityConditionalAccessPolicy -BodyParameter $CAParams
Write-Host "[+] Conditional Access block policy created"

# Step 3: List active CA policies to confirm
Get-MgIdentityConditionalAccessPolicy |
    Where-Object { $_.DisplayName -like "IR-BLOCK*" } |
    Select-Object Id, DisplayName, State
```

### 5.3 Export Audit Evidence

Export sign-in and audit logs for the affected user to support case documentation and potential legal/HR escalation.

```powershell
Connect-ExchangeOnline

# Export unified audit log for the affected user — last 7 days
$StartDate = (Get-Date).AddDays(-7).ToString("MM/dd/yyyy")
$EndDate   = (Get-Date).ToString("MM/dd/yyyy")
$OutputPath = "C:\IR\evidence\j.smith-auditlog-$(Get-Date -Format 'yyyyMMdd').csv"

Search-UnifiedAuditLog `
    -StartDate $StartDate `
    -EndDate   $EndDate `
    -UserIds   "j.smith@corp.onmicrosoft.com" `
    -ResultSize 5000 |
    Export-Csv -Path $OutputPath -NoTypeInformation

Write-Host "[+] Audit log exported to $OutputPath"
```

### 5.4 Response Action Checklist

- [ ] Refresh tokens revoked — confirmed via `SignInSessionsValidFromDateTime`
- [ ] Account disabled (if compromise confirmed)
- [ ] Named location created for attacker IP country
- [ ] Conditional Access block policy applied and set to `Enabled`
- [ ] Audit log exported and saved to case folder
- [ ] ServiceNow ticket updated with containment actions and timestamps
- [ ] User's manager and security team notified

---

## 6. Automation — Logic App Workflow

Azure Logic App triggered by a Sentinel incident creation event. Automatically sends a Teams alert, optionally disables the affected user account, and creates a ServiceNow incident — reducing mean time to respond for high-severity impossible travel events.

### 6.1 Logic App Overview

| Component | Value |
|---|---|
| Trigger | Microsoft Sentinel — When a response to a Microsoft Sentinel alert is triggered |
| Condition | Incident severity == `High` |
| Action 1 | Post adaptive card to Security Operations Teams channel |
| Action 2 (conditional) | Disable user account via Microsoft Graph API |
| Action 3 | Create ServiceNow incident via REST API |

### 6.2 Logic App ARM Deployment JSON

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": [
    {
      "type": "Microsoft.Logic/workflows",
      "apiVersion": "2019-05-01",
      "name": "impossible-travel-response-automation",
      "location": "australiaeast",
      "identity": {
        "type": "SystemAssigned"
      },
      "properties": {
        "state": "Enabled",
        "definition": {
          "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
          "contentVersion": "1.0.0.0",
          "triggers": {
            "Microsoft_Sentinel_incident": {
              "type": "ApiConnectionWebhook",
              "inputs": {
                "host": {
                  "connection": {
                    "name": "@parameters('$connections')['azuresentinel']['connectionId']"
                  }
                },
                "body": {
                  "callback_url": "@{listCallbackUrl()}"
                },
                "path": "/incident-creation"
              }
            }
          },
          "actions": {
            "Parse_Incident_Entities": {
              "type": "ParseJson",
              "inputs": {
                "content": "@triggerBody()?['object']?['properties']?['relatedEntities']",
                "schema": {
                  "type": "array",
                  "items": {
                    "type": "object",
                    "properties": {
                      "kind": { "type": "string" },
                      "properties": {
                        "type": "object",
                        "properties": {
                          "friendlyName": { "type": "string" },
                          "upnSuffix": { "type": "string" },
                          "address": { "type": "string" }
                        }
                      }
                    }
                  }
                }
              },
              "runAfter": {}
            },
            "Post_Teams_Alert": {
              "type": "ApiConnection",
              "inputs": {
                "host": {
                  "connection": {
                    "name": "@parameters('$connections')['teams']['connectionId']"
                  }
                },
                "method": "post",
                "path": "/v3/beta/teams/@{encodeURIComponent('security-ops-channel-id')}/channels/@{encodeURIComponent('19:channel-id@thread.tacv2')}/messages",
                "body": {
                  "messageType": "message",
                  "body": {
                    "contentType": "html",
                    "content": "<b>HIGH SEVERITY -- Impossible Travel Detected</b><br><b>Incident:</b> @{triggerBody()?['object']?['properties']?['incidentNumber']}<br><b>User:</b> @{triggerBody()?['object']?['properties']?['relatedEntities']?[0]?['properties']?['friendlyName']}<br><b>Severity:</b> @{triggerBody()?['object']?['properties']?['severity']}<br><b>Time:</b> @{triggerBody()?['object']?['properties']?['createdTimeUtc']}<br><b>Sentinel Link:</b> @{triggerBody()?['object']?['properties']?['incidentUrl']}"
                  }
                }
              },
              "runAfter": {
                "Parse_Incident_Entities": ["Succeeded"]
              }
            },
            "Check_High_Severity": {
              "type": "If",
              "expression": {
                "and": [
                  {
                    "equals": [
                      "@triggerBody()?['object']?['properties']?['severity']",
                      "High"
                    ]
                  }
                ]
              },
              "actions": {
                "Disable_User_Account": {
                  "type": "Http",
                  "inputs": {
                    "method": "PATCH",
                    "uri": "https://graph.microsoft.com/v1.0/users/@{triggerBody()?['object']?['properties']?['relatedEntities']?[0]?['properties']?['friendlyName']}",
                    "headers": {
                      "Content-Type": "application/json"
                    },
                    "body": {
                      "accountEnabled": false
                    },
                    "authentication": {
                      "type": "ManagedServiceIdentity",
                      "audience": "https://graph.microsoft.com"
                    }
                  }
                }
              },
              "else": {
                "actions": {}
              },
              "runAfter": {
                "Post_Teams_Alert": ["Succeeded"]
              }
            },
            "Create_ServiceNow_Incident": {
              "type": "Http",
              "inputs": {
                "method": "POST",
                "uri": "https://corp.service-now.com/api/now/table/incident",
                "headers": {
                  "Content-Type": "application/json",
                  "Accept": "application/json"
                },
                "body": {
                  "short_description": "Security Incident -- Impossible Travel: @{triggerBody()?['object']?['properties']?['relatedEntities']?[0]?['properties']?['friendlyName']}",
                  "description": "Sentinel Incident #@{triggerBody()?['object']?['properties']?['incidentNumber']} -- Impossible travel detected. Severity: @{triggerBody()?['object']?['properties']?['severity']}. Automated response initiated via Logic App. Refer to Sentinel for investigation details.",
                  "urgency": "1",
                  "impact": "1",
                  "category": "Security",
                  "assignment_group": "Security Operations"
                },
                "authentication": {
                  "type": "Basic",
                  "username": "@parameters('serviceNowUsername')",
                  "password": "@parameters('serviceNowPassword')"
                }
              },
              "runAfter": {
                "Check_High_Severity": ["Succeeded", "Skipped"]
              }
            }
          }
        },
        "parameters": {
          "$connections": {
            "value": {
              "azuresentinel": {
                "connectionId": "/subscriptions/<subscription-id>/resourceGroups/corp-sentinel-rg/providers/Microsoft.Web/connections/azuresentinel",
                "connectionName": "azuresentinel",
                "id": "/subscriptions/<subscription-id>/providers/Microsoft.Web/locations/australiaeast/managedApis/azuresentinel"
              },
              "teams": {
                "connectionId": "/subscriptions/<subscription-id>/resourceGroups/corp-sentinel-rg/providers/Microsoft.Web/connections/teams",
                "connectionName": "teams",
                "id": "/subscriptions/<subscription-id>/providers/Microsoft.Web/locations/australiaeast/managedApis/teams"
              }
            }
          }
        }
      }
    }
  ]
}
```

### 6.3 Required Permissions

After deploying the Logic App, grant the system-assigned managed identity the following permissions:

| Permission | Scope | Purpose |
|---|---|---|
| `User.ReadWrite.All` | Microsoft Graph | Disable user account in Entra ID |
| `Microsoft Sentinel Responder` | `corp-sentinel-rg` | Trigger and update Sentinel incidents |

```powershell
# Grant User.ReadWrite.All to Logic App managed identity
$LogicAppObjectId = "<logic-app-managed-identity-object-id>"
$GraphAppId = "00000003-0000-0000-c000-000000000002"

Connect-MgGraph -Scopes "AppRoleAssignment.ReadWrite.All", "Application.Read.All"

$GraphSP = Get-MgServicePrincipal -Filter "appId eq '$GraphAppId'"
$AppRole  = $GraphSP.AppRoles | Where-Object { $_.Value -eq "User.ReadWrite.All" }

New-MgServicePrincipalAppRoleAssignment `
    -ServicePrincipalId $LogicAppObjectId `
    -PrincipalId        $LogicAppObjectId `
    -ResourceId         $GraphSP.Id `
    -AppRoleId          $AppRole.Id

Write-Host "[+] User.ReadWrite.All granted to Logic App managed identity"
```

---

## 7. Validation

Safe simulation steps to verify the full detection-to-response pipeline before a real incident occurs. Requires two accounts with VPN access to endpoints in different countries.

### 7.1 Simulation Prerequisites

- Two VPN endpoints in geographically distant countries (e.g., a local Australian endpoint and a European or US endpoint)
- A test user account in `corp.onmicrosoft.com` with Sentinel analytics rule and Logic App enabled
- Sentinel workspace with `SigninLogs` and `AADUserRiskEvents` connected
- Logic App deployed and Teams webhook configured (use a test channel, not the live SOC channel)

### 7.2 Simulation Steps

1. Sign in to the test account from the local VPN endpoint (Country A) — record the exact time
2. Wait 5 minutes
3. Switch VPN to the foreign endpoint (Country B) and sign in again with the same account — record the exact time
4. Wait up to 60 minutes for Sentinel's hourly analytics rule run

### 7.3 Expected Results

| Component | Expected Outcome | Verification Method |
|---|---|---|
| Entra ID risk detection | `ImpossibleTravel` risk event raised (High or Medium) | Entra ID → Identity Protection → Risky sign-ins |
| Sentinel alert fired | Incident created with severity `High` | Sentinel → Incidents → filter last 24h |
| Incident entities populated | Account (UPN) + IP entities present | Sentinel incident → Entities panel |
| Teams notification sent | Adaptive card posted to test channel | Check Teams channel within 2 minutes of incident creation |
| Logic App user disable (if High) | Account shows `AccountEnabled: false` | `Get-MgUser -UserId <UPN>` |
| ServiceNow ticket created | Incident in `New` state, assigned to Security Operations | ServiceNow → Incidents → filter by `Security` category |

### 7.4 Post-Simulation Cleanup

```powershell
# Re-enable test account after simulation
Connect-MgGraph -Scopes "User.ReadWrite.All"
Update-MgUser -UserId "test-user@corp.onmicrosoft.com" -AccountEnabled:$true

# Re-enable sign-in sessions
Invoke-MgInvalidateUserRefreshToken -UserId "test-user@corp.onmicrosoft.com"
Write-Host "[+] Test account restored"

# Remove the IR block CA policy created during simulation
$PolicyId = (Get-MgIdentityConditionalAccessPolicy |
    Where-Object { $_.DisplayName -like "IR-BLOCK*" }).Id
Remove-MgIdentityConditionalAccessPolicy -ConditionalAccessPolicyId $PolicyId
Write-Host "[+] IR block CA policy removed"
```

---

## 8. Troubleshooting

Common issues encountered when deploying or running this pipeline, with root causes and fixes.

| Problem | Root Cause | Fix |
|---|---|---|
| No `SigninLogs` data in Sentinel | Entra ID diagnostic settings not forwarding to Log Analytics | Entra ID → Monitoring → Diagnostic settings → Add diagnostic setting → enable `SignInLogs` → send to `ws-prod-sentinel-01` |
| `AADUserRiskEvents` table empty | Entra ID P2 licence not assigned or risk events not forwarded | Assign Entra ID P2 (Microsoft 365 E5 includes this); enable `RiskyUsers` and `UserRiskEvents` in diagnostic settings |
| `geo_distance_2points()` returns null | `LocationDetails.geoCoordinates.latitude` or `.longitude` is null for some sign-ins | Add `| where isnotempty(LocationDetails.geoCoordinates.latitude)` before the `extend` — already included in KQL 1.1 |
| No device records in `DeviceInfo` join | Device is not enrolled in Defender for Endpoint / Intune, or `AadDeviceId` does not match `DeviceDetail.deviceId` in SigninLogs | Verify device is hybrid joined and Defender for Endpoint sensor is active; check both `DeviceDetail.deviceId` and `DeviceDetail.displayName` as join keys |
| Analytics rule never fires | `queryFrequency` too long or `triggerThreshold` set too high | Confirm `queryFrequency` is `PT1H` and `triggerThreshold` is `0` (fire on any result); run the KQL manually in Log Analytics to confirm it returns rows |
| Logic App fails at Teams step | API connection not authorized or Teams connection expired | In Azure Portal → Logic App → API connections → teams → authorize with a service account that has Teams channel write access |
| Logic App fails at Graph API disable step | Managed identity missing `User.ReadWrite.All` app role | Re-run the PowerShell in Section 6.3 to grant the app role assignment; wait 5–10 minutes for propagation |
| ServiceNow ticket not created | ServiceNow URL, credentials, or table name incorrect | Test the REST API call directly: `Invoke-RestMethod -Uri https://corp.service-now.com/api/now/table/incident -Method GET -Credential $cred` |
| `Invoke-MgInvalidateUserRefreshToken` returns 404 | `UserId` is the UPN but the user object cannot be found | Use `Get-MgUser -UserId <UPN>` first to confirm the user exists; some tenants require the `ObjectId` (GUID) instead of UPN |
| CrowdStrike device not found in Event Search | Sensor hostname doesn't match Intune `DeviceName` (case mismatch or FQDN vs NetBIOS) | Search CrowdStrike by partial hostname using `ComputerName=CORP-LT*`; cross-reference by device serial or MAC address |

---

## 9. Executive Summary

### What Is Impossible Travel?

An impossible travel alert fires when a user account produces two successful sign-ins within a short time window from geographic locations that are physically impossible to travel between in that time — for example, signing in from Sydney at 09:00 and from Moscow at 10:15.

This is a high-fidelity indicator of account compromise. It means someone other than the legitimate user is using the account, either because credentials were stolen (through phishing, data breach, or credential stuffing) or because an active session was hijacked.

### Business Risk

An account compromise that bypasses detection and response enables an attacker to:

- **Read and exfiltrate sensitive data** from SharePoint, OneDrive, and Exchange — including financial records, contracts, HR data, and intellectual property
- **Escalate privilege** — particularly dangerous if the compromised account has admin rights or can approve expense claims, wire transfers, or IT access requests
- **Launch business email compromise (BEC)** — impersonate the user to redirect payments or deceive partners and customers
- **Establish persistence** — create backdoor accounts, OAuth applications, or forwarding rules that survive a password reset

The average cost of a data breach involving stolen credentials is $4.5M USD (IBM Cost of a Data Breach 2024), with a mean time to identify of 292 days where automated detection is absent.

### How This Pipeline Protects the Organisation

This pipeline provides automated, layered detection and response that operates around the clock without manual SOC intervention for initial containment:

1. **Detection fires within 60 minutes** of the impossible travel event occurring — the Sentinel analytics rule runs hourly
2. **Teams alert reaches the SOC immediately** via Logic App — no manual log checking required
3. **High-severity events trigger automatic account containment** — the compromised account is disabled and all sessions are revoked before an analyst needs to act
4. **A ServiceNow ticket is automatically created** with full incident context, ensuring no alert falls through the cracks and every response action is traceable

### Compliance Alignment

| Framework | Control | How This Pipeline Addresses It |
|---|---|---|
| ISO 27001:2022 | A.5.24 — Information security incident management planning | Documented end-to-end pipeline covering detection, response, and post-incident review |
| ISO 27001:2022 | A.5.25 — Assessment and decision on information security events | KQL queries and investigation workflow provide structured triage criteria |
| ISO 27001:2022 | A.5.26 — Response to information security incidents | Automated containment via Logic App; manual response actions in Section 5 |
| ISO 27001:2022 | A.5.27 — Learning from information security incidents | Post-incident validation steps (Section 7) and troubleshooting log (Section 8) |
| ISO 27001:2022 | A.8.16 — Monitoring activities | Sentinel analytics rule provides continuous monitoring of sign-in activity |
| ASD Essential Eight | MFA — Maturity Level 3 | Conditional Access policy enforcement on risky sign-ins; MFA result captured in KQL |
| NIST SP 800-53 | IA-2 — Identification and Authentication | Impossible travel detection directly addresses multi-factor authentication bypass attempts |
| NIST SP 800-53 | IR-4 — Incident Handling | Structured detection-to-containment lifecycle with automation |
