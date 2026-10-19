# Misc tweaks (group 1).
@{
    Tweaks = @(
        @{
            Id = 'misc.boot-menu-legacy'
            Name = 'Legacy boot menu (bootmenupolicy Legacy) and lastknowngood yes'
            Risk = 'low'
            Phase = 20
            Source = 'RV'
            Reboot = $true
            Actions = @(
                @{ Type = 'Bcdedit'; Name = 'bootmenupolicy'; Value = 'Legacy' }
                @{ Type = 'Bcdedit'; Name = 'lastknowngood'; Value = 'yes' }
            )
        }
        @{
            Id = 'misc.classic-photo-viewer'
            Name = 'Restore the classic Windows Photo Viewer handler for image types'
            Risk = 'low'
            Phase = 10
            Source = 'RV'
            Note = 'Registers PhotoViewer.dll (HKCR/HKLM, TrustedInstaller) and per-user .ext defaults. File-association defaults may still need to be chosen by the user on 24H2.'
            Actions = @(
                                @{ Type = 'Registry'; Path = 'HKCR\Applications\photoviewer.dll\shell\open'; Name = 'MuiVerb'; Kind = 'String'; Value = '@photoviewer.dll,-3043'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\Applications\photoviewer.dll\shell\open\command'; Name = ''; Kind = 'ExpandString'; Value = '%SystemRoot%\System32\rundll32.exe "%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll", ImageView_Fullscreen %1'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\Applications\photoviewer.dll\shell\open\DropTarget'; Name = 'Clsid'; Kind = 'String'; Value = '{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.Bitmap'; Name = 'ImageOptionFlags'; Kind = 'DWord'; Value = 1; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.Bitmap'; Name = 'FriendlyTypeName'; Kind = 'ExpandString'; Value = '@%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll,-3056'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.Bitmap\DefaultIcon'; Name = ''; Kind = 'String'; Value = '%SystemRoot%\System32\imageres.dll,-70'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.Bitmap\shell\open\command'; Name = ''; Kind = 'ExpandString'; Value = '%SystemRoot%\System32\rundll32.exe "%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll", ImageView_Fullscreen %1'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.Bitmap\shell\open\DropTarget'; Name = 'Clsid'; Kind = 'String'; Value = '{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\Applications\photoviewer.dll\shell\print'; Name = 'NeverDefault'; Kind = 'String'; Value = ''; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\Applications\photoviewer.dll\shell\print\command'; Name = ''; Kind = 'ExpandString'; Value = '%SystemRoot%\System32\rundll32.exe "%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll", ImageView_Fullscreen %1'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\Applications\photoviewer.dll\shell\print\DropTarget'; Name = 'Clsid'; Kind = 'String'; Value = '{60fd46de-f830-4894-a628-6fa81bc0190d}'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.JFIF'; Name = 'EditFlags'; Kind = 'DWord'; Value = 65536; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.JFIF'; Name = 'ImageOptionFlags'; Kind = 'DWord'; Value = 1; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.JFIF'; Name = 'FriendlyTypeName'; Kind = 'ExpandString'; Value = '@%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll,-3055'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.JFIF\DefaultIcon'; Name = ''; Kind = 'String'; Value = '%SystemRoot%\System32\imageres.dll,-72'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.JFIF\shell\open'; Name = 'MuiVerb'; Kind = 'ExpandString'; Value = '@%ProgramFiles%\Windows Photo Viewer\photoviewer.dll,-3043'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.JFIF\shell\open\command'; Name = ''; Kind = 'ExpandString'; Value = '%SystemRoot%\System32\rundll32.exe "%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll", ImageView_Fullscreen %1'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.JFIF\shell\open\DropTarget'; Name = 'Clsid'; Kind = 'String'; Value = '{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.Jpeg'; Name = 'EditFlags'; Kind = 'DWord'; Value = 65536; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.Jpeg'; Name = 'ImageOptionFlags'; Kind = 'DWord'; Value = 1; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.Jpeg'; Name = 'FriendlyTypeName'; Kind = 'ExpandString'; Value = '@%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll,-3055'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.Jpeg\DefaultIcon'; Name = ''; Kind = 'String'; Value = '%SystemRoot%\System32\imageres.dll,-72'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.Jpeg\shell\open'; Name = 'MuiVerb'; Kind = 'ExpandString'; Value = '@%ProgramFiles%\Windows Photo Viewer\photoviewer.dll,-3043'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.Jpeg\shell\open\command'; Name = ''; Kind = 'ExpandString'; Value = '%SystemRoot%\System32\rundll32.exe "%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll", ImageView_Fullscreen %1'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.Jpeg\shell\open\DropTarget'; Name = 'Clsid'; Kind = 'String'; Value = '{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.Gif'; Name = 'ImageOptionFlags'; Kind = 'DWord'; Value = 1; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.Gif'; Name = 'FriendlyTypeName'; Kind = 'ExpandString'; Value = '@%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll,-3057'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.Gif\DefaultIcon'; Name = ''; Kind = 'String'; Value = '%SystemRoot%\System32\imageres.dll,-83'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.Gif\shell\open\command'; Name = ''; Kind = 'ExpandString'; Value = '%SystemRoot%\System32\rundll32.exe "%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll", ImageView_Fullscreen %1'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.Gif\shell\open\DropTarget'; Name = 'Clsid'; Kind = 'String'; Value = '{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.Png'; Name = 'ImageOptionFlags'; Kind = 'DWord'; Value = 1; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.Png'; Name = 'FriendlyTypeName'; Kind = 'ExpandString'; Value = '@%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll,-3057'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.Png\DefaultIcon'; Name = ''; Kind = 'String'; Value = '%SystemRoot%\System32\imageres.dll,-71'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.Png\shell\open\command'; Name = ''; Kind = 'ExpandString'; Value = '%SystemRoot%\System32\rundll32.exe "%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll", ImageView_Fullscreen %1'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.Png\shell\open\DropTarget'; Name = 'Clsid'; Kind = 'String'; Value = '{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.Wdp'; Name = 'EditFlags'; Kind = 'DWord'; Value = 65536; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.Wdp'; Name = 'ImageOptionFlags'; Kind = 'DWord'; Value = 1; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.Wdp\DefaultIcon'; Name = ''; Kind = 'String'; Value = '%SystemRoot%\System32\wmphoto.dll,-400'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.Wdp\shell\open'; Name = 'MuiVerb'; Kind = 'ExpandString'; Value = '@%ProgramFiles%\Windows Photo Viewer\photoviewer.dll,-3043'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.Wdp\shell\open\command'; Name = ''; Kind = 'ExpandString'; Value = '%SystemRoot%\System32\rundll32.exe "%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll", ImageView_Fullscreen %1'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\PhotoViewer.FileAssoc.Wdp\shell\open\DropTarget'; Name = 'Clsid'; Kind = 'String'; Value = '{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\SystemFileAssociations\image\shell\Image Preview\command'; Name = ''; Kind = 'ExpandString'; Value = '%SystemRoot%\System32\rundll32.exe "%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll", ImageView_Fullscreen %1'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCR\SystemFileAssociations\image\shell\Image Preview\DropTarget'; Name = '{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}'; Kind = 'String'; Value = ''; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities'; Name = 'ApplicationDescription'; Kind = 'String'; Value = '@%ProgramFiles%\Windows Photo Viewer\photoviewer.dll,-3069'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities'; Name = 'ApplicationName'; Kind = 'String'; Value = '@%ProgramFiles%\Windows Photo Viewer\photoviewer.dll,-3009'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations'; Name = '.cr2'; Kind = 'String'; Value = 'PhotoViewer.FileAssoc.Tiff'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations'; Name = '.jpg'; Kind = 'String'; Value = 'PhotoViewer.FileAssoc.Jpeg'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations'; Name = '.wdp'; Kind = 'String'; Value = 'PhotoViewer.FileAssoc.Wdp'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations'; Name = '.jfif'; Kind = 'String'; Value = 'PhotoViewer.FileAssoc.JFIF'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations'; Name = '.dib'; Kind = 'String'; Value = 'PhotoViewer.FileAssoc.Bitmap'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations'; Name = '.png'; Kind = 'String'; Value = 'PhotoViewer.FileAssoc.Png'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations'; Name = '.jxr'; Kind = 'String'; Value = 'PhotoViewer.FileAssoc.Wdp'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations'; Name = '.bmp'; Kind = 'String'; Value = 'PhotoViewer.FileAssoc.Bitmap'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations'; Name = '.jpe'; Kind = 'String'; Value = 'PhotoViewer.FileAssoc.Jpeg'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations'; Name = '.jpeg'; Kind = 'String'; Value = 'PhotoViewer.FileAssoc.Jpeg'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations'; Name = '.gif'; Kind = 'String'; Value = 'PhotoViewer.FileAssoc.Gif'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations'; Name = '.tif'; Kind = 'String'; Value = 'PhotoViewer.FileAssoc.Tiff'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations'; Name = '.tiff'; Kind = 'String'; Value = 'PhotoViewer.FileAssoc.Tiff'; TI = $true }
                                @{ Type = 'Registry'; Path = 'HKCU\Software\Classes\.jpg'; Name = ''; Kind = 'String'; Value = 'PhotoViewer.FileAssoc.Tiff' }
                                @{ Type = 'Registry'; Path = 'HKCU\Software\Classes\.jpeg'; Name = ''; Kind = 'String'; Value = 'PhotoViewer.FileAssoc.Tiff' }
                                @{ Type = 'Registry'; Path = 'HKCU\Software\Classes\.gif'; Name = ''; Kind = 'String'; Value = 'PhotoViewer.FileAssoc.Tiff' }
                                @{ Type = 'Registry'; Path = 'HKCU\Software\Classes\.png'; Name = ''; Kind = 'String'; Value = 'PhotoViewer.FileAssoc.Tiff' }
                                @{ Type = 'Registry'; Path = 'HKCU\Software\Classes\.bmp'; Name = ''; Kind = 'String'; Value = 'PhotoViewer.FileAssoc.Tiff' }
                                @{ Type = 'Registry'; Path = 'HKCU\Software\Classes\.tiff'; Name = ''; Kind = 'String'; Value = 'PhotoViewer.FileAssoc.Tiff' }
                                @{ Type = 'Registry'; Path = 'HKCU\Software\Classes\.ico'; Name = ''; Kind = 'String'; Value = 'PhotoViewer.FileAssoc.Tiff' }
                                @{ Type = 'Registry'; Path = 'HKCU\Software\Classes\.tif'; Name = ''; Kind = 'String'; Value = 'PhotoViewer.FileAssoc.Tiff' }
                                @{ Type = 'Registry'; Path = 'HKCU\Software\Classes\.wdp'; Name = ''; Kind = 'String'; Value = 'PhotoViewer.FileAssoc.Wdp' }
                                @{ Type = 'Registry'; Path = 'HKCU\Software\Classes\.jfif'; Name = ''; Kind = 'String'; Value = 'PhotoViewer.FileAssoc.Tiff' }
                                @{ Type = 'Registry'; Path = 'HKCU\Software\Classes\.dib'; Name = ''; Kind = 'String'; Value = 'PhotoViewer.FileAssoc.Tiff' }
                                @{ Type = 'Registry'; Path = 'HKCU\Software\Classes\.jpe'; Name = ''; Kind = 'String'; Value = 'PhotoViewer.FileAssoc.Tiff' }
                                @{ Type = 'Registry'; Path = 'HKCU\Software\Classes\.jxr'; Name = ''; Kind = 'String'; Value = 'PhotoViewer.FileAssoc.Tiff' }
            )
        }
        @{
            Id = 'misc.long-paths'
            Name = 'Win32 long paths enabled (LongPathsEnabled=1)'
            Risk = 'low'
            Phase = 10
            Source = 'OD'
            Reboot = $true
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\CurrentControlSet\Control\FileSystem'; Name = 'LongPathsEnabled'; Kind = 'DWord'; Value = 1 }
            )
        }
        @{
            Id = 'misc.accessibility-hotkeys-off'
            Name = 'Disable Sticky/Filter/Toggle/Mouse Keys and High Contrast hotkeys and Narrator Win+Ctrl+Enter'
            Risk = 'low'
            Phase = 10
            Source = 'WH,WU'
            Note = 'StickyKeys Flags 506 (WU); others use the WH recommended values.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\Accessibility\StickyKeys'; Name = 'Flags'; Kind = 'String'; Value = '506' }
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\Accessibility\Keyboard Response'; Name = 'Flags'; Kind = 'String'; Value = '2' }
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\Accessibility\ToggleKeys'; Name = 'Flags'; Kind = 'String'; Value = '34' }
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\Accessibility\MouseKeys'; Name = 'Flags'; Kind = 'String'; Value = '130' }
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\Accessibility\HighContrast'; Name = 'Flags'; Kind = 'String'; Value = '4194' }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Narrator\NoRoam'; Name = 'WinEnterLaunchEnabled'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'misc.regional-formats'
            Name = 'Regional formats: short date yyyy-MM-dd, Monday first, metric, "." decimal, "," list separator'
            Risk = 'low'
            Phase = 10
            Source = 'WH'
            Note = 'Preference item: values chosen by the author (ISO date, Monday, metric); edit here to taste. Not in the source mech file beyond the option list.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\International'; Name = 'sShortDate'; Kind = 'String'; Value = 'yyyy-MM-dd' }
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\International'; Name = 'iFirstDayOfWeek'; Kind = 'String'; Value = '0' }
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\International'; Name = 'sDecimal'; Kind = 'String'; Value = '.' }
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\International'; Name = 'sList'; Kind = 'String'; Value = ',' }
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\International'; Name = 'iMeasure'; Kind = 'String'; Value = '0' }
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\International'; Name = 'sMonDecimalSep'; Kind = 'String'; Value = '.' }
            )
        }
    )
}
