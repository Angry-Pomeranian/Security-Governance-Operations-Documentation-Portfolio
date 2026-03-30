# Kali Linux WSL Installation and Execution Detection

## Description

Detects installation or execution of the Kali Linux WSL distribution by monitoring WSL-related processes that contain Kali-specific command-line arguments.

## Query

```kql
DeviceProcessEvents
| where FileName in ("wsl.exe","wslhost.exe","wslservice.exe","kali.exe")
| where ProcessCommandLine has_any (dynamic(["kali", "kali-linux"]))
| project Timestamp, DeviceName, InitiatingProcessAccountName, FileName, ProcessCommandLine
| order by Timestamp desc
```

## Entity Mapping

### Host

* **HostName** → `DeviceName`

### Account

* **Name** → `InitiatingProcessAccountName`

### Process

* **ProcessName** → `FileName`
* **CommandLine** → `ProcessCommandLine`

## MITRE ATT&CK Techniques

| Technique ID | Technique Name                    |
| ------------ | --------------------------------- |
| T1059        | Command and Scripting Interpreter |
| T1059.004    | Unix Shell                        |
| T1202        | Indirect Command Execution        |
| T1547        | Boot or Logon Autostart Execution |
| T1546        | Event Triggered Execution         |
| T1204        | User Execution                    |
| T0863        | User Execution (ICS)              |
| T0871        | Execution Through API (ICS)       |
| T1624        | Event Triggered Execution (ICS)   |

---

Should look like this when one:



<img width="306" height="720" alt="image" src="https://github.com/user-attachments/assets/ff873c99-f9d9-4751-bba2-5cf264523bd0" />
