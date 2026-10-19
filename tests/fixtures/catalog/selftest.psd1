# Self-test catalog: writes ONLY to HKCU\Software\WinDebloatSelfTest and a temp file. Safe to run unelevated.
@{
    Tweaks = @(
        @{
            Id = 'test.dword'; Name = 'Self-test DWord + string'; Risk = 'low'; Phase = 10
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\Software\WinDebloatSelfTest'; Name = 'Flag'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\WinDebloatSelfTest'; Name = 'BigDword'; Kind = 'DWord'; Value = 4294967295 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\WinDebloatSelfTest'; Name = 'Text'; Kind = 'String'; Value = 'hello' }
                @{ Type = 'Registry'; Path = 'HKCU\Software\WinDebloatSelfTest'; Name = 'Multi'; Kind = 'MultiString'; Value = @('a', 'b') }
                @{ Type = 'Registry'; Path = 'HKCU\Software\WinDebloatSelfTest'; Name = 'Bin'; Kind = 'Binary'; Value = '00-01-ff' }
            )
        }
        @{
            Id = 'test.delete'; Name = 'Self-test delete value'; Risk = 'low'; Phase = 20
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\Software\WinDebloatSelfTest'; Name = 'ToDelete'; Op = 'DeleteValue' }
            )
        }
        @{
            Id = 'test.exec'; Name = 'Self-test exec'; Risk = 'low'; Phase = 30
            Actions = @(
                @{ Type = 'Exec'; Test = 'Test-Path "$env:TEMP\windebloat-selftest.flag"'; Apply = 'Set-Content "$env:TEMP\windebloat-selftest.flag" 1'; Revert = 'Remove-Item "$env:TEMP\windebloat-selftest.flag" -Force' }
            )
        }
        @{
            Id = 'test.service-na'; Name = 'Self-test missing service is N/A'; Risk = 'low'
            Actions = @( @{ Type = 'Service'; Name = 'NoSuchServiceXyz'; Start = 'Disabled' } )
        }
        @{
            Id = 'test.badbuild'; Name = 'Self-test build gate'; Risk = 'low'; Builds = @{ Min = 99999 }
            Actions = @( @{ Type = 'Registry'; Path = 'HKCU\Software\WinDebloatSelfTest'; Name = 'Never'; Kind = 'DWord'; Value = 1 } )
        }
    )
}
