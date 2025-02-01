﻿# PowerShell Script: Failed Login Analysis with IP Reputation Check
# Author: Ryan Emerson
# Description: Extracts failed login attempts from Windows Event Logs or a CSV file and checks IP reputation via AbuseIPDB.

param (
    [string]$outputPath = "$env:USERPROFILE\Documents\FailedLogins.csv",
    [switch]$useCsv,  # Option to use a CSV instead of Windows Event Log
    [string]$csvPath = "$env:USERPROFILE\Documents\AuthWatch_FakeLogins.csv",
    [switch]$emailAlert,
    [string]$emailRecipient = "admin@company.com"
)

# Enter your AbuseIPDB API key here
$AbuseIPDB_API_Key = "9e8420481b2920462f98f9e3a84323eb66998ad38494cc26a34a6184554763bdf80f2eeb1736403c"

# Function to check IP reputation using AbuseIPDB
function getIPReputation($ip) {
    if ([string]::IsNullOrWhiteSpace($ip) -or $ip -eq "-" -or $ip -eq "N/A") {
        return "N/A"
    }

    # Validate IP format
    if ($ip -notmatch "^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$") {
        return "Invalid IP"
    }

    $url = "https://api.abuseipdb.com/api/v2/check?ipAddress=$ip&maxAgeInDays=90"
    $headers = @{
        "Key" = $AbuseIPDB_API_Key
        "Accept" = "application/json"
    }

    try {
        $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get
        return $response.data.abuseConfidenceScore  # Score between 0-100
    }
    catch {
        Write-Host "Failed to retrieve IP reputation for $ip" -ForegroundColor Yellow
        return "Error"
    }
}

# Function to send email alerts (Placeholder: Needs SMTP setup)
function sendAlertEmail($logData) {
    Write-Host "Email alert feature is not implemented yet."
}

# Function to pause script execution
function pauseScript {
    Write-Host "`nPress Enter to continue..." -ForegroundColor Yellow
    Read-Host | Out-Null
}

# Clear the screen for better visibility
Clear-Host
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "     Failed Login Analysis Script Started" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Start Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n" -ForegroundColor Gray

# Decide whether to use CSV or Windows Event Log
$logData = @()

if ($useCsv) {
    # Load fake log data from CSV
    if (-not (Test-Path $csvPath)) {
        Write-Host "Error: Test log file not found. Run the fake log generator script first." -ForegroundColor Red
        exit
    }
    Write-Host "Loading fake log data from CSV..." -ForegroundColor Green
    $logData = Import-Csv -Path $csvPath
} else {
    # Retrieve logs from Windows Event Viewer
    Write-Host "Retrieving failed login attempts from Windows Event Logs..." -ForegroundColor Green
    try {
        $eventId = 4625  # Failed logon event ID
        $securityEvents = Get-WinEvent -LogName Security -FilterXPath "*[System[(EventID=$eventId)]]" -MaxEvents 50 -ErrorAction Stop

        $logData = $securityEvents | ForEach-Object {
            $sourceIp = $_.Properties[18].Value  # Extract Source IP

            # Ensure the IP is valid before checking reputation
            if ($sourceIp -match "^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$") {
                $ipReputation = getIPReputation $sourceIp
            } else {
                $ipReputation = "N/A"
            }

            [PSCustomObject]@{
                TimeGenerated = $_.TimeCreated
                UserName = $_.Properties[5].Value
                SourceIP = $sourceIp
                LogonType = switch ($_.Properties[10].Value) {
                    2 { "Interactive" }
                    3 { "Network" }
                    4 { "Batch" }
                    5 { "Service" }
                    7 { "Unlock" }
                    8 { "NetworkCleartext" }
                    9 { "NewCredentials" }
                    10 { "RemoteInteractive" }
                    11 { "CachedInteractive" }
                    default { "Unknown" }
                }
                FailureReason = "Failed Logon"
                ProcessName = $_.Properties[17].Value
                WorkstationName = $_.Properties[13].Value
                TargetDomain = $_.Properties[6].Value
                IPReputationScore = $ipReputation
            }
        }
    }
    catch {
        Write-Host "No Windows Event Logs found or insufficient permissions." -ForegroundColor Yellow
        Write-Host "Switching to CSV mode instead..." -ForegroundColor Cyan
        $useCsv = $true
    }
}

# If Event Log retrieval failed, fall back to CSV
if ($useCsv -and $logData.Count -eq 0) {
    if (-not (Test-Path $csvPath)) {
        Write-Host "Error: No event logs and CSV file not found. Exiting..." -ForegroundColor Red
        exit
    }
    Write-Host "Loading fake log data from CSV..." -ForegroundColor Green
    $logData = Import-Csv -Path $csvPath
}

# Process each log entry
$processedLogs = @()  # Ensure processed logs are stored
foreach ($entry in $logData) {
    $sourceIp = $entry.SourceIP  # Extract Source IP

    # Ensure the IP is valid before checking reputation
    if ($sourceIp -match "^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$") {
        $ipReputation = getIPReputation $sourceIp
    } else {
        $ipReputation = "N/A"
    }

    $processedLogs += [PSCustomObject]@{
        TimeGenerated = $entry.TimeGenerated
        UserName = $entry.UserName
        SourceIP = $sourceIp
        LogonType = $entry.LogonType
        FailureReason = $entry.FailureReason
        ProcessName = $entry.ProcessName
        WorkstationName = $entry.WorkstationName
        TargetDomain = $entry.TargetDomain
        IPReputationScore = $ipReputation
    }
}

Write-Host "Complete" -ForegroundColor Green

# Export results if we have data
if ($processedLogs.Count -gt 0) {
    $timeStamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $outputPath = $outputPath -replace '\.csv$', "_${timeStamp}.csv"

    Write-Host "Exporting data to CSV..." -NoNewline
    $processedLogs | Export-Csv -Path $outputPath -NoTypeInformation
    Write-Host "Success" -ForegroundColor Green

    # Summary report
    Write-Host "`n==================================================" -ForegroundColor Green
    Write-Host "                 SUMMARY REPORT" -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Green
    Write-Host "Results saved to: $outputPath"

    # Send email alert if configured
    sendAlertEmail $processedLogs
}

Write-Host "`nScript execution completed successfully!" -ForegroundColor Green

pauseScript
