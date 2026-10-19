# Group 2 catalog: appx. Generated from docs/tweaks/group2.mech.md.
@{
    Tweaks = @(
        @{
            Id = 'appx.deprovision-markers'
            Name = 'Deprovision keys (AppxAllUserStore\Deprovisioned) for ~55 packages so updates/new users don''t reinstall them: stops reinstall after feature updates and for new profiles'
            Risk = 'med'
            Phase = 10
            Source = 'RV,RT'
            Note = 'Excludes Notepad, Calculator, Paint and SecHealthUI (kept by the user).'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.549981C3F5F10_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.BingNews_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.BingWeather_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.ECApp_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.GetHelp_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.Getstarted_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.MicrosoftEdge_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.MicrosoftEdgeDevToolsClient_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.MicrosoftSolitaireCollection_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.People_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.PowerAutomateDesktop_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.Todos_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.Windows.Apprep.ChxApp_cw5n1h2txyewy'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.Windows.PeopleExperienceHost_cw5n1h2txyewy'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.Windows.Photos_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.Windows.SecureAssessmentBrowser_cw5n1h2txyewy'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.WindowsAlarms_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.WindowsCamera_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.WindowsFeedbackHub_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.WindowsMaps_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.WindowsSoundRecorder_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.ZuneMusic_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.ZuneVideo_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\MicrosoftWindows.Client.WebExperience_cw5n1h2txyewy'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\microsoft.windowscommunicationsapps_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.Advertising.Xaml_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.Microsoft3DViewer_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.MixedReality.Portal_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.MSPaint_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\clipchamp.clipchamp_yxz26nhyzhsrt'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\MicrosoftCorporationII.QuickAssist_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\MicrosoftCorporationII.MicrosoftFamily_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.Whiteboard_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\microsoft.microsoftskydrive_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.MicrosoftTeamsforSurfaceHub_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\MicrosoftCorporationII.MailforSurfaceHub_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.MicrosoftPowerBIForWindows_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.SkypeApp_kzf8qxf38zg5c'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.Office.OneNote_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.Office.Excel_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.Office.PowerPoint_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.Office.Word_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.Windows.DevHome_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.OutlookForWindows_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\MSTeams_8wekyb3d8bbwe'; Op = 'EnsureKey'; TI = $true }
            )
        }
        @{
            Id = 'appx.block-outlook-devhome-autoinstall'
            Name = 'Blocks OOBE/Orchestrator auto-install of new Outlook and Dev Home on later updates'
            Risk = 'low'
            Phase = 10
            Source = 'RV'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe'; Name = 'BlockedOobeUpdaters'; Kind = 'String'; Value = '["MS_Outlook"]'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\OutlookUpdate'; Op = 'DeleteKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\DevHomeUpdate'; Op = 'DeleteKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator\UScheduler\DevHomeUpdate'; Name = 'workCompleted'; Kind = 'DWord'; Value = 1; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator\UScheduler\OutlookUpdate'; Name = 'workCompleted'; Kind = 'DWord'; Value = 1; TI = $true }
            )
        }
        @{
            Id = 'appx.preinstalled-apps-block'
            Name = 'ContentDeliveryManager PreInstalled/OEM/SilentInstalledApps = 0 so Windows stops silently pushing apps'
            Risk = 'low'
            Phase = 10
            Source = 'RV,OD,WH'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'PreInstalledAppsEnabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'PreInstalledAppsEverEnabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'OemPreInstalledAppsEnabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SilentInstalledAppsEnabled'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'appx.tips'
            Name = 'Tips / Get Started (Microsoft.Getstarted)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.Getstarted' }
                @{ Type = 'Appx'; Name = 'Microsoft.WindowsTips' }
            )
        }
        @{
            Id = 'appx.office-hub'
            Name = 'Microsoft 365 / Office hub (Microsoft.MicrosoftOfficeHub)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WU,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.MicrosoftOfficeHub' }
            )
        }
        @{
            Id = 'appx.people'
            Name = 'People (Microsoft.People)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.People' }
            )
        }
        @{
            Id = 'appx.widgets-platform-runtime'
            Name = 'Widgets Platform Runtime (Microsoft.WidgetsPlatformRuntime)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.WidgetsPlatformRuntime' }
            )
        }
        @{
            Id = 'appx.mail-calendar'
            Name = 'Mail and Calendar (microsoft.windowscommunicationsapps)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'microsoft.windowscommunicationsapps' }
            )
        }
        @{
            Id = 'appx.bing-search'
            Name = 'Bing Search (Microsoft.BingSearch)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WU,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.BingSearch' }
            )
        }
        @{
            Id = 'appx.maps'
            Name = 'Maps (Microsoft.WindowsMaps)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WU,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.WindowsMaps' }
            )
        }
        @{
            Id = 'appx.onenote'
            Name = 'OneNote for Windows (Microsoft.Office.OneNote)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WH,OD,WU'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.Office.OneNote' }
                @{ Type = 'Appx'; Name = 'Microsoft.Office.Sway' }
            )
        }
        @{
            Id = 'appx.bing-weather'
            Name = 'MSN Weather (Microsoft.BingWeather)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WU,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.BingWeather' }
            )
        }
        @{
            Id = 'appx.photos'
            Name = 'Photos (Microsoft.Windows.Photos)'
            Risk = 'med'
            Phase = 30
            Source = 'RV,WU,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.Windows.Photos' }
            )
        }
        @{
            Id = 'appx.solitaire'
            Name = 'Solitaire Collection (Microsoft.MicrosoftSolitaireCollection)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WU,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.MicrosoftSolitaireCollection' }
            )
        }
        @{
            Id = 'appx.secure-assessment-browser'
            Name = 'Secure Assessment Browser (Microsoft.Windows.SecureAssessmentBrowser)'
            Risk = 'low'
            Phase = 30
            Source = 'RV'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.Windows.SecureAssessmentBrowser' }
            )
        }
        @{
            Id = 'appx.skype'
            Name = 'Skype (Microsoft.SkypeApp)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.SkypeApp' }
            )
        }
        @{
            Id = 'appx.feedback-hub'
            Name = 'Feedback Hub (Microsoft.WindowsFeedbackHub)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WU,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.WindowsFeedbackHub' }
            )
        }
        @{
            Id = 'appx.windows-aihub'
            Name = 'Windows.AIHub appx'
            Risk = 'low'
            Phase = 30
            Source = 'OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.Windows.AIHub' }
            )
        }
        @{
            Id = 'appx.devhome'
            Name = 'Dev Home / Windows Advanced Settings (Microsoft.Windows.DevHome)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WU,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.Windows.DevHome' }
            )
        }
        @{
            Id = 'appx.family-safety'
            Name = 'Microsoft Family (MicrosoftCorporationII.MicrosoftFamily)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'MicrosoftCorporationII.MicrosoftFamily' }
            )
        }
        @{
            Id = 'appx.get-help'
            Name = 'Get Help (Microsoft.GetHelp)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WU,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.GetHelp' }
            )
        }
        @{
            Id = 'appx.crossdevice'
            Name = 'Cross Device / Mobile Devices (MicrosoftWindows.CrossDevice)'
            Risk = 'med'
            Phase = 30
            Source = 'RV,WU,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'MicrosoftWindows.CrossDevice' }
            )
        }
        @{
            Id = 'appx.movies-tv'
            Name = 'Movies & TV (Microsoft.ZuneVideo)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WU,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.ZuneVideo' }
            )
        }
        @{
            Id = 'appx.paint3d'
            Name = 'Paint 3D (Microsoft.MSPaint)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.MSPaint' }
            )
        }
        @{
            Id = 'appx.clipchamp'
            Name = 'Clipchamp (Clipchamp.Clipchamp)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WU,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Clipchamp.Clipchamp' }
            )
        }
        @{
            Id = 'appx.outlook-new'
            Name = 'Outlook for Windows (Microsoft.OutlookForWindows, OutlookPWA)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WU,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.OutlookForWindows' }
                @{ Type = 'Appx'; Name = 'OutlookPWA' }
            )
        }
        @{
            Id = 'appx.camera'
            Name = 'Camera (Microsoft.WindowsCamera)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WU,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.WindowsCamera' }
            )
        }
        @{
            Id = 'appx.xbox-app'
            Name = 'Xbox app (Microsoft.GamingApp, Microsoft.XboxApp)'
            Risk = 'low'
            Phase = 30
            Source = 'WU,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.GamingApp' }
                @{ Type = 'Appx'; Name = 'Microsoft.XboxApp' }
            )
        }
        @{
            Id = 'appx.xbox-speech-overlay'
            Name = 'Xbox Speech To Text Overlay (Microsoft.XboxSpeechToTextOverlay)'
            Risk = 'low'
            Phase = 30
            Source = 'WU,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.XboxSpeechToTextOverlay' }
            )
        }
        @{
            Id = 'appx.power-automate'
            Name = 'Power Automate (Microsoft.PowerAutomateDesktop)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WU,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.PowerAutomateDesktop' }
            )
        }
        @{
            Id = 'appx.legacy-win10-leftovers'
            Name = 'Messaging, OneConnect, Wallet, Print3D, 3DBuilder, Office.Sway, MicrosoftJournal, NetworkSpeedTest, MinecraftUWP'
            Risk = 'low'
            Phase = 30
            Source = 'OD,WU'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.Messaging' }
                @{ Type = 'Appx'; Name = 'Microsoft.OneConnect' }
                @{ Type = 'Appx'; Name = 'Microsoft.Wallet' }
                @{ Type = 'Appx'; Name = 'Microsoft.MSWallet' }
                @{ Type = 'Appx'; Name = 'Microsoft.Print3D' }
                @{ Type = 'Appx'; Name = 'Microsoft.3DBuilder' }
                @{ Type = 'Appx'; Name = 'Microsoft.Office.Sway' }
                @{ Type = 'Appx'; Name = 'Microsoft.MicrosoftJournal' }
                @{ Type = 'Appx'; Name = 'Microsoft.NetworkSpeedTest' }
                @{ Type = 'Appx'; Name = 'Microsoft.MinecraftUWP' }
            )
        }
        @{
            Id = 'appx.office-desktop-stubs'
            Name = 'Office Word/Excel/PowerPoint store stubs (Microsoft.Office.Word/Excel/PowerPoint)'
            Risk = 'low'
            Phase = 30
            Source = 'RV'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.Office.Word' }
                @{ Type = 'Appx'; Name = 'Microsoft.Office.Excel' }
                @{ Type = 'Appx'; Name = 'Microsoft.Office.PowerPoint' }
            )
        }
        @{
            Id = 'appx.bing-extras'
            Name = 'Bing Finance/Sports/FoodAndDrink/HealthAndFitness/Travel/Translator + MicrosoftStart'
            Risk = 'low'
            Phase = 30
            Source = 'OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.BingFinance' }
                @{ Type = 'Appx'; Name = 'Microsoft.BingSports' }
                @{ Type = 'Appx'; Name = 'Microsoft.BingFoodAndDrink' }
                @{ Type = 'Appx'; Name = 'Microsoft.BingHealthAndFitness' }
                @{ Type = 'Appx'; Name = 'Microsoft.BingTravel' }
                @{ Type = 'Appx'; Name = 'Microsoft.BingTranslator' }
                @{ Type = 'Appx'; Name = 'Microsoft.MicrosoftStart' }
            )
        }
        @{
            Id = 'appx.spotify'
            Name = 'Spotify (SpotifyAB.SpotifyMusic)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'SpotifyAB.SpotifyMusic' }
            )
        }
        @{
            Id = 'appx.third-party-promos'
            Name = 'OEM/sponsored third-party stubs (Disney, Amazon, Netflix, TikTok, Candy Crush, Instagram, Facebook, LinkedIn, Hulu, WinZip, Adobe Express, etc.)'
            Risk = 'low'
            Phase = 30
            Source = 'OD'
            Note = 'Includes DolbyAccess (spatial audio app); untick if needed.'
            Actions = @(
                @{ Type = 'Appx'; Name = '*Drawboard.DrawboardPDF*' }
                @{ Type = 'Appx'; Name = '*Disney.37853FC22B2CE*' }
                @{ Type = 'Appx'; Name = '*Amazon.com.Amazon*' }
                @{ Type = 'Appx'; Name = '*4DF9E0F8.Netflix*' }
                @{ Type = 'Appx'; Name = '*BytedancePte.Ltd.TikTok*' }
                @{ Type = 'Appx'; Name = '*king.com.CandyCrushSaga*' }
                @{ Type = 'Appx'; Name = '*king.com.CandyCrushSodaSaga*' }
                @{ Type = 'Appx'; Name = '*king.com.BubbleWitch3Saga*' }
                @{ Type = 'Appx'; Name = '*AmazonVideo.PrimeVideo*' }
                @{ Type = 'Appx'; Name = '*Facebook.Instagram*' }
                @{ Type = 'Appx'; Name = '*FACEBOOK.FACEBOOK*' }
                @{ Type = 'Appx'; Name = '*7EE7776C.LinkedInforWindows*' }
                @{ Type = 'Appx'; Name = '*Flipboard*' }
                @{ Type = 'Appx'; Name = '*iHeartRadio*' }
                @{ Type = 'Appx'; Name = '*PandoraMediaInc*' }
                @{ Type = 'Appx'; Name = '*TuneInRadio*' }
                @{ Type = 'Appx'; Name = '*Duolingo-LearnLanguagesforFree*' }
                @{ Type = 'Appx'; Name = '*PicsArt-PhotoStudio*' }
                @{ Type = 'Appx'; Name = '*WinZipUniversal*' }
                @{ Type = 'Appx'; Name = '*AdobeSystemsIncorporated.AdobePhotoshopExpress*' }
                @{ Type = 'Appx'; Name = '*OneCalendar*' }
                @{ Type = 'Appx'; Name = '*NYTCrossword*' }
                @{ Type = 'Appx'; Name = '*MarchofEmpires*' }
                @{ Type = 'Appx'; Name = '*flaregamesGmbH.RoyalRevolt*' }
                @{ Type = 'Appx'; Name = '*Asphalt8Airborne*' }
                @{ Type = 'Appx'; Name = '*FarmVille2CountryEscape*' }
                @{ Type = 'Appx'; Name = '*HiddenCity*' }
                @{ Type = 'Appx'; Name = '*CaesarsSlotsFreeCasino*' }
                @{ Type = 'Appx'; Name = '*COOKINGFEVER*' }
                @{ Type = 'Appx'; Name = '*DisneyMagicKingdoms*' }
                @{ Type = 'Appx'; Name = '*PhototasticCollage*' }
                @{ Type = 'Appx'; Name = '*AutodeskSketchBook*' }
                @{ Type = 'Appx'; Name = '*PolarrPhotoEditorAcademicEdition*' }
                @{ Type = 'Appx'; Name = '*Sidia.LiveWallpaper*' }
                @{ Type = 'Appx'; Name = '*HULULLC.HULUPLUS*' }
                @{ Type = 'Appx'; Name = '*SlingTV*' }
                @{ Type = 'Appx'; Name = '*DolbyLaboratories.DolbyAccess*' }
            )
        }
        @{
            Id = 'appx.bing-news'
            Name = 'Microsoft News (Microsoft.BingNews, alias Microsoft.News)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WU,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.BingNews' }
                @{ Type = 'Appx'; Name = 'Microsoft.News' }
            )
        }
        @{
            Id = 'appx.3d-viewer'
            Name = '3D Viewer (Microsoft.Microsoft3DViewer)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.Microsoft3DViewer' }
            )
        }
        @{
            Id = 'appx.todo'
            Name = 'Microsoft To Do (Microsoft.Todos)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WU,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.Todos' }
            )
        }
        @{
            Id = 'appx.start-experiences'
            Name = 'Start Experiences App (Microsoft.StartExperiencesApp)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WU,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.StartExperiencesApp' }
            )
        }
        @{
            Id = 'appx.m365-companions'
            Name = 'Microsoft 365 Companions (Microsoft.M365Companions)'
            Risk = 'low'
            Phase = 30
            Source = 'OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.M365Companions' }
            )
        }
        @{
            Id = 'appx.alarms-clock'
            Name = 'Clock / Alarms (Microsoft.WindowsAlarms)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WU,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.WindowsAlarms' }
            )
        }
        @{
            Id = 'appx.sound-recorder'
            Name = 'Sound Recorder (Microsoft.WindowsSoundRecorder)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WU,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.WindowsSoundRecorder' }
            )
        }
        @{
            Id = 'appx.mixed-reality-portal'
            Name = 'Mixed Reality Portal (Microsoft.MixedReality.Portal)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.MixedReality.Portal' }
            )
        }
        @{
            Id = 'appx.yourphone'
            Name = 'Phone Link (Microsoft.YourPhone)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WU,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.YourPhone' }
            )
        }
        @{
            Id = 'appx.whiteboard'
            Name = 'Whiteboard (Microsoft.Whiteboard)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.Whiteboard' }
            )
        }
        @{
            Id = 'appx.media-player'
            Name = 'Media Player (Microsoft.ZuneMusic)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WU,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.ZuneMusic' }
            )
        }
        @{
            Id = 'appx.surfacehub-apps'
            Name = 'Teams and Mail for Surface Hub (Microsoft.MicrosoftTeamsforSurfaceHub, MicrosoftCorporationII.MailforSurfaceHub)'
            Risk = 'low'
            Phase = 30
            Source = 'RV'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.MicrosoftTeamsforSurfaceHub' }
                @{ Type = 'Appx'; Name = 'MicrosoftCorporationII.MailforSurfaceHub' }
            )
        }
        @{
            Id = 'appx.quick-assist'
            Name = 'Quick Assist Store app (MicrosoftCorporationII.QuickAssist)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WU,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'MicrosoftCorporationII.QuickAssist' }
            )
        }
        @{
            Id = 'appx.powerbi'
            Name = 'Power BI (Microsoft.MicrosoftPowerBIForWindows)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.MicrosoftPowerBIForWindows' }
            )
        }
        @{
            Id = 'appx.cortana'
            Name = 'Cortana (Microsoft.549981C3F5F10)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.549981C3F5F10' }
            )
        }
        @{
            Id = 'appx.sticky-notes'
            Name = 'Sticky Notes (Microsoft.MicrosoftStickyNotes)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WU,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.MicrosoftStickyNotes' }
            )
        }
        @{
            Id = 'appx.widgets-webexperience'
            Name = 'Widgets board (MicrosoftWindows.Client.WebExperience)'
            Risk = 'med'
            Phase = 30
            Source = 'RV,OD'
            Note = 'Policies stop Windows reinstalling the Widgets package.'
            Actions = @(
                @{ Type = 'Appx'; Name = 'MicrosoftWindows.Client.WebExperience' }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Dsh'; Name = 'AllowNewsAndInterests'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds'; Name = 'EnableFeeds'; Kind = 'DWord'; Value = 0 }
            )
        }
    )
}
