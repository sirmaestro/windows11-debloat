# Script action: 'WinDebloat Ultra Performance' power plan = duplicate of the Ultimate Performance scheme
# (e9a42b02-d5df-448d-aa00-03f14749eb61) under a fixed GUID, renamed and activated.
# Test: applied when the ACTIVE scheme is named 'WinDebloat Ultra Performance'. Prior = GUID of the active scheme before apply.
# Undo: re-activate the prior scheme (Balanced if unknown) and delete our scheme.
# NOTE: scriptblocks do not see this file's variables when called later, so each block defines its own constants.

return @{
    Test = {
        param($Action)
        $name = 'WinDebloat Ultra Performance'
        $active = (& powercfg.exe /getactivescheme 2>$null | Out-String)
        if ($LASTEXITCODE -ne 0 -or -not $active) { return @{ Status = 'Unknown'; Detail = 'powercfg /getactivescheme failed'; Prior = $null } }
        $guid = $null
        if ($active -match '([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})') { $guid = $Matches[1].ToLower() }
        $prior = @{ ActiveGuid = $guid }
        if ($active -match [regex]::Escape("($name)")) { return @{ Status = 'Applied'; Detail = ''; Prior = $prior } }
        return @{ Status = 'Pending'; Detail = "activate '$name' power plan"; Prior = $prior }
    }
    Apply = {
        param($Action, $Test)
        $name = 'WinDebloat Ultra Performance'
        $ours = '5d6a2b1e-7c34-4f0a-9b8e-0c1d2e3f4a5b'
        $ultimate = 'e9a42b02-d5df-448d-aa00-03f14749eb61'
        $list = (& powercfg.exe /list 2>$null | Out-String)
        if ($list -notmatch [regex]::Escape("($name)")) {
            & powercfg.exe /duplicatescheme $ultimate $ours | Out-Null
            if ($LASTEXITCODE -ne 0) { throw "powercfg /duplicatescheme failed (exit $LASTEXITCODE)" }
            & powercfg.exe /changename $ours $name 'Ultimate Performance duplicate created by WinDebloat' | Out-Null
        }
        else {
            if ($list -match ('([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})\s+\(' + [regex]::Escape($name) + '\)')) { $ours = $Matches[1] }
        }
        & powercfg.exe /setactive $ours | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "powercfg /setactive failed (exit $LASTEXITCODE)" }
    }
    Undo = {
        param($Action, $Prior)
        $name = 'WinDebloat Ultra Performance'
        $ours = '5d6a2b1e-7c34-4f0a-9b8e-0c1d2e3f4a5b'
        $balanced = '381b4222-f694-41f0-9685-ff5bb260df2e'
        $list = (& powercfg.exe /list 2>$null | Out-String)
        if ($list -notmatch [regex]::Escape("($name)")) { return }
        $back = $balanced
        if ($Prior -and $Prior.ActiveGuid -and $Prior.ActiveGuid -ne $ours -and $list -match [regex]::Escape($Prior.ActiveGuid)) { $back = $Prior.ActiveGuid }
        & powercfg.exe /setactive $back | Out-Null
        & powercfg.exe /delete $ours | Out-Null
    }
}
