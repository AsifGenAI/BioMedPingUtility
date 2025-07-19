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
