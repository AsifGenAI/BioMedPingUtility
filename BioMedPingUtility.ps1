<#
.SYNOPSIS
  Displays wired NIC network info (ignoring Wi‑Fi), pings gateway & hard‑coded server, and tests TCP port connectivity.

.DESCRIPTION
  - Uses WMI to retrieve the first active, wired (non‑wireless) interface with an IPv4 gateway  
  - Shows Local IP, Subnet Mask, Default Gateway  
  - Pings the gateway (captures any “Generic failure” or other exception)  
  - Pings hard‑coded server 8.8.8.8 (captures exceptions)  
  - Tests TCP connectivity to 8.8.8.8 on port 443  
  - If all checks pass, reminds to contact Clinical Application Team if the device is still not working  
  - If ping succeeds but port test fails, prompts to contact the Network Team  
  - If gateway or server ping fails, prompts to contact the Network Team

.NOTES
  Save this as BioMedPingUtility.ps1 and run from an elevated PowerShell prompt.
#>

# — Hard‑coded targets —
$Server    = '8.8.8.8'
$TestPort  = 443
$PingCount = 2

# — Get the first IP‑enabled, wired adapter with a default gateway (ignore any with "Wi-Fi" or "Wireless") —
$wmi = Get-WmiObject -Class Win32_NetworkAdapterConfiguration |
    Where-Object {
        $_.IPEnabled -and
        $_.DefaultIPGateway -and
        $_.IPAddress -and
        ($_.Description -notmatch 'Wi-?Fi|Wireless')
    } |
    Select-Object -First 1

if (-not $wmi) {
    Write-Error "No active wired IPv4 interface with a default gateway found."
    exit 1
}

# — Extract network info from WMI object —
$localIP    = $wmi.IPAddress[0]
$subnetMask = $wmi.IPSubnet[0]
$gateway    = $wmi.DefaultIPGateway[0]

# — Display network info —
Write-Host "Local IP Address : $localIP"
Write-Host "Subnet Mask       : $subnetMask"
Write-Host "Default Gateway   : $gateway"
Write-Host ''

# — Ping Default Gateway —
Write-Host "Pinging default gateway ($gateway)…"
try {
    $gatewayOK    = Test-Connection -ComputerName $gateway -Count $PingCount -Quiet -ErrorAction Stop
    $gatewayError = $null
} catch {
    $gatewayOK    = $false
    $gatewayError = $_.Exception.Message
}
if ($gatewayOK) {
    Write-Host "✅ Default gateway is reachable." -ForegroundColor Green
} else {
    Write-Host "❌ Default gateway is NOT reachable." -ForegroundColor Red
    if ($gatewayError) {
        Write-Host "   ▶ Error: $gatewayError"
    }
}
Write-Host ''

# — Ping Hard‑coded Server —
Write-Host "Pinging server ($Server)…"
try {
    $serverOK    = Test-Connection -ComputerName $Server -Count $PingCount -Quiet -ErrorAction Stop
    $serverError = $null
} catch {
    $serverOK    = $false
    $serverError = $_.Exception.Message
}
if ($serverOK) {
    Write-Host "✅ Server '$Server' is reachable." -ForegroundColor Green
} else {
    Write-Host "❌ Server '$Server' is NOT reachable." -ForegroundColor Red
    if ($serverError) {
        Write-Host "   ▶ Error: $serverError"
    }
}
Write-Host ''

# — TCP Port Test on Hard‑coded Server —
Write-Host "Testing TCP port $TestPort on '$Server'…"
$tnc = Test-NetConnection -ComputerName $Server -Port $TestPort -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
if ($tnc -and $tnc.TcpTestSucceeded) {
    $portOK = $true
    Write-Host "✅ TCP port $TestPort on '$Server' is OPEN." -ForegroundColor Green
} else {
    $portOK = $false
    Write-Host "❌ TCP port $TestPort on '$Server' is CLOSED or FILTERED." -ForegroundColor Red
    if ($tnc -and $tnc.PingReplyDetails) {
        Write-Host "   ▶ Roundtrip: $($tnc.PingReplyDetails.RoundtripTime) ms"
    } elseif (-not $tnc) {
        Write-Host "   ▶ Unable to test port connectivity."
    }
}
Write-Host ''

# — Final messages based on results —
if ($gatewayOK -and $serverOK -and $portOK) {
    Write-Host "🎉 All connectivity checks passed! If the device is still not working, please contact your Clinical Application Team." -ForegroundColor Cyan
}
elseif ($serverOK -and -not $portOK) {
    Write-Host "✅ Server '$Server' is reachable. However, connectivity on port $TestPort cannot be established. Please contact your Network Team with this screenshot." -ForegroundColor Yellow
}
else {
    Write-Host "❌ Default gateway or server is not reachable. Please contact your Network Team with this screenshot." -ForegroundColor Red
}
