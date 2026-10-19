@{
    Tweaks = @(
        @{
            Id = 'start.pinned-folders-hidden'; Name = 'Hide folder shortcuts next to Start power button'; Risk = 'low'; Phase = 50; Source = 'RV'; RestartExplorer = $true
            Note = 'PolicyManager AllowPinnedFolder*=0 (Settings stays shown); bundles NoResolveSearch=1'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start'; Name = 'AllowPinnedFolderDocuments'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start'; Name = 'AllowPinnedFolderDocuments_ProviderSet'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start'; Name = 'AllowPinnedFolderDownloads'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start'; Name = 'AllowPinnedFolderDownloads_ProviderSet'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start'; Name = 'AllowPinnedFolderFileExplorer'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start'; Name = 'AllowPinnedFolderFileExplorer_ProviderSet'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start'; Name = 'AllowPinnedFolderHomeGroup'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start'; Name = 'AllowPinnedFolderHomeGroup_ProviderSet'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start'; Name = 'AllowPinnedFolderMusic'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start'; Name = 'AllowPinnedFolderMusic_ProviderSet'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start'; Name = 'AllowPinnedFolderNetwork'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start'; Name = 'AllowPinnedFolderNetwork_ProviderSet'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start'; Name = 'AllowPinnedFolderPersonalFolder'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start'; Name = 'AllowPinnedFolderPersonalFolder_ProviderSet'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start'; Name = 'AllowPinnedFolderPictures'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start'; Name = 'AllowPinnedFolderPictures_ProviderSet'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start'; Name = 'AllowPinnedFolderVideos'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start'; Name = 'AllowPinnedFolderVideos_ProviderSet'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start'; Name = 'AllowPinnedFolderSettings'; Kind = 'DWord'; Value = 1; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start'; Name = 'AllowPinnedFolderSettings_ProviderSet'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'NoResolveSearch'; Kind = 'DWord'; Value = 1 }
            )
        }
        @{
            Id = 'start.recommendations-account-notifs-off'; Name = 'Turn off Start Iris recommendations and account notifications'; Risk = 'low'; Phase = 50; Source = 'RV,WH'; RestartExplorer = $true
            Note = 'Start_IrisRecommendations=0, Start_AccountNotifications=0'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'Start_IrisRecommendations'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'Start_AccountNotifications'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'start.taskbar-search-mode'; Name = 'Taskbar search box: icon only'; Risk = 'low'; Phase = 50; Source = 'RV,WU,OD,WH'; RestartExplorer = $true
            Note = 'ReviOS value SearchboxTaskbarMode=1 (icon only); WU/WH use 0 (hidden)'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Search'; Name = 'SearchboxTaskbarMode'; Kind = 'DWord'; Value = 1 }
            )
        }
        @{
            Id = 'start.cortana-cloud-search-off'; Name = 'Windows Search policy: cloud, Cortana, web search, location off'; Risk = 'low'; Phase = 10; Source = 'RV'
            Note = 'ReviOS writes AllowCortana=1 (sic); intended 0 used here'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search'; Name = 'AllowCloudSearch'; Kind = 'DWord'; Value = 2; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search'; Name = 'AllowCortanaAboveLock'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search'; Name = 'AllowCortana'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search'; Name = 'AllowCortanaInAAD'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search'; Name = 'AllowCortanaInAADPathOOBE'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search'; Name = 'AllowSearchToUseLocation'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search'; Name = 'ConnectedSearchUseWeb'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search'; Name = 'ConnectedSearchUseWebOverMeteredConnections'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search'; Name = 'DisableWebSearch'; Kind = 'DWord'; Value = 1; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search'; Name = 'ConnectedSearchPrivacy'; Kind = 'DWord'; Value = 3; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Speech_OneCore\Preferences'; Name = 'VoiceActivationEnableAboveLockscreen'; Kind = 'DWord'; Value = 0; TI = $true }
            )
        }
        @{
            Id = 'start.task-view-off'; Name = 'Hide Task View button'; Risk = 'low'; Phase = 50; Source = 'RV,WU,OD,WH'; RestartExplorer = $true
            Note = 'ShowTaskViewButton=0'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'ShowTaskViewButton'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'start.widgets-off'; Name = 'Disable Widgets and News/Interests'; Risk = 'low'; Phase = 50; Source = 'RV,WU,OD,WH'; RestartExplorer = $true
            Note = 'Policies + ShellFeedsTaskbarViewMode=2 + TaskbarDa=0 (Optional: Windows blocks writes to these two values on 24H2+; the Dsh/Feeds policies hide Widgets regardless); Appx removal elsewhere'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds'; Name = 'EnableFeeds'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Feeds'; Name = 'ShellFeedsTaskbarViewMode'; Kind = 'DWord'; Value = 2; Optional = $true }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'TaskbarDa'; Kind = 'DWord'; Value = 0; Optional = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Dsh'; Name = 'AllowNewsAndInterests'; Kind = 'DWord'; Value = 0; TI = $true }
            )
        }
        @{
            Id = 'start.chat-meetnow-off'; Name = 'Hide taskbar Chat, Meet Now and People bar'; Risk = 'low'; Phase = 50; Source = 'RV,WU,OD'; RestartExplorer = $true
            Note = 'ChatIcon=3, TaskbarMn=0, HideSCAMeetNow (HKCU+HKLM), HidePeopleBar'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Chat'; Name = 'ChatIcon'; Kind = 'DWord'; Value = 3; TI = $true }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'TaskbarMn'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'HideSCAMeetNow'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'HideSCAMeetNow'; Kind = 'DWord'; Value = 1; TI = $true }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Policies\Microsoft\Windows\Explorer'; Name = 'HidePeopleBar'; Kind = 'DWord'; Value = 1 }
            )
        }
        @{
            Id = 'start.end-task'; Name = 'Add "End task" to taskbar right-click menu'; Risk = 'low'; Phase = 50; Source = 'RV,WU,OD,WH'; RestartExplorer = $true
            Note = 'TaskbarDeveloperSettings\TaskbarEndTask=1'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings'; Name = 'TaskbarEndTask'; Kind = 'DWord'; Value = 1 }
            )
        }
    )
}

