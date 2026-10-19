# Script action: one-shot refresh of the trusted root certificates from Windows Update
# (CertUtil -generateSSTFromWU, then import into LocalMachine\Root and LocalMachine\AuthRoot).
# Idempotence marker: HKLM\SOFTWARE\WinDebloat\State\RootCertsRefreshed (ISO date). Undo does not remove certificates.
# NOTE: scriptblocks returned from a script file do not see this file's variables when called later,
# so every block defines its own constants.

return @{
    Test = {
        param($Action)
        $t = @(Resolve-RegPath 'HKLM\SOFTWARE\WinDebloat\State')[0]
        $cur = Read-RegTarget $t 'RootCertsRefreshed'
        if ($cur.ValueExists) { return @{ Status = 'Applied'; Detail = [string]$cur.Data; Prior = $null } }
        return @{ Status = 'Pending'; Detail = 'root certificates not yet refreshed'; Prior = $null }
    }
    Apply = {
        param($Action, $Test)
        $sst = Join-Path $env:TEMP ('windebloat-roots-' + [guid]::NewGuid().ToString('N') + '.sst')
        try {
            & certutil.exe -generateSSTFromWU $sst 2>&1 | Out-Null
            if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $sst)) { throw "certutil -generateSSTFromWU failed (exit $LASTEXITCODE)" }
            Import-Certificate -FilePath $sst -CertStoreLocation 'Cert:\LocalMachine\Root' -ErrorAction Stop | Out-Null
            Import-Certificate -FilePath $sst -CertStoreLocation 'Cert:\LocalMachine\AuthRoot' -ErrorAction Stop | Out-Null
            $t = @(Resolve-RegPath 'HKLM\SOFTWARE\WinDebloat\State')[0]
            $key = $t.Base.CreateSubKey($t.Sub)
            try { $key.SetValue('RootCertsRefreshed', (Get-Date).ToString('yyyy-MM-dd'), [Microsoft.Win32.RegistryValueKind]::String) }
            finally { $key.Close() }
        }
        finally { Remove-Item -LiteralPath $sst -Force -ErrorAction SilentlyContinue }
    }
    Undo = {
        param($Action, $Prior)
        $t = @(Resolve-RegPath 'HKLM\SOFTWARE\WinDebloat\State')[0]
        $key = $t.Base.OpenSubKey($t.Sub, $true)
        if ($key) { try { $key.DeleteValue('RootCertsRefreshed', $false) } finally { $key.Close() } }
        Write-Log WARN 'Imported root certificates are not removed by undo.'
    }
}
