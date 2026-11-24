<#
.SYNOPSIS
Checks whether Groq accepts an API key, without generating text.
.DESCRIPTION
Uses GROQ_API_KEY from Windows user variables, then checks the current terminal
if the user variable is empty. If neither has a key, or -PromptForKey is supplied,
asks for the key with hidden input. The script keeps the key in memory for the check.

Makes one authenticated GET to Groq's models endpoint. A successful check proves
authentication for this endpoint; model-specific generation permissions need a
separate check. Requires Windows PowerShell 5.1 or PowerShell 7, without Python.

Exit code: 0 = key accepted; 1 = rejected or verification could not complete.
.EXAMPLE
.\Check-GroqApiKey.ps1
.EXAMPLE
.\Check-GroqApiKey.ps1 -PromptForKey
#>
[CmdletBinding()]
param(
    [switch]$PromptForKey,
    [ValidateRange(1, 60)][int]$TimeoutSeconds = 15
)

$ErrorActionPreference = 'Stop'
$groqExitCode = 1
$groqSecret = $null
$groqKeyValue = $null
$groqHeaders = $null

try {
    if (-not $PromptForKey) {
        $groqKeyValue = [Environment]::GetEnvironmentVariable('GROQ_API_KEY', [EnvironmentVariableTarget]::User)
        if ([string]::IsNullOrWhiteSpace($groqKeyValue)) {
            $groqKeyValue = $env:GROQ_API_KEY
        }
    }
    if ($PromptForKey -or [string]::IsNullOrWhiteSpace($groqKeyValue)) {
        $groqSecret = Read-Host 'Paste your Groq API key (input is hidden)' -AsSecureString
        $groqKeyValue = [System.Management.Automation.PSCredential]::new(
            'groq', $groqSecret
        ).GetNetworkCredential().Password
    }
    if ([string]::IsNullOrWhiteSpace($groqKeyValue)) {
        Write-Host '[FAIL] No API key was provided.' -ForegroundColor Red
        exit 1
    }
    $groqKeyValue = $groqKeyValue.Trim()
    if ($groqKeyValue -match '\s') {
        Write-Host '[FAIL] The key contains whitespace. Paste only the API key.' -ForegroundColor Red
        exit 1
    }

    Write-Host 'Checking Groq authentication...'
    $groqHeaders = @{ Authorization = 'Bearer ' + $groqKeyValue; Accept = 'application/json' }
    $groqReply = Invoke-RestMethod -Uri 'https://api.groq.com/openai/v1/models' `
        -Method Get -Headers $groqHeaders -UserAgent 'Paridhwani/2.0' `
        -TimeoutSec $TimeoutSeconds -MaximumRedirection 0 -UseBasicParsing -ErrorAction Stop

    # Validate the response before claiming authentication succeeded. Do not echo it.
    if ($null -eq $groqReply -or $groqReply.data -isnot [array]) {
        Write-Host '[FAIL] Groq returned an unexpected response. The key could not be verified.' -ForegroundColor Red
        exit 1
    }
    foreach ($groqModel in $groqReply.data) {
        if ($null -eq $groqModel -or $groqModel.id -isnot [string] -or [string]::IsNullOrWhiteSpace($groqModel.id)) {
            Write-Host '[FAIL] Groq returned an unexpected model list. The key could not be verified.' -ForegroundColor Red
            exit 1
        }
    }

    Write-Host '[PASS] Groq accepted the API key.' -ForegroundColor Green
    Write-Host ('Models listed: {0}' -f $groqReply.data.Count)
    Write-Host 'Model-specific generation permissions require a separate check.'
    $groqExitCode = 0
} catch {
    # Only fixed messages and numeric HTTP status are displayed. Exception messages,
    # request headers and provider response bodies can contain sensitive details.
    $groqHttpStatus = 0
    if ($null -ne $_.Exception.Response) {
        $groqHttpStatus = [int]$_.Exception.Response.StatusCode
    }

    if ($groqHttpStatus -eq 401) {
        Write-Host '[FAIL] HTTP 401: Groq rejected the API key. Check that it is active and copied correctly.' -ForegroundColor Red
    } elseif ($groqHttpStatus -eq 403) {
        if ([string]$_.ErrorDetails.Message -match '\berror(?:\s+code)?\s*:?\s*1010\b') {
            Write-Host '[FAIL] HTTP 403 / Cloudflare 1010: the provider blocked this request. Key validity is unconfirmed.' -ForegroundColor Red
        } else {
            Write-Host '[FAIL] HTTP 403: access denied. Check Groq account/project permissions; this alone does not prove the key is invalid.' -ForegroundColor Red
        }
    } elseif ($groqHttpStatus -eq 429) {
        Write-Host '[FAIL] HTTP 429: Groq rate limit reached. Wait before checking again.' -ForegroundColor Yellow
    } elseif ($groqHttpStatus -ge 500) {
        Write-Host ('[FAIL] HTTP {0}: Groq is unavailable. Try again later.' -f $groqHttpStatus) -ForegroundColor Yellow
    } elseif ($groqHttpStatus -gt 0) {
        Write-Host ('[FAIL] Groq returned HTTP {0}. The key could not be verified.' -f $groqHttpStatus) -ForegroundColor Red
    } else {
        $groqDnsFailure = $false
        $groqTimedOut = $false
        for ($groqCause = $_.Exception; $null -ne $groqCause; $groqCause = $groqCause.InnerException) {
            if ($groqCause -is [System.Net.WebException]) {
                $groqDnsFailure = $groqDnsFailure -or $groqCause.Status -in @(
                    [System.Net.WebExceptionStatus]::NameResolutionFailure,
                    [System.Net.WebExceptionStatus]::ProxyNameResolutionFailure
                )
                $groqTimedOut = $groqTimedOut -or $groqCause.Status -eq [System.Net.WebExceptionStatus]::Timeout
            }
            if ($groqCause -is [System.Net.Sockets.SocketException]) {
                $groqDnsFailure = $groqDnsFailure -or $groqCause.SocketErrorCode -in @(
                    [System.Net.Sockets.SocketError]::HostNotFound,
                    [System.Net.Sockets.SocketError]::TryAgain,
                    [System.Net.Sockets.SocketError]::NoData
                )
            }
            $groqTimedOut = $groqTimedOut -or $groqCause -is [System.TimeoutException] -or
                $groqCause -is [System.OperationCanceledException]
        }
        if ($groqDnsFailure) {
            Write-Host '[FAIL] Could not resolve api.groq.com. Check DNS/network access. The key was not verified.' -ForegroundColor Red
        } elseif ($groqTimedOut) {
            Write-Host '[FAIL] The connection timed out. The key was not verified.' -ForegroundColor Red
        } else {
            Write-Host '[FAIL] The connection or check could not complete. Check network/proxy access. The key was not verified.' -ForegroundColor Red
        }
    }
} finally {
    $groqHeaders = $null
    $groqKeyValue = $null
    if ($null -ne $groqSecret) { $groqSecret.Dispose() }
}

exit $groqExitCode
