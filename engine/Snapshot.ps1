# Snapshot / state store.
#   runs\<runid>.json : every action executed in a run with its PRIOR state (what revert restores)
#   state.json        : which tweaks this tool has applied (used for 'status' drift detection and -DriftOnly)

function ConvertTo-Hashtable {
    param($Object)
    if ($null -eq $Object) { return $null }
    if ($Object -is [System.Management.Automation.PSCustomObject]) {
        $h = @{}
        foreach ($p in $Object.PSObject.Properties) { $h[$p.Name] = ConvertTo-Hashtable $p.Value }
        return $h
    }
    if ($Object -is [System.Collections.IDictionary]) {
        $h = @{}
        foreach ($k in $Object.Keys) { $h[$k] = ConvertTo-Hashtable $Object[$k] }
        return $h
    }
    if ($Object -is [System.Collections.IEnumerable] -and $Object -isnot [string]) {
        return , @($Object | ForEach-Object { ConvertTo-Hashtable $_ })
    }
    return $Object
}

function Read-JsonFile {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    $raw = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    if (-not $raw) { return $null }
    return (ConvertTo-Hashtable (ConvertFrom-Json $raw))
}

function Write-JsonFile {
    param([string]$Path, $Object)
    $json = ConvertTo-StableJson $Object 14
    [IO.File]::WriteAllText($Path, $json, (New-Object Text.UTF8Encoding($false)))
}

function Get-State {
    $s = Read-JsonFile $script:StateFile
    if (-not $s) { $s = @{ Applied = @{} } }
    if (-not $s.ContainsKey('Applied') -or $null -eq $s.Applied) { $s.Applied = @{} }
    return $s
}

function Save-State {
    param($State)
    Initialize-DataDir
    Write-JsonFile $script:StateFile $State
}

function New-RunRecord {
    param([string]$Profile)
    Initialize-DataDir
    $base = Get-Date -Format 'yyyyMMdd-HHmmss'
    $id = $base; $n = 1
    while (Test-Path -LiteralPath (Join-Path $script:RunsDir ($id + '.json'))) { $n++; $id = '{0}-{1:00}' -f $base, $n }   # never overwrite an earlier snapshot
    return @{ Run = $id; Time = (Get-Date).ToString('o'); Profile = $Profile; Build = (Get-BuildNumber); Entries = @() }
}

function Add-RunEntry {
    param($Run, [string]$TweakId, [int]$Index, $Action, $Prior)
    $Run.Entries += @{ Tweak = $TweakId; Index = $Index; Type = $Action.Type; Action = $Action; Prior = $Prior }
    Save-RunRecord $Run
}

function Save-RunRecord {
    param($Run)
    Write-JsonFile (Join-Path $script:RunsDir ($Run.Run + '.json')) $Run
}

function Get-RunRecords {
    # newest first. Callers MUST wrap the call in @() (a single record unrolls to a lone hashtable).
    if (-not (Test-Path $script:RunsDir)) { return @() }
    $files = @(Get-ChildItem $script:RunsDir -Filter '*.json' -File | Sort-Object Name -Descending)
    return @($files | ForEach-Object { Read-JsonFile $_.FullName } | Where-Object { $_ })
}
