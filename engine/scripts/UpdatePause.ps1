# Script action: pause Windows Update until 2038-01-19 (Revision Tool's wu-pause-updates approach).
# The 'start' times use the current date so the Windows Update UI shows a sane pause window.
# Values live in HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings (REG_SZ, ISO 8601 UTC) plus FlightSettingsMaxPauseDays (DWORD).
# 'resume' deletes all seven values; Windows can also reset them itself after feature updates or Settings use (drift).
# Returns the hashtable of scriptblocks expected by the 'Script' action type.
# NOTE: scriptblocks returned from a script file do not see this file's variables when called later,
# so every block defines its own constants.

return @{
    Test = {
        param($Action)
        $settingsPath = 'HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'
        $endTime = '2038-01-19T03:14:07Z'; $maxDays = 5269
        $startNames = @('PauseFeatureUpdatesStartTime', 'PauseQualityUpdatesStartTime', 'PauseUpdatesStartTime')
        $endNames = @('PauseFeatureUpdatesEndTime', 'PauseQualityUpdatesEndTime', 'PauseUpdatesExpiryTime')
        $t = @(Resolve-RegPath $settingsPath)[0]
        $prior = @(); $ok = $true
        foreach ($n in $endNames) {
            $cur = Read-RegTarget $t $n
            $prior += @{ Name = $n; Existed = $cur.ValueExists; Value = $cur.Data }
            if (-not $cur.ValueExists -or [string]$cur.Data -ne $endTime) { $ok = $false }
        }
        foreach ($n in $startNames) {
            $cur = Read-RegTarget $t $n
            $prior += @{ Name = $n; Existed = $cur.ValueExists; Value = $cur.Data }
            if (-not $cur.ValueExists) { $ok = $false }
        }
        $cur = Read-RegTarget $t 'FlightSettingsMaxPauseDays'
        $prior += @{ Name = 'FlightSettingsMaxPauseDays'; Existed = $cur.ValueExists; Value = $cur.Data }
        if (-not $cur.ValueExists -or [int]$cur.Data -lt $maxDays) { $ok = $false }
        if ($ok) { return @{ Status = 'Applied'; Detail = ''; Prior = $prior } }
        return @{ Status = 'Pending'; Detail = "pause updates until $endTime"; Prior = $prior }
    }
    Apply = {
        param($Action, $Test)
        $settingsPath = 'HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'
        $endTime = '2038-01-19T03:14:07Z'; $maxDays = 5269
        $startNames = @('PauseFeatureUpdatesStartTime', 'PauseQualityUpdatesStartTime', 'PauseUpdatesStartTime')
        $endNames = @('PauseFeatureUpdatesEndTime', 'PauseQualityUpdatesEndTime', 'PauseUpdatesExpiryTime')
        $t = @(Resolve-RegPath $settingsPath)[0]
        $now = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        $key = $t.Base.CreateSubKey($t.Sub)
        try {
            $key.SetValue('FlightSettingsMaxPauseDays', [int]$maxDays, [Microsoft.Win32.RegistryValueKind]::DWord)
            foreach ($n in $startNames) { $key.SetValue($n, $now, [Microsoft.Win32.RegistryValueKind]::String) }
            foreach ($n in $endNames) { $key.SetValue($n, $endTime, [Microsoft.Win32.RegistryValueKind]::String) }
        }
        finally { $key.Close() }
    }
    Undo = {
        param($Action, $Prior)
        $settingsPath = 'HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'
        $names = @('PauseFeatureUpdatesStartTime', 'PauseQualityUpdatesStartTime', 'PauseUpdatesStartTime', 'PauseFeatureUpdatesEndTime', 'PauseQualityUpdatesEndTime', 'PauseUpdatesExpiryTime', 'FlightSettingsMaxPauseDays')
        $t = @(Resolve-RegPath $settingsPath)[0]
        $key = $t.Base.OpenSubKey($t.Sub, $true)
        if (-not $key) { return }
        try { foreach ($n in $names) { $key.DeleteValue($n, $false) } }
        finally { $key.Close() }
    }
}
