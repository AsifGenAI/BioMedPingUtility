# BioMedPingUtility

A simple PowerShell health‑check script for biomedical devices that verifies:

1. Wired NIC status (ignores Wi‑Fi/Wireless)  
2. Local IP, Subnet Mask & Default Gateway  
3. ICMP ping to the default gateway  
4. ICMP ping to a hard‑coded server (8.8.8.8)  
5. TCP port test to the server on port 443  

Based on the results, it displays one of three scenarios with clear next‑step instructions.
---

## Prerequisites

- Windows PowerShell (v5.1 or later)  
- Run **as Administrator** (to access WMI and network adapters)  

---

## Installation

1. Copy **BioMedPingUtility.ps1** to your scripts folder (e.g. `D:\scripts`).  
2. Ensure execution policy allows script running:
   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   
## Usage
```powershell
PS D:\scripts> .\BioMedPingUtility.ps1
```
No parameters required — server and port are hard‑coded.

## Output Scenarios

### Scenario 1: All Connectivity Success – Clinical Apps Attention Needed
```text
Local IP Address : 192.168.8.7
Subnet Mask       : 255.255.255.0
Default Gateway   : 192.168.8.1

Pinging default gateway (192.168.8.1)…
✅ Default gateway is reachable.

Pinging server (8.8.8.8)…
✅ Server '8.8.8.8' is reachable.

Testing TCP port 443 on '8.8.8.8'…
✅ TCP port 443 on '8.8.8.8' is OPEN.

🎉 All connectivity checks passed! If the device is still not working, please contact your Clinical Application Team.
```
### Scenario 2: Network OK but Server Port Blocked
```text
…gateway & server pings succeed…

Testing TCP port 443 on '8.8.8.8'…
❌ TCP port 443 on '8.8.8.8' is CLOSED or FILTERED.

✅ Server '8.8.8.8' is reachable. However, connectivity on port 443 cannot be established. Please contact your Network Team with this screenshot.
```
### Scenario 3: Network Failure
```text
Pinging default gateway (192.168.8.1)…
❌ Default gateway is NOT reachable.

Pinging server (8.8.8.8)…
❌ Server '8.8.8.8' is NOT reachable.

❌ Default gateway or server is not reachable. Please contact your Network Team with this screenshot.
```
