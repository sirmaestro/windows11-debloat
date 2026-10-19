# Script action: deep idle C6 disabled in the 'WinDebloat Ultra Performance' plan
# (idle promote 7b224883-... = 100, idle demote 4b92d758-... = 80, AC, SUB_PROCESSOR 54533251-...).
# N/A when the plan does not exist (apply pwr.high-performance-plan first).
# NOTE: each scriptblock defines its own constants.

return @{
    Test = {
        param($Action)
        $ours = '5d6a2b1e-7c34-4f0a-9b8e-0c1d2e3f4a5b'
        $sub = '54533251-82be-4824-96c1-47b60b740d00'
        $list = (& powercfg.exe /list 2>$null | Out-String)
        if ($LASTEXITCODE -ne 0 -or -not $list) { return @{ Status = 'Unknown'; Detail = 'powercfg /list failed'; Prior = $null } }
        if ($list -notmatch [regex]::Escape($ours)) { return @{ Status = 'NotApplicable'; Detail = 'WinDebloat Ultra Performance plan not present'; Prior = $null } }
        $vals = @{}
        foreach ($s in @('7b224883-b3cc-4d79-819f-8374152cbe7c', '4b92d758-5a24-4851-a470-815d78aee119')) {
            $q = (& powercfg.exe /query $ours $sub $s 2>$null | Out-String)
            if ($q -match 'Current AC Power Setting Index:\s*0x([0-9a-fA-F]+)') { $vals[$s] = [Convert]::ToInt32($Matches[1], 16) } else { $vals[$s] = $null }
        }
        $prior = @{ Promote = $vals['7b224883-b3cc-4d79-819f-8374152cbe7c']; Demote = $vals['4b92d758-5a24-4851-a470-815d78aee119'] }
        if ($prior.Promote -eq 100 -and $prior.Demote -eq 80) { return @{ Status = 'Applied'; Detail = ''; Prior = $prior } }
        return @{ Status = 'Pending'; Detail = 'idle promote/demote -> 100/80'; Prior = $prior }
    }
    Apply = {
        param($Action, $Test)
        $ours = '5d6a2b1e-7c34-4f0a-9b8e-0c1d2e3f4a5b'
        $sub = '54533251-82be-4824-96c1-47b60b740d00'
        & powercfg.exe /setacvalueindex $ours $sub '7b224883-b3cc-4d79-819f-8374152cbe7c' 100 | Out-Null
        & powercfg.exe /setacvalueindex $ours $sub '4b92d758-5a24-4851-a470-815d78aee119' 80 | Out-Null
        $act = (& powercfg.exe /getactivescheme 2>$null | Out-String)
        if ($act -match [regex]::Escape($ours)) { & powercfg.exe /setactive $ours | Out-Null }
    }
    Undo = {
        param($Action, $Prior)
        $ours = '5d6a2b1e-7c34-4f0a-9b8e-0c1d2e3f4a5b'
        $sub = '54533251-82be-4824-96c1-47b60b740d00'
        $list = (& powercfg.exe /list 2>$null | Out-String)
        if ($list -notmatch [regex]::Escape($ours)) { return }
        $p = 60; $d = 40
        if ($Prior -and $null -ne $Prior.Promote) { $p = [int]$Prior.Promote }
        if ($Prior -and $null -ne $Prior.Demote) { $d = [int]$Prior.Demote }
        if ($p -eq 100) { $p = 60 }
        if ($d -eq 80) { $d = 40 }
        & powercfg.exe /setacvalueindex $ours $sub '7b224883-b3cc-4d79-819f-8374152cbe7c' $p | Out-Null
        & powercfg.exe /setacvalueindex $ours $sub '4b92d758-5a24-4851-a470-815d78aee119' $d | Out-Null
    }
}
