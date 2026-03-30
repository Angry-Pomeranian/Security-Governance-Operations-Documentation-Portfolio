<#
.SYNOPSIS
    Validates Intune Config Refresh status (no admin required)

.DESCRIPTION
    Checks:
      • EnterpriseMgmt scheduled tasks
      • Config Refresh registry values
      • Confirms status directly in terminal
#>

Write-Host "`n=== Step 1: EnterpriseMgmt Scheduled Tasks ===`n" -ForegroundColor Cyan
$tasks = Get-ScheduledTask | Where-Object { $_.TaskPath -like "\Microsoft\Windows\EnterpriseMgmt*" } |
         Select-Object TaskPath, TaskName, State
if ($tasks) { $tasks | Format-Table -AutoSize }
else        { Write-Host "No EnterpriseMgmt tasks found." -ForegroundColor Yellow }

# Step 2 – Registry check
Write-Host "`n=== Step 2: Config Refresh Registry State ===`n" -ForegroundColor Cyan
$EnrollmentId = "11E94EC7-5CF6-470A-A516-7BAF499BE9AE"
$Path = "HKLM:\SOFTWARE\Microsoft\Enrollments\$EnrollmentId\ConfigRefresh"

if (Test-Path $Path) {
    $values  = Get-ItemProperty -Path $Path | Select-Object Enabled, Cadence
    $enabled = $values.Enabled
    $cadence = $values.Cadence
    Write-Host "✅ ConfigRefresh key exists for active enrollment:`n$Path`n" -ForegroundColor Green
    Write-Host "Enabled : $enabled"
    Write-Host "Cadence : $cadence"
    if ($enabled -eq 1 -and $cadence -ge 1) {
        Write-Host "`n✅ Config Refresh is active and healthy. Drift Control will run automatically every $cadence minutes." -ForegroundColor Green
    } else {
        Write-Host "`n⚠️ Config Refresh key found but values are not in expected state. Check Intune policy deployment." -ForegroundColor Yellow
    }
} else {
    Write-Host "⌛ ConfigRefresh key not yet present — waiting for next MDM refresh." -ForegroundColor Yellow
}

Write-Host "`n=== Validation Complete ===`n" -ForegroundColor Cyan
