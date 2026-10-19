# Action type: Registry
#
#   @{ Type='Registry'; Path='HKLM\SOFTWARE\...'; Name='Value'; Kind='DWord'; Value=1 }          set a value (Op default 'Set')
#   @{ Type='Registry'; Path='HKCU\Software\...'; Name='X'; Op='DeleteValue' }                   delete a value
#   @{ Type='Registry'; Path='HKLM\SOFTWARE\...\Key'; Op='DeleteKey' }                           delete a key (exported first)
#   @{ Type='Registry'; Path='HKLM\SOFTWARE\...\Key'; Op='EnsureKey' }                           create an (empty) key
# Options: TI=$true (write as TrustedInstaller), RequireKey=$true (N/A if the parent key does not exist)
# Kinds: DWord, QWord, String, ExpandString, MultiString, Binary (Value = hex string 'aa-bb' or int array)
# HKCU paths are expanded to every real user profile + the Default user template (see Hives.ps1).

function Resolve-RegPath {
    param([string]$Path)
    $p = $Path -replace '^HKEY_LOCAL_MACHINE', 'HKLM' -replace '^HKEY_CURRENT_USER', 'HKCU' -replace '^HKEY_USERS', 'HKU' -replace '^HKEY_CLASSES_ROOT', 'HKCR'
    $p = $p -replace '^(HKLM|HKCU|HKU|HKCR):', '$1'
    $idx = $p.IndexOf('\')
    if ($idx -lt 0) { $hive = $p; $rest = '' } else { $hive = $p.Substring(0, $idx); $rest = $p.Substring($idx + 1) }
    $out = @()
    switch ($hive) {
        'HKLM' { $out += @{ Base = [Microsoft.Win32.Registry]::LocalMachine; Sub = $rest; Display = "HKLM\$rest"; Native = "HKLM\$rest" } }
        'HKCR' { $out += @{ Base = [Microsoft.Win32.Registry]::ClassesRoot; Sub = $rest; Display = "HKCR\$rest"; Native = "HKCR\$rest" } }
        'HKU' { $out += @{ Base = [Microsoft.Win32.Registry]::Users; Sub = $rest; Display = "HKU\$rest"; Native = "HKU\$rest" } }
        'HKCU' {
            foreach ($t in (Get-UserTargets)) {
                $root = $t.Root -replace '^HKU\\', ''
                $sub = if ($rest) { "$root\$rest" } else { $root }
                $out += @{ Base = [Microsoft.Win32.Registry]::Users; Sub = $sub; Display = "HKCU[$($t.Name)]\$rest"; Native = "HKU\$sub" }
            }
        }
        default { throw "Unsupported registry hive in path '$Path'" }
    }
    return $out
}

function ConvertTo-RegData {
    param([string]$Kind, $Value)
    switch ($Kind) {
        'DWord' { $v = [int64]$Value; if ($v -gt 2147483647) { $v -= 4294967296 }; return [int]$v }
        'QWord' { return [int64]$Value }
        'String' { return [string]$Value }
        'ExpandString' { return [string]$Value }
        'MultiString' { return , ([string[]]@($Value)) }
        'Binary' {
            if ($Value -is [string]) {
                $hex = ($Value -replace '[^0-9a-fA-F]', '')
                $bytes = New-Object byte[] ($hex.Length / 2)
                for ($i = 0; $i -lt $bytes.Length; $i++) { $bytes[$i] = [Convert]::ToByte($hex.Substring($i * 2, 2), 16) }
                return , $bytes
            }
            return , ([byte[]]@($Value | ForEach-Object { [byte]$_ }))
        }
        default { throw "Unknown registry kind '$Kind'" }
    }
}

function Get-RegKindName {
    param([Microsoft.Win32.RegistryValueKind]$K)
    return $K.ToString()
}

function Test-RegDataEqual {
    param([string]$Kind, $Actual, $Desired)
    switch ($Kind) {
        'MultiString' { return (@($Actual) -join "`0") -ceq (@($Desired) -join "`0") }
        'Binary' {
            $a = [byte[]]$Actual; $b = [byte[]]$Desired
            if ($a.Length -ne $b.Length) { return $false }
            for ($i = 0; $i -lt $a.Length; $i++) { if ($a[$i] -ne $b[$i]) { return $false } }
            return $true
        }
        'String' { return ([string]$Actual) -ieq ([string]$Desired) }
        'ExpandString' { return ([string]$Actual) -ieq ([string]$Desired) }
        default { return ([int64]$Actual) -eq ([int64]$Desired) }
    }
}

function ConvertTo-PriorData {
    # Make a registry value JSON-serializable.
    param([string]$Kind, $Data)
    if ($Kind -eq 'Binary') { return , @([byte[]]$Data | ForEach-Object { [int]$_ }) }
    if ($Kind -eq 'MultiString') { return , @($Data) }
    return $Data
}

function Read-RegTarget {
    # Returns @{ KeyExists; ValueExists; Kind; Data }
    param($T, [string]$Name)
    $key = $null
    try {
        $key = $T.Base.OpenSubKey($T.Sub, $false)
        if (-not $key) { return @{ KeyExists = $false; ValueExists = $false } }
        $names = $key.GetValueNames()
        $exists = $false
        foreach ($n in $names) { if ($n -ieq $Name) { $exists = $true; $Name = $n; break } }
        if (-not $exists) { return @{ KeyExists = $true; ValueExists = $false } }
        $kind = Get-RegKindName ($key.GetValueKind($Name))
        $data = $key.GetValue($Name, $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
        return @{ KeyExists = $true; ValueExists = $true; Kind = $kind; Data = $data }
    }
    finally { if ($key) { $key.Close() } }
}

function Test-ActionRegistry {
    param([hashtable]$Action)
    $op = Get-Prop $Action 'Op' 'Set'
    $name = Get-Prop $Action 'Name' ''
    $requireKey = [bool](Get-Prop $Action 'RequireKey' $false)
    $targets = @(Resolve-RegPath $Action.Path)
    if ($targets.Count -eq 0) { return @{ Status = 'NotApplicable'; Detail = 'no user hives available'; Prior = @() } }

    $pending = 0; $applied = 0; $na = 0; $prior = @(); $detail = @()
    foreach ($t in $targets) {
        switch ($op) {
            'Set' {
                $desiredData = ConvertTo-RegData $Action.Kind $Action.Value
                if ($requireKey) {
                    $parent = $null
                    try { $parent = $t.Base.OpenSubKey($t.Sub, $false) } finally { if ($parent) { $parent.Close() } }
                    if (-not $parent) { $na++; continue }
                }
                $cur = Read-RegTarget $t $name
                $entry = @{ Target = $t.Native; Display = $t.Display; KeyExists = $cur.KeyExists; ValueExists = $cur.ValueExists }
                if ($cur.ValueExists) { $entry.Kind = $cur.Kind; $entry.Data = (ConvertTo-PriorData $cur.Kind $cur.Data) }
                $prior += , $entry
                if ($cur.ValueExists -and $cur.Kind -eq $Action.Kind -and (Test-RegDataEqual $Action.Kind $cur.Data $desiredData)) { $applied++ }
                else {
                    $pending++
                    $shown = if ($cur.ValueExists) { "$($cur.Data)" } else { '<absent>' }
                    $detail += "$($t.Display)\$name : $shown -> $($Action.Value)"
                }
            }
            'DeleteValue' {
                $cur = Read-RegTarget $t $name
                $entry = @{ Target = $t.Native; Display = $t.Display; KeyExists = $cur.KeyExists; ValueExists = $cur.ValueExists }
                if ($cur.ValueExists) { $entry.Kind = $cur.Kind; $entry.Data = (ConvertTo-PriorData $cur.Kind $cur.Data); $pending++; $detail += "$($t.Display)\$name : delete" }
                else { $applied++ }
                $prior += , $entry
            }
            'DeleteKey' {
                $k = $null
                try { $k = $t.Base.OpenSubKey($t.Sub, $false) } finally { if ($k) { $k.Close() } }
                $prior += , @{ Target = $t.Native; Display = $t.Display; KeyExists = [bool]$k }
                if ($k) { $pending++; $detail += "$($t.Display) : delete key" } else { $applied++ }
            }
            'EnsureKey' {
                $k = $null
                try { $k = $t.Base.OpenSubKey($t.Sub, $false) } finally { if ($k) { $k.Close() } }
                $prior += , @{ Target = $t.Native; Display = $t.Display; KeyExists = [bool]$k }
                if ($k) { $applied++ } else { $pending++; $detail += "$($t.Display) : create key" }
            }
            default { throw "Registry action: unknown Op '$op'" }
        }
    }
    if ($pending -gt 0) { $status = 'Pending' }
    elseif ($applied -gt 0) { $status = 'Applied' }
    else { $status = 'NotApplicable' }
    return @{ Status = $status; Detail = ($detail -join '; '); Prior = $prior }
}

function Invoke-RegWrite {
    # Executes a scriptblock directly or as TrustedInstaller; an access-denied failure is retried as TrustedInstaller.
    param([bool]$TI, [scriptblock]$Block)
    if ($TI) { Invoke-AsTrustedInstaller $Block; return }
    try { & $Block }
    catch {
        if (-not ((Test-AccessDenied $_) -and (Test-IsAdmin))) { throw }
        Write-Log DEBUG 'Registry key is protected; retrying as TrustedInstaller'
        Invoke-AsTrustedInstaller $Block
    }
}

function Invoke-ActionRegistry {
    param([hashtable]$Action, $Test)
    $op = Get-Prop $Action 'Op' 'Set'
    $name = Get-Prop $Action 'Name' ''
    $ti = [bool](Get-Prop $Action 'TI' $false)
    $requireKey = [bool](Get-Prop $Action 'RequireKey' $false)
    $targets = @(Resolve-RegPath $Action.Path)
    foreach ($t in $targets) {
        $tt = $t
        switch ($op) {
            'Set' {
                $data = ConvertTo-RegData $Action.Kind $Action.Value
                if ($requireKey) {
                    $parent = $null
                    try { $parent = $tt.Base.OpenSubKey($tt.Sub, $false) } finally { if ($parent) { $parent.Close() } }
                    if (-not $parent) { continue }
                }
                $kind = $Action.Kind
                Invoke-RegWrite $ti {
                    $key = $null
                    try {
                        $key = $tt.Base.CreateSubKey($tt.Sub)
                        $key.SetValue($name, $data, [Microsoft.Win32.RegistryValueKind]::$kind)
                    }
                    finally { if ($key) { $key.Close() } }
                }
            }
            'DeleteValue' {
                Invoke-RegWrite $ti {
                    $key = $null
                    try {
                        $key = $tt.Base.OpenSubKey($tt.Sub, $true)
                        if ($key) { $key.DeleteValue($name, $false) }
                    }
                    finally { if ($key) { $key.Close() } }
                }
            }
            'DeleteKey' {
                # Export first so Undo can import it back.
                # A target without the key (e.g. the Default user template) has nothing to export or delete.
                $existing = $null
                try { $existing = $tt.Base.OpenSubKey($tt.Sub, $false) } finally { if ($existing) { $existing.Close() } }
                if (-not $existing) { continue }
                $exportDir = Join-Path $script:RunsDir 'exports'
                if (-not (Test-Path $exportDir)) { New-Item -ItemType Directory -Path $exportDir -Force | Out-Null }
                $file = Join-Path $exportDir (([guid]::NewGuid().ToString('N')) + '.reg')
                # reg.exe writes errors to stderr; under $ErrorActionPreference='Stop' a 2>&1 redirect would throw.
                $prevEap = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
                try { & reg.exe export $tt.Native $file /y 2>&1 | Out-Null } finally { $ErrorActionPreference = $prevEap }
                if ($LASTEXITCODE -eq 0) {
                    foreach ($pe in @($Test.Prior)) { if ($pe.Target -eq $tt.Native) { $pe.ExportFile = $file } }
                }
                Invoke-RegWrite $ti {
                    $tt.Base.DeleteSubKeyTree($tt.Sub, $false)
                }
            }
            'EnsureKey' {
                Invoke-RegWrite $ti {
                    $key = $tt.Base.CreateSubKey($tt.Sub)
                    if ($key) { $key.Close() }
                }
            }
        }
    }
}

function Undo-ActionRegistry {
    param([hashtable]$Action, $Prior)
    $op = Get-Prop $Action 'Op' 'Set'
    $name = Get-Prop $Action 'Name' ''
    $ti = [bool](Get-Prop $Action 'TI' $false)
    foreach ($e in @($Prior)) {
        if ($null -eq $e) { continue }
        $target = Get-Prop $e 'Target'
        if (-not $target) { continue }
        $tt = @(Resolve-RegPath $target)[0]
        # A persisted snapshot may point at a user hive that is not mounted now; skip if the key root is gone.
        switch ($op) {
            { $_ -in @('Set', 'DeleteValue') } {
                if (Get-Prop $e 'ValueExists' $false) {
                    $kind = Get-Prop $e 'Kind'
                    $data = ConvertTo-RegData $kind (Get-Prop $e 'Data')
                    Invoke-RegWrite $ti {
                        $key = $null
                        try { $key = $tt.Base.CreateSubKey($tt.Sub); $key.SetValue($name, $data, [Microsoft.Win32.RegistryValueKind]::$kind) }
                        finally { if ($key) { $key.Close() } }
                    }
                }
                else {
                    Invoke-RegWrite $ti {
                        $key = $null
                        try { $key = $tt.Base.OpenSubKey($tt.Sub, $true); if ($key) { $key.DeleteValue($name, $false) } }
                        finally { if ($key) { $key.Close() } }
                    }
                }
            }
            'EnsureKey' {
                if (-not (Get-Prop $e 'KeyExists' $false)) { Invoke-RegWrite $ti { $tt.Base.DeleteSubKeyTree($tt.Sub, $false) } }
            }
            'DeleteKey' {
                if (-not (Get-Prop $e 'KeyExists' $false)) { continue }   # the key never existed for this target
                $file = Get-Prop $e 'ExportFile'
                if ($file -and (Test-Path -LiteralPath $file)) {
                    $prevEap = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
                    try { & reg.exe import $file 2>&1 | Out-Null } finally { $ErrorActionPreference = $prevEap }
                }
                else { Write-Log WARN "No export available to restore key $target" }
            }
        }
    }
}
