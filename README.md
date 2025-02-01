# 🔒 LogSentinel: Windows Log Analyzer & IP Reputation Checker  

## 🚀 Overview  
LogSentinel is a personal project built to automate failed login investigations by extracting authentication logs and checking IP reputation scores using AbuseIPDB.  
I created this tool to help security analysts and IT admins quickly identify suspicious logins without manually digging through event logs.  

## 💡 Why I Built This  
As a Security Grading Analyst, I spend a lot of time reviewing authentication logs to detect unusual login patterns.  
Manually analyzing logs is slow, and identifying truly suspicious logins requires context—such as whether an IP has a bad reputation.  

So I built LogSentinel to:  
✅ **Automate log retrieval** from **Windows Event Logs** or a **CSV file** for offline analysis.  
✅ **Check IP reputation** against **AbuseIPDB** to flag **potentially compromised accounts**.  
✅ **Export data** in a **clean, structured format** for further analysis.  

---

## 🎯 Features  

✅ **Two Data Sources**  
- Reads real-time **Windows Event Logs** (Event ID 4625).  
- Supports **CSV file input** for offline analysis & testing.  

✅ **IP Reputation Checking**  
- Queries **AbuseIPDB API** to detect known malicious IPs.  
- Adds a **confidence score (0-100)** indicating threat level.  

✅ **CSV Export**  
- Saves analyzed logins with reputation scores to a **timestamped CSV**.  

✅ **Automatic Fallback**  
- If **Windows logs aren’t accessible**, the script switches to **CSV mode**.  

✅ **Customizable Alerts (Planned Feature)**  
- **Email notifications** (coming soon).  
- **High-risk IP threshold alerts** (if reputation > 75).  

---

## 📖 How to Use  

### ▶️ **To analyze failed logins using Windows Event Logs (default)**  
```powershell
.\Windows-Log-Analysis.ps1
```
*(Requires Administrator privileges to access Security Logs.)*  

### ▶️ **To analyze a CSV file instead of Event Logs**  
```powershell
.\Windows-Log-Analysis.ps1 -useCsv
```
*(Ensure the test CSV exists at `C:\Users\YourUser\Documents\FakeFailedLogins.csv`.)*  

### 📁 **Output Location**  
- Results are saved in:  
  ```
  C:\Users\YourUser\Documents\FailedLogins_YYYYMMDD_HHMMSS.csv
  ```

---

## 🔥 Real-World Use Case  
While working as a Security Analyst, I often had to manually go through weeks of authentication logs to detect unusual login activity.  
One challenge was distinguishing real threats from false positives (e.g., traveling users triggering "unusual location" flags).  

This script helps **automate** that process by:  
✅ Pulling failed logins **directly from Windows Event Logs**.  
✅ Querying **IP reputation scores** to spot compromised sources.  
✅ Exporting data into **easy-to-read CSV files** for further analysis.  

---

## 📸 Screenshots  
### **Script Running in PowerShell:**  
![Script Running](screenshot.png)  

### **Sample CSV Output:**  
```
TimeGenerated, UserName, SourceIP, LogonType, FailureReason, IPReputationScore
2025-02-01 14:20, admin, 203.0.113.45, RemoteInteractive, Invalid credentials, 87
2025-02-01 14:22, user123, 192.168.1.10, Network, Account locked out, 12
```

---

## 🎯 Personal Roadmap  

### 🔍 **Enhancements**  
- [ ] **Geolocation Lookup** (Map IPs to countries & cities).  
- [ ] **Improved Reputation Scores** (Combine multiple sources beyond AbuseIPDB).  
- [ ] **More Event IDs** (Monitor failed Kerberos logins & suspicious authentication patterns).  
- [ ] **Threat Intelligence Integration** (Cross-check against real-world attack data).  

### ⚠ **Alerts & Security Automation**  
- [ ] **Email Alerts for High-Risk IPs** (Notify admins if reputation > 75).  
- [ ] **Webhook Integration** (Send data to SIEM tools like Splunk).  
- [ ] **Automated Blocking** (Option to flag/block repeated failed attempts).  

### 📊 **Visualization & Reporting**  
- [ ] **Dashboard for Log Analysis** (Graph login trends & anomalies).  
- [ ] **Weekly Summary Reports** (Automatically generate key insights).  

---

## 🤝 Contributing  
Suggestions & improvements are welcome! 🚀  
Feel free to **open an issue** or **submit a pull request**.  

---

## 📜 License  
Licensed under the **MIT License** – Free to use & modify.  
```
