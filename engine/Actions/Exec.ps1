# Action types: Exec, Script
#
# Exec: inline PowerShell code as strings (psd1 data files cannot hold scriptblocks).
#   @{ Type='Exec'; Test='(powercfg /a) -notmatch "Hibernate"'; Apply='powercfg /h off'; Revert='powercfg /h on' }
#   Test must evaluate to $true when the change is ALREADY in place. Revert is optional.
#
# Script: code in engine/scripts/<Name>.ps1, which must RETURN a hashtable of scriptblocks:
#   @{ Test = { param($Action) ... $true/$false or @{Status=..;Detail=..;Prior=..} }
#      Apply = { param($Action, $Test) ... }
#      Undo = { param($Action, $Prior) ... } }
#   @{ Type='Script'; Script='EdgeRemoval'; Args=@{ ... } }

function Invoke-CodeString {
    param([string]$Code, [hashtable]$Action)
    $sb = [scriptblock]::Create($Code)
    return (& $sb)
}

function Test-ActionExec {
    param([hashtable]$Action)
    $r = $false
    try { $r = [bool](Invoke-CodeString $Action.Test $Action) } catch { return @{ Status = 'Unknown'; Detail = "test failed: $($_.Exception.Message)"; Prior = $null } }
    if ($r) { return @{ Status = 'Applied'; Detail = ''; Prior = $null } }
    return @{ Status = 'Pending'; Detail = (Get-Prop $Action 'Note' 'exec'); Prior = $null }
}
function Invoke-ActionExec {
    param([hashtable]$Action, $Test)
    Invoke-CodeString $Action.Apply $Action | Out-Null
}
function Undo-ActionExec {
    param([hashtable]$Action, $Prior)
    $rv = Get-Prop $Action 'Revert'
    if ($rv) { Invoke-CodeString $rv $Action | Out-Null } else { Write-Log WARN "Exec action has no Revert; nothing restored." }
}

function Get-ScriptDef {
    param([hashtable]$Action)
    $file = Join-Path $script:EngineRoot ("scripts\" + $Action.Script + '.ps1')
    if (-not (Test-Path -LiteralPath $file)) { throw "Script action file not found: $file" }
    return (& $file)
}

function Test-ActionScript {
    param([hashtable]$Action)
    $def = Get-ScriptDef $Action
    $r = & $def.Test $Action
    if ($r -is [hashtable]) { return $r }
    if ($r) { return @{ Status = 'Applied'; Detail = ''; Prior = $null } }
    return @{ Status = 'Pending'; Detail = $Action.Script; Prior = $null }
}
function Invoke-ActionScript {
    param([hashtable]$Action, $Test)
    $def = Get-ScriptDef $Action
    & $def.Apply $Action $Test | Out-Null
}
function Undo-ActionScript {
    param([hashtable]$Action, $Prior)
    $def = Get-ScriptDef $Action
    if ($def.Undo) { & $def.Undo $Action $Prior | Out-Null } else { Write-Log WARN "Script '$($Action.Script)' has no Undo." }
}
