# 🔒 AuthWatch: Log Analysis & Threat Detection  

AuthWatch is a cybersecurity tool designed to help analyze authentication logs, detect unusual login activity, and check IP reputation using AbuseIPDB. It provides a structured way to investigate failed logins, whether from real-time Windows Event Logs or imported log files.  

## Features  

- **Analyze authentication logs** from Windows Event Viewer or a CSV file  
- **Identify suspicious login attempts** based on IP reputation  
- **Automatically export findings** to a CSV for further review  
- **Fallback to CSV mode** when event logs are unavailable  

## How to Use  

### Analyze Windows Event Logs (requires admin privileges)  
```powershell
.\AuthWatch.ps1
```

### Analyze a CSV file instead of Event Logs  
```powershell
.\AuthWatch.ps1 -useCsv
```
Ensure the CSV exists at:  
```
C:\Users\YourUser\Documents\FailedLogins.csv
```

### Output  
The results will be saved in:  
```
C:\Users\YourUser\Documents\AuthWatch_YYYYMMDD_HHMMSS.csv
```

## Real-World Use Case  

AuthWatch helps detect failed login attempts and identify potential threats using IP reputation analysis. It can be used by security analysts, IT admins, or anyone monitoring authentication logs.  

## Roadmap  

- [ ] Add geolocation lookup for flagged IPs  
- [ ] Improve detection by integrating multiple threat intelligence sources  
- [ ] Expand log support for failed RDP and Kerberos authentication events  
- [ ] Implement real-time alerting for high-risk IPs  

## Contributing  

Contributions and suggestions are always welcome. Feel free to open an issue or submit a pull request.  

## License  

MIT License – Free to use and modify.  
```
