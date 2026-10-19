# Common helpers: paths, logging, environment checks.
# Compatible with Windows PowerShell 5.1 (no ?:, ??, && or ||).

$script:DataDir = Join-Path $env:ProgramData 'WinDebloat'
$script:RunsDir = Join-Path $script:DataDir 'runs'
$script:LogDir  = Join-Path $script:DataDir 'logs'
$script:StateFile = Join-Path $script:DataDir 'state.json'
$script:LogFile = $null
$script:Quiet = $false

function Initialize-DataDir {
    foreach ($d in @($script:DataDir, $script:RunsDir, $script:LogDir)) {
        if (-not (Test-Path -LiteralPath $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
    }
    if (-not $script:LogFile) {
        $script:LogFile = Join-Path $script:LogDir ((Get-Date -Format 'yyyyMMdd-HHmmss') + '.log')
    }
}

function Write-Log {
    param(
        [ValidateSet('INFO', 'OK', 'WARN', 'ERROR', 'PLAN', 'DEBUG')][string]$Level = 'INFO',
        [string]$Message
    )
    $line = '{0} [{1}] {2}' -f (Get-Date -Format 'HH:mm:ss'), $Level, $Message
    if ($script:LogFile) {
        try { Add-Content -LiteralPath $script:LogFile -Value $line -Encoding UTF8 } catch { }
    }
    if ($script:Quiet -and $Level -in @('INFO', 'OK', 'DEBUG', 'PLAN')) { return }
    if ($Level -eq 'DEBUG' -and -not $env:WINDEBLOAT_DEBUG) { return }
    $color = switch ($Level) {
        'OK' { 'Green' } 'WARN' { 'Yellow' } 'ERROR' { 'Red' } 'PLAN' { 'Cyan' } 'DEBUG' { 'DarkGray' } default { 'Gray' }
    }
    Write-Host $line -ForegroundColor $color
}

function Test-IsAdmin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    return ([Security.Principal.WindowsPrincipal]$id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-AccessDenied {
    # .NET calls surface as MethodInvocationException; look through to the real cause.
    param($ErrorRecord)
    $e = $ErrorRecord.Exception
    while ($e) {
        if ($e -is [System.UnauthorizedAccessException] -or $e -is [System.Security.SecurityException]) { return $true }
        $e = $e.InnerException
    }
    return $false
}

function Get-BuildNumber {
    return [int](Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').CurrentBuildNumber
}

function Get-Prop {
    # Safe property read on a hashtable/PSObject with default.
    param($Object, [string]$Name, $Default = $null)
    if ($null -eq $Object) { return $Default }
    if ($Object -is [hashtable]) {
        if ($Object.ContainsKey($Name)) { return $Object[$Name] } else { return $Default }
    }
    $p = $Object.PSObject.Properties[$Name]
    if ($p) { return $p.Value } else { return $Default }
}

function Expand-EnvPath {
    param([string]$Path)
    return [Environment]::ExpandEnvironmentVariables($Path)
}

function ConvertTo-StableJson {
    param($Object, [int]$Depth = 12)
    return ($Object | ConvertTo-Json -Depth $Depth)
}
