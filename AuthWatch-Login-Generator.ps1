# AuthWatch Fake Login Generator
# Generates a CSV file with simulated authentication logs, including attack scenarios

param (
    [int]$logCount = 100, # Total number of logs to generate
    [string]$outputPath = "$env:USERPROFILE\Documents\AuthWatch_Fake.csv"
)

# Sample usernames, IPs, and failure reasons
$users = @("admin", "testuser", "jsmith", "backup", "security", "root", "sysadmin", "sysacct")
$attackIPs = @("14.103.133.101", "164.77.216.194", "185.42.12.240", "36.93.237.218", "103.55.191.76", "152.42.214.250", "218.92.0.219") # Known malicious IPs
$failureReasons = @("Invalid credentials", "Account locked out", "Account disabled", "Expired password", "Unknown failure")

# Logon Types (Windows Event Log)
$logonTypes = @{
    "2" = "Interactive"  # Local login
    "3" = "Network"  # SMB, file share, etc.
    "5" = "Service"  # Service account logins
    "10" = "RemoteInteractive"  # RDP login attempt
    "11" = "CachedInteractive"  # Cached domain credentials
}

# Attack Pattern Distribution
$bruteForceAttempts = 10   # Number of brute force logs
$passwordSprayAttempts = 5  # Number of password spraying attempts
$rdpAttackAttempts = 5      # Number of RDP attacks

# Generate fake logs
$fakeLogs = @()

# Generate Normal Failed Logins
for ($i = 1; $i -le ($logCount - $bruteForceAttempts - $passwordSprayAttempts - $rdpAttackAttempts); $i++) {
    $randomUser = $users | Get-Random
    $randomIP = "192.168.1." + (Get-Random -Minimum 1 -Maximum 255)  # Internal LAN IP
    $randomFailure = $failureReasons | Get-Random
    $randomLogonType = $logonTypes.Keys | Get-Random

    $fakeLogs += [PSCustomObject]@{
        TimeGenerated = (Get-Date).AddMinutes(-($i * 5))  # Spread out over time
        UserName = $randomUser
        SourceIP = $randomIP
        LogonType = $logonTypes[$randomLogonType]
        FailureReason = $randomFailure
        ProcessName = "WinLogon.exe"
        WorkstationName = "WORKSTATION-$i"
        TargetDomain = "TESTDOMAIN"
    }
}

# Simulate Brute Force Attack (Repeated failed logins from one attacker IP)
$bruteForceIP = $attackIPs | Get-Random
for ($i = 1; $i -le $bruteForceAttempts; $i++) {
    $fakeLogs += [PSCustomObject]@{
        TimeGenerated = (Get-Date).AddMinutes(-($i * 2))
        UserName = "admin"
        SourceIP = $bruteForceIP
        LogonType = "RemoteInteractive"
        FailureReason = "Invalid credentials"
        ProcessName = "WinLogon.exe"
        WorkstationName = "SERVER-01"
        TargetDomain = "TESTDOMAIN"
    }
}

# Simulate Password Spraying (Different usernames from one attacker IP)
$passwordSprayIP = $attackIPs | Get-Random
for ($i = 1; $i -le $passwordSprayAttempts; $i++) {
    $fakeLogs += [PSCustomObject]@{
        TimeGenerated = (Get-Date).AddMinutes(-($i * 3))
        UserName = $users | Get-Random
        SourceIP = $passwordSprayIP
        LogonType = "Network"
        FailureReason = "Invalid credentials"
        ProcessName = "SMBAuth.exe"
        WorkstationName = "CORP-SERVER"
        TargetDomain = "TESTDOMAIN"
    }
}

# Simulate RDP Attacks (Multiple failed RDP logins from various attacker IPs)
for ($i = 1; $i -le $rdpAttackAttempts; $i++) {
    $rdpIP = $attackIPs | Get-Random  # Each RDP attempt may use a different attacker IP
    $fakeLogs += [PSCustomObject]@{
        TimeGenerated = (Get-Date).AddMinutes(-($i * 6))
        UserName = "admin"
        SourceIP = $rdpIP
        LogonType = "RemoteInteractive"
        FailureReason = "Invalid credentials"
        ProcessName = "mstsc.exe"
        WorkstationName = "REMOTE-ACCESS"
        TargetDomain = "TESTDOMAIN"
    }
}

# Export fake logs to CSV
$fakeLogs | Export-Csv -Path $outputPath -NoTypeInformation
Write-Host "Fake log data saved to: $outputPath"
