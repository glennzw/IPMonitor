# Initialize variables
$apiEndpoint = "fake-json-api.mock.beeceptor.com"
$ipHistory = @()
$currentIP = ""
$loopInterval = 20

function Resolve-ApiIPv4 {
    try {
        $resolvedIPs = [System.Net.Dns]::GetHostAddresses($apiEndpoint) | Where-Object { $_.AddressFamily -eq 'InterNetwork' }
        return $resolvedIPs.IPAddressToString
    } catch {
        return $null
    }
}

function Check-ApiAccessibility {
    try {
        $response = Invoke-WebRequest -Uri "https://$apiEndpoint" -UseBasicParsing -TimeoutSec 5
        return $true
    } catch [System.Net.WebException] {
        if ($_.Exception.Response.StatusCode -eq 404) {
            return $true
        } else {
            return $false
        }
    } catch {
        return $false
    }
}

function Monitor-Api {
    while ($true) {
        $resolvedIP = Resolve-ApiIPv4
        $isAccessible = Check-ApiAccessibility
        $timestamp = Get-Date -Format "dd MMM HH'h'mm"
        
        if ($resolvedIP -ne $null -and $resolvedIP -ne $currentIP) {
            $currentIP = $resolvedIP
            $ipHistory += "${timestamp}: ${resolvedIP}`n"
        }
        
        Clear-Host
        Write-Output "Endpoint IP Monitor"
        Write-Output "-------------------"
        Write-Output "Endpoint: $apiEndpoint"
        Write-Output "Endpoint IP: $resolvedIP"
        Write-Output "Currently accessible: $isAccessible"
        Write-Output ""
        Write-Output "IP History:"
        $ipHistory | ForEach-Object { Write-Output $_ }
        
        Start-Sleep -Seconds $loopInterval
    }
}

# Start monitoring
Monitor-Api
