# Action types: ScheduledTask, File, Hosts, Env, Bcdedit

# ---------- ScheduledTask ----------
#   @{ Type='ScheduledTask'; Path='\Microsoft\Windows\Application Experience\'; Name='*'; State='Disabled' }
# Name may be a wildcard. Tasks that do not exist -> NotApplicable.

function Get-TaskMatches {
    param([string]$Path, [string]$Name)
    if (-not $Path.EndsWith('\')) { $Path += '\' }
    return @(Get-ScheduledTask -TaskPath $Path -ErrorAction SilentlyContinue | Where-Object { $_.TaskName -like $Name })
}

function Test-ActionScheduledTask {
    param([hashtable]$Action)
    $name = Get-Prop $Action 'Name' '*'
    $tasks = Get-TaskMatches $Action.Path $name
    if ($tasks.Count -eq 0) { return @{ Status = 'NotApplicable'; Detail = 'task not present'; Prior = @() } }
    $prior = @($tasks | ForEach-Object { @{ Path = $_.TaskPath; Name = $_.TaskName; Enabled = ($_.State -ne 'Disabled') } })
    $wantDisabled = ((Get-Prop $Action 'State' 'Disabled') -eq 'Disabled')
    $bad = @($tasks | Where-Object { if ($wantDisabled) { $_.State -ne 'Disabled' } else { $_.State -eq 'Disabled' } })
    if ($bad.Count -eq 0) { return @{ Status = 'Applied'; Detail = ''; Prior = $prior } }
    return @{ Status = 'Pending'; Detail = (($bad | ForEach-Object { $_.TaskName }) -join ','); Prior = $prior }
}

function Set-TaskState {
    param($Task, [bool]$Enable)
    try {
        if ($Enable) { Enable-ScheduledTask -TaskPath $Task.TaskPath -TaskName $Task.TaskName -ErrorAction Stop | Out-Null }
        else { Disable-ScheduledTask -TaskPath $Task.TaskPath -TaskName $Task.TaskName -ErrorAction Stop | Out-Null }
    }
    catch {
        $flag = if ($Enable) { '/enable' } else { '/disable' }
        $full = ($Task.TaskPath.TrimEnd('\') + '\' + $Task.TaskName)
        & schtasks.exe /change /tn $full $flag 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) { Write-Log WARN "Could not change task $full ($($_.Exception.Message)); may need TrustedInstaller." }
    }
}

function Invoke-ActionScheduledTask {
    param([hashtable]$Action, $Test)
    $wantDisabled = ((Get-Prop $Action 'State' 'Disabled') -eq 'Disabled')
    foreach ($t in (Get-TaskMatches $Action.Path (Get-Prop $Action 'Name' '*'))) { Set-TaskState $t (-not $wantDisabled) }
}

function Undo-ActionScheduledTask {
    param([hashtable]$Action, $Prior)
    foreach ($p in @($Prior)) {
        $t = Get-ScheduledTask -TaskPath $p.Path -TaskName $p.Name -ErrorAction SilentlyContinue
        if ($t) { Set-TaskState $t ([bool]$p.Enabled) }
    }
}

# ---------- File ----------
#   @{ Type='File'; Op='Delete'; Path='%SystemDrive%\OneDriveTemp' }     delete file/dir (wildcards ok; files <=5MB backed up)
#   @{ Type='File'; Op='Write'; Path='C:\x.txt'; Content='text' }       write UTF-8 (no BOM) text

function Test-ActionFile {
    param([hashtable]$Action)
    $path = Expand-EnvPath $Action.Path
    $op = Get-Prop $Action 'Op' 'Delete'
    if ($op -eq 'Delete') {
        $hits = @(Get-Item -Path $path -Force -ErrorAction SilentlyContinue)
        if ($hits.Count -eq 0) { return @{ Status = 'Applied'; Detail = ''; Prior = @() } }
        return @{ Status = 'Pending'; Detail = "delete $path"; Prior = @($hits | ForEach-Object { $_.FullName }) }
    }
    $exists = Test-Path -LiteralPath $path
    $cur = if ($exists) { [IO.File]::ReadAllText($path) } else { $null }
    $prior = @{ Existed = $exists; Backup = $null }
    if ($exists -and $cur -ceq $Action.Content) { return @{ Status = 'Applied'; Detail = ''; Prior = $prior } }
    return @{ Status = 'Pending'; Detail = "write $path"; Prior = $prior }
}

function Invoke-ActionFile {
    param([hashtable]$Action, $Test)
    $path = Expand-EnvPath $Action.Path
    $op = Get-Prop $Action 'Op' 'Delete'
    $bdir = Join-Path $script:RunsDir 'backup'
    if ($op -eq 'Delete') {
        $i = 0
        foreach ($p in @($Test.Prior)) {
            $item = Get-Item -LiteralPath $p -Force -ErrorAction SilentlyContinue
            if ($item -and -not $item.PSIsContainer -and $item.Length -le 5MB) {
                if (-not (Test-Path $bdir)) { New-Item -ItemType Directory -Path $bdir -Force | Out-Null }
                $dest = Join-Path $bdir ([guid]::NewGuid().ToString('N') + '_' + $item.Name)
                Copy-Item -LiteralPath $p -Destination $dest -Force
                $i++
            }
            Remove-Item -LiteralPath $p -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    else {
        $dir = Split-Path $path -Parent
        if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        if ($Test.Prior.Existed -and (Test-Path -LiteralPath $path)) {
            if (-not (Test-Path $bdir)) { New-Item -ItemType Directory -Path $bdir -Force | Out-Null }
            $dest = Join-Path $bdir ([guid]::NewGuid().ToString('N') + '_' + (Split-Path $path -Leaf))
            Copy-Item -LiteralPath $path -Destination $dest -Force
            $Test.Prior.Backup = $dest
        }
        [IO.File]::WriteAllText($path, [string]$Action.Content, (New-Object Text.UTF8Encoding($false)))
    }
}

function Undo-ActionFile {
    param([hashtable]$Action, $Prior)
    $path = Expand-EnvPath $Action.Path
    if ((Get-Prop $Action 'Op' 'Delete') -eq 'Write') {
        if ($Prior -and (Get-Prop $Prior 'Backup')) { Copy-Item -LiteralPath $Prior.Backup -Destination $path -Force }
        elseif ($Prior -and -not (Get-Prop $Prior 'Existed' $false)) { Remove-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue }
    }
    else { Write-Log WARN "Deleted files for '$path' are not restored automatically (small-file backups are in $script:RunsDir\backup)." }
}

# ---------- Hosts ----------
#   @{ Type='Hosts'; Name='telemetry'; Entries=@('telemetry.microsoft.com','watson.microsoft.com') }   -> 0.0.0.0 <host>
# Managed block between markers; never replaces the file. Lines already present elsewhere in the file are not duplicated.

function Get-HostsPath { return (Join-Path $env:SystemRoot 'System32\drivers\etc\hosts') }

function Get-HostsDesired {
    param([hashtable]$Action)
    $lines = @()
    foreach ($e in @($Action.Entries)) {
        if ($e -match '^\s*\S+\s+\S+') { $lines += $e.Trim() } else { $lines += "0.0.0.0 $($e.Trim())" }
    }
    return $lines
}

function Test-ActionHosts {
    param([hashtable]$Action)
    $path = Get-HostsPath
    $content = if (Test-Path $path) { [IO.File]::ReadAllLines($path) } else { @() }
    $present = @{}
    foreach ($l in $content) { $t = ($l -replace '\s+', ' ').Trim(); if ($t -and -not $t.StartsWith('#')) { $present[$t.ToLower()] = $true } }
    $missing = @(Get-HostsDesired $Action | Where-Object { -not $present.ContainsKey((($_ -replace '\s+', ' ').Trim().ToLower())) })
    $prior = @{ Block = $Action.Name }
    if ($missing.Count -eq 0) { return @{ Status = 'Applied'; Detail = ''; Prior = $prior } }
    return @{ Status = 'Pending'; Detail = "$($missing.Count) hosts entries missing"; Prior = $prior }
}

function Invoke-ActionHosts {
    param([hashtable]$Action, $Test)
    $path = Get-HostsPath
    $begin = "# >>> WinDebloat:$($Action.Name)"; $end = "# <<< WinDebloat:$($Action.Name)"
    $content = if (Test-Path $path) { @([IO.File]::ReadAllLines($path)) } else { @() }
    # strip an old managed block
    $out = @(); $skip = $false
    foreach ($l in $content) {
        if ($l -eq $begin) { $skip = $true; continue }
        if ($l -eq $end) { $skip = $false; continue }
        if (-not $skip) { $out += $l }
    }
    $present = @{}
    foreach ($l in $out) { $t = ($l -replace '\s+', ' ').Trim(); if ($t -and -not $t.StartsWith('#')) { $present[$t.ToLower()] = $true } }
    $add = @(Get-HostsDesired $Action | Where-Object { -not $present.ContainsKey((($_ -replace '\s+', ' ').Trim().ToLower())) })
    if ($add.Count -gt 0) { $out += $begin; $out += $add; $out += $end }
    [IO.File]::WriteAllLines($path, [string[]]$out, (New-Object Text.UTF8Encoding($false)))
    & ipconfig.exe /flushdns 2>&1 | Out-Null
}

function Undo-ActionHosts {
    param([hashtable]$Action, $Prior)
    $path = Get-HostsPath
    $begin = "# >>> WinDebloat:$($Action.Name)"; $end = "# <<< WinDebloat:$($Action.Name)"
    $out = @(); $skip = $false
    foreach ($l in @([IO.File]::ReadAllLines($path))) {
        if ($l -eq $begin) { $skip = $true; continue }
        if ($l -eq $end) { $skip = $false; continue }
        if (-not $skip) { $out += $l }
    }
    [IO.File]::WriteAllLines($path, [string[]]$out, (New-Object Text.UTF8Encoding($false)))
}

# ---------- Env ----------
#   @{ Type='Env'; Name='DOTNET_CLI_TELEMETRY_OPTOUT'; Value='1'; Target='Machine' }

function Test-ActionEnv {
    param([hashtable]$Action)
    $target = Get-Prop $Action 'Target' 'Machine'
    $cur = [Environment]::GetEnvironmentVariable($Action.Name, $target)
    $prior = @{ Existed = ($null -ne $cur); Value = $cur }
    if ($cur -ceq [string]$Action.Value) { return @{ Status = 'Applied'; Detail = ''; Prior = $prior } }
    return @{ Status = 'Pending'; Detail = "$($Action.Name)=$($Action.Value)"; Prior = $prior }
}
function Invoke-ActionEnv {
    param([hashtable]$Action, $Test)
    [Environment]::SetEnvironmentVariable($Action.Name, [string]$Action.Value, (Get-Prop $Action 'Target' 'Machine'))
}
function Undo-ActionEnv {
    param([hashtable]$Action, $Prior)
    $val = if (Get-Prop $Prior 'Existed' $false) { [string]$Prior.Value } else { $null }
    [Environment]::SetEnvironmentVariable($Action.Name, $val, (Get-Prop $Action 'Target' 'Machine'))
}

# ---------- Bcdedit ----------
#   @{ Type='Bcdedit'; Name='bootmenupolicy'; Value='Legacy' }          set
#   @{ Type='Bcdedit'; Name='useplatformclock'; Op='DeleteValue' }      delete

function Get-BcdValue {
    param([string]$Name)
    $out = & bcdedit.exe /enum '{current}' 2>&1
    if ($LASTEXITCODE -ne 0) { return @{ Ok = $false } }
    foreach ($l in $out) {
        if ($l -match '^\s*(\S+)\s+(.+?)\s*$' -and $Matches[1] -ieq $Name) { return @{ Ok = $true; Exists = $true; Value = $Matches[2] } }
    }
    return @{ Ok = $true; Exists = $false }
}

function Test-ActionBcdedit {
    param([hashtable]$Action)
    if (-not (Test-IsAdmin)) { return @{ Status = 'Unknown'; Detail = 'needs admin'; Prior = $null } }
    $cur = Get-BcdValue $Action.Name
    if (-not $cur.Ok) { return @{ Status = 'Unknown'; Detail = 'bcdedit failed'; Prior = $null } }
    $prior = @{ Exists = $cur.Exists; Value = (Get-Prop $cur 'Value') }
    if ((Get-Prop $Action 'Op' 'Set') -eq 'DeleteValue') {
        if (-not $cur.Exists) { return @{ Status = 'Applied'; Detail = ''; Prior = $prior } }
        return @{ Status = 'Pending'; Detail = "bcdedit delete $($Action.Name)"; Prior = $prior }
    }
    if ($cur.Exists -and $cur.Value -ieq [string]$Action.Value) { return @{ Status = 'Applied'; Detail = ''; Prior = $prior } }
    return @{ Status = 'Pending'; Detail = "bcdedit $($Action.Name) -> $($Action.Value)"; Prior = $prior }
}
function Invoke-ActionBcdedit {
    param([hashtable]$Action, $Test)
    if ((Get-Prop $Action 'Op' 'Set') -eq 'DeleteValue') { & bcdedit.exe /deletevalue $Action.Name 2>&1 | Out-Null }
    else { & bcdedit.exe /set $Action.Name ([string]$Action.Value) 2>&1 | Out-Null }
    if ($LASTEXITCODE -ne 0) { throw "bcdedit failed for $($Action.Name)" }
}
function Undo-ActionBcdedit {
    param([hashtable]$Action, $Prior)
    if ($Prior -and (Get-Prop $Prior 'Exists' $false)) { & bcdedit.exe /set $Action.Name ([string]$Prior.Value) 2>&1 | Out-Null }
    else { & bcdedit.exe /deletevalue $Action.Name 2>&1 | Out-Null }
}
