# Catalog loading, validation and selection.
# catalog/*.psd1:   @{ Tweaks = @( @{ Id=..; Name=..; Risk='low'; Actions=@( @{ Type=...; ... } ) }, ... ) }
# profiles/*.psd1:  @{ Description='...'; Tweaks = @('id', 'prefix.*', ...) }   (order = apply order within a phase)

$script:ValidTypes = @('Registry', 'Service', 'Appx', 'Capability', 'Feature', 'ScheduledTask', 'File', 'Hosts', 'Env', 'Bcdedit', 'Exec', 'Script')
$script:CatalogCache = $null

function Get-CatalogFiles {
    $dir = if ($env:WINDEBLOAT_CATALOG) { $env:WINDEBLOAT_CATALOG } else { Join-Path $script:Root 'catalog' }
    return @(Get-ChildItem -LiteralPath $dir -Filter '*.psd1' -File -ErrorAction SilentlyContinue | Sort-Object Name)
}

function Test-ActionDefinition {
    # Returns an array of problem strings (empty when valid).
    param($A, [string]$Where)
    $p = @()
    if ($A -isnot [hashtable]) { return @("$Where : action is not a hashtable") }
    $type = Get-Prop $A 'Type'
    if ($type -notin $script:ValidTypes) { return @("$Where : unknown action Type '$type'") }
    function Need { param($k) if (-not $A.ContainsKey($k) -or $null -eq $A[$k]) { $script:__p += "$Where ($type) : missing '$k'" } }
    $script:__p = @()
    switch ($type) {
        'Registry' {
            Need 'Path'
            $op = Get-Prop $A 'Op' 'Set'
            if ($op -notin @('Set', 'DeleteValue', 'DeleteKey', 'EnsureKey')) { $script:__p += "$Where (Registry) : bad Op '$op'" }
            if ($op -eq 'Set') {
                Need 'Kind'; Need 'Value'
                if ((Get-Prop $A 'Kind') -notin @('DWord', 'QWord', 'String', 'ExpandString', 'MultiString', 'Binary')) { $script:__p += "$Where (Registry) : bad Kind '$(Get-Prop $A 'Kind')'" }
            }
            if ($op -in @('Set', 'DeleteValue') -and -not $A.ContainsKey('Name')) { $script:__p += "$Where (Registry) : missing 'Name' (use '' for the default value)" }
            if ((Get-Prop $A 'Path') -and ((Get-Prop $A 'Path') -notmatch '^(HKLM|HKCU|HKU|HKCR)[\\:]')) { $script:__p += "$Where (Registry) : Path must start with HKLM\ HKCU\ HKU\ or HKCR\" }
        }
        'Service' { Need 'Name'; Need 'Start'; if ((Get-Prop $A 'Start') -notin $script:ServiceStartMap.Keys) { $script:__p += "$Where (Service) : bad Start '$(Get-Prop $A 'Start')'" } }
        'Appx' { Need 'Name' }
        'Capability' { Need 'Name' }
        'Feature' { Need 'Name'; Need 'State' }
        'ScheduledTask' { Need 'Path' }
        'File' { Need 'Path'; if ((Get-Prop $A 'Op' 'Delete') -eq 'Write') { Need 'Content' } }
        'Hosts' { Need 'Name'; Need 'Entries' }
        'Env' { Need 'Name'; Need 'Value' }
        'Bcdedit' { Need 'Name'; if ((Get-Prop $A 'Op' 'Set') -ne 'DeleteValue') { Need 'Value' } }
        'Exec' { Need 'Test'; Need 'Apply' }
        'Script' {
            Need 'Script'
            if ((Get-Prop $A 'Script') -and -not (Test-Path (Join-Path $script:Root ('engine\scripts\' + $A.Script + '.ps1')))) { $script:__p += "$Where (Script) : engine\scripts\$($A.Script).ps1 not found" }
        }
    }
    $p = @($script:__p); $script:__p = @()
    return $p
}

function Get-Catalog {
    <# Loads and validates every catalog file. Returns an ordered hashtable id -> tweak. Throws on structural errors unless -Lenient. #>
    param([switch]$Force, [switch]$Lenient)
    if ($script:CatalogCache -and -not $Force) { return $script:CatalogCache }
    $all = [ordered]@{}
    $problems = @()
    $seq = 0
    foreach ($f in (Get-CatalogFiles)) {
        try { $data = Import-PowerShellDataFile -LiteralPath $f.FullName }
        catch { $problems += "$($f.Name) : cannot parse ($($_.Exception.Message))"; continue }
        foreach ($t in @($data.Tweaks)) {
            $id = Get-Prop $t 'Id'
            $where = "$($f.Name):$id"
            if (-not $id -or $id -notmatch '^[A-Za-z]+\.[A-Za-z0-9._-]+$') { $problems += "$where : bad or missing Id"; continue }
            if ($all.Contains($id)) { $problems += "$where : duplicate Id"; continue }
            if (-not (Get-Prop $t 'Name')) { $problems += "$where : missing Name" }
            if ((Get-Prop $t 'Risk') -notin @('low', 'med', 'high')) { $problems += "$where : Risk must be low|med|high" }
            $acts = @(Get-Prop $t 'Actions' @())
            if ($acts.Count -eq 0) { $problems += "$where : no Actions" }
            $i = 0
            foreach ($a in $acts) { $problems += @(Test-ActionDefinition $a "$where#$i"); $i++ }
            $t.__File = $f.Name
            $t.__Seq = $seq++
            $all[$id] = $t
        }
    }
    if ($problems.Count -gt 0) {
        foreach ($p in $problems) { Write-Log ERROR "catalog: $p" }
        if (-not $Lenient) { throw "Catalog has $($problems.Count) problem(s); fix them or run 'validate'." }
    }
    $script:CatalogCache = $all
    return $all
}

function Get-ProfilesDir { if ($env:WINDEBLOAT_PROFILES) { return $env:WINDEBLOAT_PROFILES } else { return (Join-Path $script:Root 'profiles') } }
function Get-ProfilePath { param([string]$Name) return (Join-Path (Get-ProfilesDir) "$Name.psd1") }

function Get-ProfileDefinition {
    param([string]$Name)
    $f = Get-ProfilePath $Name
    if (-not (Test-Path -LiteralPath $f)) { throw "Profile '$Name' not found ($f). Available: $((Get-ChildItem (Get-ProfilesDir) -Filter *.psd1 | ForEach-Object BaseName) -join ', ')" }
    return (Import-PowerShellDataFile -LiteralPath $f)
}

function Select-Tweaks {
    <# Resolve a selection into an ordered list of tweak hashtables. Order: Phase, then profile order. #>
    param([string]$Profile, [string[]]$Only, [string[]]$Category)
    $cat = Get-Catalog
    $ids = @()
    if ($Profile) {
        $def = Get-ProfileDefinition $Profile
        foreach ($pat in @($def.Tweaks)) {
            $hit = @($cat.Keys | Where-Object { $_ -like $pat })
            if ($hit.Count -eq 0) { Write-Log WARN "profile '$Profile': '$pat' matches no catalog tweak" }
            $ids += $hit
        }
    }
    else { $ids = @($cat.Keys) }
    if ($Only) {
        $flat = @($Only | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })
        $ids = @($ids | Where-Object { $i = $_; ($flat | Where-Object { $i -like $_ }).Count -gt 0 })
        if (-not $Profile) { }
    }
    if ($Category) {
        $cats = @($Category | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() })
        $ids = @($ids | Where-Object { $p = ($_ -split '\.')[0]; $cats -contains $p })
    }
    $seen = @{}; $out = @(); $n = 0
    foreach ($id in $ids) {
        if ($seen.ContainsKey($id)) { continue }
        $seen[$id] = $true
        $t = $cat[$id]
        $t.__Order = $n++
        $out += $t
    }
    return @($out | Sort-Object @{ Expression = { [int](Get-Prop $_ 'Phase' 20) } }, @{ Expression = { $_.__Order } })
}
