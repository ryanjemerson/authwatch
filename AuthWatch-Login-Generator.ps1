# AuthWatch Fake Login Generator
# Generates a CSV file with simulated authentication logs, including attack scenarios

param (
    [int]$logCount = 100, # Total number of logs to generate
    [string]$outputPath = "$env:USERPROFILE\Documents\AuthWatch_FakeLogins.csv"
)

# Sample usernames, IPs, and failure reasons
$users = @("admin", "testuser", "jsmith", "backup", "security", "root", "sysadmin", "serviceacct")
$attackIPs = @("185.199.110.153", "45.33.32.156", "203.0.113.45", "8.8.8.8") # Known malicious IPs
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

# Simulate Brute Force Attack (Repeated failed logins from one IP)
for ($i = 1; $i -le $bruteForceAttempts; $i++) {
    $fakeLogs += [PSCustomObject]@{
        TimeGenerated = (Get-Date).AddMinutes(-($i * 2))
        UserName = "admin"
        SourceIP = "185.199.110.153"
        LogonType = "RemoteInteractive"
        FailureReason = "Invalid credentials"
        ProcessName = "WinLogon.exe"
        WorkstationName = "SERVER-01"
        TargetDomain = "TESTDOMAIN"
    }
}

# Simulate Password Spraying (Different usernames from one IP)
for ($i = 1; $i -le $passwordSprayAttempts; $i++) {
    $fakeLogs += [PSCustomObject]@{
        TimeGenerated = (Get-Date).AddMinutes(-($i * 3))
        UserName = $users | Get-Random
        SourceIP = "45.33.32.156"
        LogonType = "Network"
        FailureReason = "Invalid credentials"
        ProcessName = "SMBAuth.exe"
        WorkstationName = "CORP-SERVER"
        TargetDomain = "TESTDOMAIN"
    }
}

# Simulate RDP Attacks (Multiple failed RDP logins)
for ($i = 1; $i -le $rdpAttackAttempts; $i++) {
    $fakeLogs += [PSCustomObject]@{
        TimeGenerated = (Get-Date).AddMinutes(-($i * 6))
        UserName = "admin"
        SourceIP = "203.0.113.45"
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