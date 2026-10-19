# Group 2 mechanisms: Appx / Features / AI / Edge-OneDrive-Teams

## Implementation notes (not a tweak)

- Removal engine (recommended): for each Name, (1) `Get-AppxProvisionedPackage -Online | ? DisplayName -eq <Name> | Remove-AppxProvisionedPackage -Online -PackageName <PackageName>`; (2) `Get-AppxPackage -AllUsers -Name <Name> | Remove-AppxPackage -AllUsers` (types Main/Bundle/Resource); (3) write deprovision key (see appx.deprovision-markers). RT engine additionally: delete `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\InboxApplications\<fullName>`; on failure write `...\AppxAllUserStore\EndOfLife\<SID>\<fullName>` and retry; last resort unregister preserving roamable data; leftovers go to RunOnce. Skip `IsFramework` and `NonRemovable` packages.
- PFN suffix: `Microsoft.*`, `MicrosoftCorporationII.*`, `MSTeams`, `microsoft.windowscommunicationsapps`, `Microsoft.549981C3F5F10` use `_8wekyb3d8bbwe`; `MicrosoftWindows.*` and system shell packages (`Microsoft.Windows.SecureAssessmentBrowser`, `PeopleExperienceHost`, `Apprep.ChxApp`, `ContentDeliveryManager`) use `_cw5n1h2txyewy`; Clipchamp `_yxz26nhyzhsrt`; Spotify `_zpdnekdrzrea0`. Always resolve actual PFN with Get-AppxPackage rather than hard-coding.
- Winhance variant: provisioned removal first, then `Remove-AppxPackage -AllUsers`, exact Name match; BloatRemoval.ps1 v2.3 is idempotent and re-run by `\Winhance\BloatRemoval` task (AtLogon, SYSTEM). winutil: same pipeline from appx.json. optimizerDuck: interactive, `Remove-AppxPackage -Package <FullName>` + optional provisioned removal.
- Reinstall hints: Store IDs given where inventory has them; many are "not reinstallable" (Maps, People, Skype, Paint 3D, Tips, Cortana, Xbox Game Bar plugin, AI packages).
- Each appx entry below: src detail lines name the inventory files. Region: items below are for 24H2/25H2.

## Appx Bloat Removal

### appx.deprovision-markers
Create empty keys `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\<PFN>` (needs TI/SYSTEM). RV list (PFN Name; suffix per notes): Microsoft.549981C3F5F10, BingNews, BingWeather, ECApp, GetHelp, Getstarted, MicrosoftEdge.Stable, MicrosoftEdge, MicrosoftEdgeDevToolsClient, MicrosoftSolitaireCollection, MicrosoftStickyNotes, People, PowerAutomateDesktop, Todos, Windows.Apprep.ChxApp, Windows.ContentDeliveryManager, Windows.PeopleExperienceHost, Windows.Photos, Windows.SecureAssessmentBrowser, WindowsAlarms, WindowsCamera, WindowsFeedbackHub, WindowsMaps, WindowsSoundRecorder, ZuneMusic, ZuneVideo, MicrosoftWindows.Client.WebExperience, microsoft.windowscommunicationsapps, Advertising.Xaml, Microsoft3DViewer, MixedReality.Portal, MSPaint, Paint, WindowsNotepad, clipchamp.clipchamp, SecHealthUI, WindowsCalculator, QuickAssist, MicrosoftFamily, Whiteboard, microsoft.microsoftskydrive, TeamsforSurfaceHub, MailforSurfaceHub, PowerBI, SkypeApp, OfficeHub, Office.{OneNote,Excel,PowerPoint,Word}, Windows.DevHome, OutlookForWindows, MSTeams. Keys must be created per PFN (with `Microsoft.`/etc. prefix). Notes: includes Paint/Notepad/Calculator/SecHealthUI/Photos, so new users never get them back; consider removing those from the list if you keep them. RV comment: Edge/WebView/DevHome "still get reinstalled after Windows Updates" -> hence the markers. Revert: delete the key.
src detail: playbook.md (Appx deprovisioning markers), optimizerduck-revitool.md (revitool engine).

### appx.block-outlook-devhome-autoinstall
- `HKLM\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\BlockedOobeUpdaters` = `["MS_Outlook"]` (REG_SZ JSON array).
- Delete keys `...\UScheduler_Oobe\OutlookUpdate` and `...\UScheduler_Oobe\DevHomeUpdate`.
- `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator\UScheduler\DevHomeUpdate\workCompleted=1` and `...\UScheduler\OutlookUpdate\workCompleted=1` (DWORD).
- RV WallpaperStartup also runs `Get-AppxPackage Microsoft.OutlookForWindows* | Remove-AppxPackage` at first logon (W10 case).
Revert: remove values. src detail: playbook.md (Block Outlook auto-install).

### appx.preinstalled-apps-block
`HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager` (+DEFAULT mirror) DWORD 0: PreInstalledAppsEnabled, PreInstalledAppsEverEnabled, OemPreInstalledAppsEnabled, SilentInstalledAppsEnabled (RV also SubscribedContentEnabled, ContentDeliveryAllowed, FeatureManagementEnabled, SoftLandingEnabled etc. in priv). Winhance exposes each separately; OD DisablePreinstalledApps writes the four. Revert: 1/delete. src detail: playbook.md (Privacy), optimizerduck-revitool.md, winhance.md (Privacy).

### appx.vclibs-restore
`revitool msstore-apps --id 9NBLGGH3FRZM --ring RP` (Microsoft.VCLibs.140.00 Desktop/UWP) and `--id 9NBLGGH4RV3K` (UWPDesktop); offline fallback (issue #219). Implement with `Add-AppxPackage` of bundled VCLibs or winget. Only needed if frameworks were removed; the tool should simply skip frameworks. src detail: playbook.md, optimizerduck-revitool.md.

### appx.frameworks-do-not-remove
Guard list, not a tweak: skip anything with IsFramework=true: Microsoft.VCLibs.*, Microsoft.UI.Xaml.*, Microsoft.NET.Native.Framework/Runtime.*, Microsoft.WindowsAppRuntime.*, Microsoft.Advertising.Xaml. RV removes `Microsoft.Advertising` by prefix (listed as "Microsoft.Advertising"); implement by exact Name `Microsoft.Advertising.Xaml` only if no installed app depends on it. odk lists `Get-AppxPackage` NonRemovable=false and IsFramework=false as the eligible set. src detail: playbook.md, optimizerduck-revitool.md.

### appx.store
Name `Microsoft.WindowsStore` (StoreId 9WZDNCRFJBMP). WH rates high; odk Caution. RV never removes. RV gotcha: `DisableRootAutoUpdate` is needed for the Store (do not set). Also Store dependencies: Microsoft.StorePurchaseApp, Microsoft.WindowsStore. src detail: winhance.md, optimizerduck-revitool.md.

### appx.store-purchase-app
Name `Microsoft.StorePurchaseApp`. odk Caution list. src detail: optimizerduck-revitool.md.

### appx.app-installer
Name `Microsoft.DesktopAppInstaller` (9NBLGGH4NNS1). WH rates high ("HasInstabilityWarning"). RV writes winget telemetry-off settings.json to its LocalState. src detail: winhance.md, optimizerduck-revitool.md, playbook.md.

### appx.windows-security-ui
Name `Microsoft.SecHealthUI` (RV deprovision marker only; Windows Security app). Not removed by any tool; odk lists under Caution only as Windows Security items absent. Keep even with Defender disabled. src detail: playbook.md.

### appx.terminal
Name `Microsoft.WindowsTerminal` (+`Microsoft.WindowsTerminalPreview`), StoreId 9N0DX20HK701; risk med in WH; odk Caution. src detail: winhance.md, optimizerduck-revitool.md.

### appx.calculator
Name `Microsoft.WindowsCalculator` (9WZDNCRFHVN5). RV deprovisions but leaves installed. winutil/WH risk med; odk Caution. src detail: winutil-regtweaks.md, winhance.md.

### appx.notepad
Name `Microsoft.WindowsNotepad` (9MSMLRH6LZF3). Also AI policy ai.notepad-ai-disable. RV deprovisions only. src detail: winutil-regtweaks.md, winhance.md.

### appx.snipping-tool
Name `Microsoft.ScreenSketch` (9MZ95KL8MR0L). src detail: winutil-regtweaks.md, winhance.md.

### appx.paint
Name `Microsoft.Paint` (9PCFS5B6T72H). RV deprovisions only (keys `Paint`). WH policy keys for Paint AI see ai.paint-ai-disable. src detail: winutil-regtweaks.md, winhance.md.

### appx.paint3d
Name `Microsoft.MSPaint` (Paint 3D; not Store-reinstallable). RV removes (always list "Microsoft.MSPaint (Paint 3D)"). src detail: playbook.md, winhance.md.

### appx.photos
Name `Microsoft.Windows.Photos` (9WZDNCRFJBH4). RV (opt remove-appx-photos, default on): removal triggers installing classic Windows Photo Viewer and re-mapping file associations (see Misc in playbook.md; owned by another group). Deprovision key `Microsoft.Windows.Photos`. Codec extensions stay. Revert: Store 9WZDNCRFJBH4. src detail: playbook.md, winutil-regtweaks.md, winhance.md, optimizerduck-revitool.md.

### appx.devhome
Name `Microsoft.Windows.DevHome` (9N8MHTPHNGVV). RV opt remove-appx-devhome (default on). Also deprovision key `Windows.DevHome`, and auto-install block (appx.block-outlook-devhome-autoinstall). src detail: playbook.md, winutil-regtweaks.md, winhance.md, optimizerduck-revitool.md.

### appx.yourphone
Name `Microsoft.YourPhone` (9NMPJ99VJBWV). RV opt remove-appx-yourphone (default on). RV also hides Settings page `crossdevice`: `revitool registry hide-page --value crossdevice` (SettingsPageVisibility). src detail: playbook.md, winutil-regtweaks.md, winhance.md.

### appx.crossdevice
Name `MicrosoftWindows.CrossDevice` (family `_cw5n1h2txyewy`). WU warns: phone mirroring, file transfer, hotspot handoff. RV also blocks Cross Device Resume (see Explorer/Misc; other group). Winhance's script also stops `Resume`/`CrossDeviceResume` processes. src detail: playbook.md, winutil-regtweaks.md.

### appx.camera
Name `Microsoft.WindowsCamera` (9WZDNCRFJBBG). Deprovision key `WindowsCamera`. src detail: playbook.md, winutil-regtweaks.md, winhance.md.

### appx.widgets-webexperience
Name `MicrosoftWindows.Client.WebExperience` (RV labels "Widgets"). Deprovision key. RV also `HKLM\SOFTWARE\Policies\Microsoft\Dsh\AllowNewsAndInterests=0` (stops reinstall since 22621.1343), `HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds\EnableFeeds=0` (Start group items). RV CBS DLL restore: renames `*.bak` back in `C:\Windows\SystemApps\MicrosoftWindows.Client.CBS_cw5n1h2txyewy` (WsxPackManager.dll, WebExperienceHostApp.exe, WebExperienceHost.dll, SystemSettingsExtensions.dll) - DLL-renaming approach (#61) was reverted. src detail: playbook.md, optimizerduck-revitool.md.

### appx.widgets-platform-runtime
Name `Microsoft.WidgetsPlatformRuntime`. RV always list. src detail: playbook.md, optimizerduck-revitool.md.

### appx.start-experiences
Name `Microsoft.StartExperiencesApp` (WU describes "Widgets board"). RV always list. src detail: playbook.md, winutil-regtweaks.md.

### appx.secure-assessment-browser
Name `Microsoft.Windows.SecureAssessmentBrowser` (`_cw5n1h2txyewy`). Deprovision key too. src detail: playbook.md.

### appx.people-experience-host
Name `Microsoft.Windows.PeopleExperienceHost` (`_cw5n1h2txyewy`). RV removes; deprovision key. System shell package; risk assessment is mine (inventory is silent): shell flyouts (taskbar people/contact). src detail: playbook.md.

### appx.alarms-clock
Name `Microsoft.WindowsAlarms` (9WZDNCRFJ3PR). src detail: playbook.md, winutil-regtweaks.md, winhance.md.

### appx.maps
Name `Microsoft.WindowsMaps` (9WZDNCRDTBVB; removed from Store July 2025). Offline maps policy in misc.offline-maps. src detail: playbook.md, winhance.md.

### appx.sticky-notes
Name `Microsoft.MicrosoftStickyNotes` (9NBLGGH4QGHW). src detail: playbook.md, winutil-regtweaks.md, winhance.md.

### appx.mail-calendar
Name `microsoft.windowscommunicationsapps` (9WZDNCRFHVQM). RV gotcha: Contacts consent left allowed for Mail & Calendar; removal can cause Outlook for Windows auto-install (see block item). src detail: playbook.md, winhance.md.

### appx.outlook-new
Names `Microsoft.OutlookForWindows` (9NRX63209R7B) and `OutlookPWA` (RV list). Deprovision key `OutlookForWindows`. src detail: playbook.md, winutil-regtweaks.md, winhance.md.

### appx.people
Name `Microsoft.People` (9NBLGGH10PG8). src detail: playbook.md, winhance.md.

### appx.bing-news
Name `Microsoft.BingNews` (9WZDNCRFHVFW); odk also lists `Microsoft.News`. src detail: playbook.md, winutil-regtweaks.md, winhance.md, optimizerduck-revitool.md.

### appx.bing-weather
Name `Microsoft.BingWeather` (9WZDNCRFJ3Q2). src detail: as above.

### appx.bing-search
Name `Microsoft.BingSearch` (9NZBF4GT040C). RV always list. src detail: playbook.md, winutil-regtweaks.md, winhance.md.

### appx.bing-extras
odk names (Microsoft.*): BingFinance, BingSports, BingFoodAndDrink, BingHealthAndFitness, BingTravel, BingTranslator, MicrosoftStart. src detail: optimizerduck-revitool.md.

### appx.solitaire
Name `Microsoft.MicrosoftSolitaireCollection` (9WZDNCRFHWD2). src detail: playbook.md, winutil-regtweaks.md, winhance.md.

### appx.feedback-hub
Name `Microsoft.WindowsFeedbackHub` (9NBLGGH4R32N). RV hides `privacy-feedback` Settings page. src detail: playbook.md, winutil-regtweaks.md, winhance.md.

### appx.get-help
Name `Microsoft.GetHelp` (9PKDZBMV1H3T). src detail: playbook.md, winutil-regtweaks.md, winhance.md.

### appx.tips
Name `Microsoft.Getstarted` (odk also `Microsoft.WindowsTips`). Not reinstallable. src detail: playbook.md, winhance.md.

### appx.todo
Name `Microsoft.Todos` (9NBLGGH5R558). src detail: playbook.md, winutil-regtweaks.md, winhance.md.

### appx.power-automate
Name `Microsoft.PowerAutomateDesktop` (9NFTCH6J7FHV). src detail: playbook.md, winutil-regtweaks.md.

### appx.cortana
Name `Microsoft.549981C3F5F10` (9NFFX4SZZ23L; deprecated). src detail: playbook.md, winhance.md.

### appx.quick-assist
Name `MicrosoftCorporationII.QuickAssist` (9P7BP5VNWKX5). src detail: playbook.md, winutil-regtweaks.md, winhance.md.

### appx.family-safety
Name `MicrosoftCorporationII.MicrosoftFamily` (9PDJDJS743XF). src detail: playbook.md, winhance.md.

### appx.support-diagnostic-tool
Name `MicrosoftCorporationII.MicrosoftSupportDiagnosticTool` (odk Caution). src detail: optimizerduck-revitool.md.

### appx.media-player
Name `Microsoft.ZuneMusic` (9WZDNCRFJ3PT). RV always list. src detail: playbook.md, winutil-regtweaks.md, winhance.md.

### appx.movies-tv
Name `Microsoft.ZuneVideo` (9WZDNCRFJ3P2). src detail: same.

### appx.sound-recorder
Name `Microsoft.WindowsSoundRecorder` (9WZDNCRFHWKN). src detail: same.

### appx.clipchamp
Name `Clipchamp.Clipchamp` (9P1J8S7CCWWT). src detail: same.

### appx.whiteboard
Name `Microsoft.Whiteboard`. src detail: playbook.md, optimizerduck-revitool.md.

### appx.surfacehub-apps
Names `Microsoft.MicrosoftTeamsforSurfaceHub`, `MicrosoftCorporationII.MailforSurfaceHub`. src detail: playbook.md.

### appx.powerbi
Name `Microsoft.MicrosoftPowerBIForWindows`. src detail: playbook.md, optimizerduck-revitool.md.

### appx.skype
Name `Microsoft.SkypeApp`. src detail: playbook.md, winhance.md.

### appx.office-hub
Name `Microsoft.MicrosoftOfficeHub` (9WZDNCRD29V9; branded "Microsoft 365 Copilot"). WU's AI-removal also removes it. src detail: playbook.md, winutil-regtweaks.md, winhance.md.

### appx.office-desktop-stubs
Names `Microsoft.Office.Word`, `Microsoft.Office.Excel`, `Microsoft.Office.PowerPoint` (RV always list). src detail: playbook.md.

### appx.onenote
Name `Microsoft.Office.OneNote` (XPFFZHVGQWWLHB); odk also `Microsoft.Office.Sway`. Winhance also runs the desktop OneNote uninstall string silently (`/silent`, or DisplayLevel=False for Click-to-Run). src detail: playbook.md, winhance.md, winutil-regtweaks.md.

### appx.m365-companions
Name `Microsoft.M365Companions` (odk Caution). src detail: optimizerduck-revitool.md.

### appx.spotify
Name `SpotifyAB.SpotifyMusic`. src detail: playbook.md, optimizerduck-revitool.md.

### appx.3d-viewer
Name `Microsoft.Microsoft3DViewer` (9NBLGGH42THS). src detail: playbook.md, winhance.md.

### appx.mixed-reality-portal
Name `Microsoft.MixedReality.Portal` (9NG1H8B3ZC7M). src detail: playbook.md, winhance.md.

### appx.third-party-promos
odk SAFE list names: Drawboard.DrawboardPDF, Disney.37853FC22B2CE, Amazon.com.Amazon, 4DF9E0F8.Netflix, BytedancePte.Ltd.TikTok, king.com.CandyCrushSaga/SodaSaga/BubbleWitch3Saga, AmazonVideo.PrimeVideo, Facebook.Instagram, FACEBOOK.FACEBOOK, 7EE7776C.LinkedInforWindows, Flipboard, iHeartRadio, PandoraMediaInc, TuneInRadio, Duolingo-LearnLanguagesforFree, PicsArt-PhotoStudio, WinZipUniversal, AdobeSystemsIncorporated.AdobePhotoshopExpress, OneCalendar, NYTCrossword, MarchofEmpires, flaregamesGmbH.RoyalRevolt, Asphalt8Airborne, FarmVille2CountryEscape, HiddenCity, CaesarsSlotsFreeCasino, COOKINGFEVER, DisneyMagicKingdoms, PhototasticCollage, AutodeskSketchBook, PolarrPhotoEditorAcademicEdition, Sidia.LiveWallpaper, HULULLC.HULUPLUS, SlingTV, DolbyLaboratories.DolbyAccess (note: Dolby Access may be needed for spatial audio). Regex-match by Name substring. src detail: optimizerduck-revitool.md.

### appx.legacy-win10-leftovers
Names: Microsoft.Messaging, Microsoft.OneConnect, Microsoft.Wallet/MSWallet, Microsoft.Print3D, Microsoft.3DBuilder, Microsoft.Office.Sway, Microsoft.MicrosoftJournal, Microsoft.NetworkSpeedTest, Microsoft.MinecraftUWP. Excluded Win10-only lists from Remove-Edge-ISO otherwise. src detail: optimizerduck-revitool.md, winutil-regtweaks.md.

### appx.windows-aihub
Name `Microsoft.Windows.AIHub` (odk SAFE list). See ai.remove-ai-platform-packages. src detail: optimizerduck-revitool.md.

### appx.xbox-identity-provider
Name `Microsoft.XboxIdentityProvider` (9WZDNCRD1HKW). WU WARN: may break MS account sign-in for non-Xbox games/apps. src detail: winutil-regtweaks.md, winhance.md, optimizerduck-revitool.md.

### appx.xbox-tcui
Name `Microsoft.Xbox.TCUI` (9NKNC0LD5NN6). WU WARN same as above. src detail: same.

### appx.xbox-app
Names `Microsoft.GamingApp` (9MV0B5HZVK9Z), `Microsoft.XboxApp`. src detail: winutil-regtweaks.md, winhance.md.

### appx.xbox-game-bar
Names `Microsoft.XboxGamingOverlay` (9NZKPSTSNW4P), `Microsoft.XboxGameOverlay`. Side effects handled by Winhance BloatRemoval and RV: `HKCR\ms-gamebar` (default)=`URL:ms-gamebar`, `URL Protocol`="" , `NoOpenWith`, `shell\open\command` default=`%SystemRoot%\System32\systray.exe`; same for `ms-gamebarservices`; `HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR\AppCaptureEnabled=0`, `HKCU\System\GameConfigStore\GameDVR_Enabled=0`, `HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR\AllowGameDVR=0`; RV `HKCU\Software\Microsoft\GameBar\ShowStartupPanel=0`. RV gotchas: AppCaptureEnabled set breaks Game Bar Start Recording (#74); background-apps disabled breaks Game Bar KGL update. src detail: playbook.md, winhance.md, winutil-regtweaks.md.

### appx.xbox-speech-overlay
Name `Microsoft.XboxSpeechToTextOverlay`. src detail: winutil-regtweaks.md, optimizerduck-revitool.md.

### appx.xbox-gaming-services
Names `Microsoft.GamingServices` (9MWPM2CQNLHN), `Microsoft.XboxGameCallableUI` (SystemApps; restore by `Add-AppxPackage -Register -DisableDevelopmentMode C:\Windows\SystemApps\Microsoft.XboxGameCallableUI_cw5n1h2txyewy\AppxManifest.xml`). Also `Microsoft.Edge.GameAssist` in the RT package. src detail: optimizerduck-revitool.md.

### appx.xbox-winsxs-removal
`revitool winpackage --install xbox-removal` (CBS package `Revision-ReviOS-Xbox-Removal`); RT removes Microsoft.XboxGameCallableUI (preserve roaming) and all-users Microsoft.Xbox.TCUI, GamingApp, GamingServices, Edge.GameAssist, XboxGamingOverlay, XboxIdentityProvider; restore by Store (TCUI/GamingApp 9MV0B5HZVK9Z, GamingServices 9MWPM2CQNLHN, Overlay 9NZKPSTSNW4P, IdentityProvider 9WZDNCRD1HKW). Then ms-gamebar fix (see appx.xbox-game-bar). RV default OFF (remove-appx-xbox). Custom tool can reimplement via appx removal of the list above. src detail: playbook.md, optimizerduck-revitool.md.

### appx.copilot-plus-names
Winhance WindowsAppDefinitions id=windows-app-copilot-plus-pc: `MicrosoftWindows.Voiess`, `MicrosoftWindows.Speion`, `MicrosoftWindows.Livtop`, `MicrosoftWindows.InpApp`, `MicrosoftWindows.Filons` (described: voice, speech, live typing, input, file operations on NPU PCs; not reinstallable). Names look abbreviated/odd; verify `Get-AppxPackage -AllUsers MicrosoftWindows.*` and match actual names (likely Voiess etc. are truncated/obfuscated forms) before removing. Prefer matching real names found on a Copilot+ PC. src detail: winhance.md.

### appx.codec-extensions
Guard names: Microsoft.HEIFImageExtension, WebpImageExtension, WebMediaExtensions, RawImageExtension, VP9VideoExtensions, AV1VideoExtension, HEVCVideoExtension, MPEG2VideoExtension. src detail: optimizerduck-revitool.md.

### appx.remote-desktop-app
Name `Microsoft.RemoteDesktop`. src detail: optimizerduck-revitool.md.

### appx.oem-bloat
Name patterns: `AD2F1837.*` (HP), `DellInc.*`, `*Lenovo*`, `LGMonitorApp`. odk Caution. src detail: optimizerduck-revitool.md.

## Windows Features & Capabilities

### feat.winsxs-system-components-removal
`revitool winpackage --install system-components-removal` (CBS package `Revision-ReviOS-SystemPackages-Removal`, GitHub `meetrevision/packages` latest, asset `<Name>.31bf3856ad364e35.<arch>.<ver>.cab`; installed via DISM add-package; signature EKU 1.3.6.1.4.1.311.10.3.6; detected under `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages`). Other Revi packages: Telemetry-Removal, Defender-Removal, AI-Removal, OneDrive-Removal, Xbox-Removal. Contents not in the inventory; RV comment: old `!systemPackage` method deprecated, main cause of #49. Cannot be reimplemented without the cab; treat as optional/external. Runs after app-win32 removals. Revert: remove CBS package / not generically reversible. src detail: playbook.md, optimizerduck-revitool.md.

### feat.update-health-tools-removal
Commands: `msiexec /X{43D501A5-E5E3-46EC-8F33-9E15D2A2CBD5}`; delete `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\{UpdateHealthTools,rempl}`, `HKLM\SOFTWARE\Microsoft\CloudManagedUpdate`; rmdir `%ProgramW6432%\Microsoft Update Health Tools`; `msiexec /X{804A0628-543B-4984-896C-F58BF6A54832}` + rmdir PCHealthCheck; `Windows10UpgraderApp.exe /SunValley /ForceUninstall` + rmdir `WindowsInstallationAssistant`. May be restored by cumulative updates. src detail: playbook.md (FINALIZE.cmd).

### feat.powershell-v2
`Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2 -NoRestart` and `MicrosoftWindowsPowerShellV2Root`. RV DISM-FEATURES.ps1 only acts if CBS state differs; task file optional-features.yml not included anywhere (dead). Revert: Enable-WindowsOptionalFeature. src detail: playbook.md.

### feat.workfolders-client
`Disable-WindowsOptionalFeature -Online -FeatureName WorkFolders-Client -NoRestart`. RV dead code. src detail: playbook.md.

### feat.msrdc-infrastructure
`Disable-WindowsOptionalFeature -Online -FeatureName MSRDC-Infrastructure -NoRestart`. RV dead code. src detail: playbook.md.

### feat.printing-foundation
Disable `Printing-Foundation-Features` and `Printing-Foundation-InternetPrinting-Client`. RV dead code; risk low/med (RV). `SmbDirect` commented in RV. src detail: playbook.md.

### feat.directplay-legacy-components
`Enable-WindowsOptionalFeature -Online -FeatureName DirectPlay,LegacyComponents -NoRestart` (RV); winutil "legacy media" also WindowsMediaPlayer, MediaPlayback. src detail: playbook.md, winutil-regtweaks.md.

### feat.internet-explorer-capability
`Remove-WindowsCapability -Online -Name 'Browser.InternetExplorer*'` (match installed by prefix; State=Installed). Capability remove pattern same for the following ones. src detail: winhance.md.

### feat.powershell-ise-capability
`Remove-WindowsCapability -Online -Name 'Microsoft.Windows.PowerShell.ISE*'`. src detail: winhance.md.

### feat.quick-assist-legacy-capability
`Remove-WindowsCapability -Online -Name 'App.Support.QuickAssist*'`. src detail: winhance.md.

### feat.steps-recorder-capability
`Remove-WindowsCapability -Online -Name 'App.StepsRecorder*'`. src detail: winhance.md.

### feat.wmp-legacy-capability
`Remove-WindowsCapability -Online -Name 'Media.WindowsMediaPlayer*'`. src detail: winhance.md.

### feat.wordpad-capability
`Remove-WindowsCapability -Online -Name 'Microsoft.Windows.WordPad*'`; already removed by default in 24H2. src detail: winhance.md.

### feat.notepad-legacy-capability
`Remove-WindowsCapability -Online -Name 'Microsoft.Windows.Notepad*'`. src detail: winhance.md.

### feat.paint-legacy-capability
`Remove-WindowsCapability -Online -Name 'Microsoft.Windows.MSPaint*'`. src detail: winhance.md.

### feat.openssh-client-capability
`Remove-WindowsCapability -Online -Name 'OpenSSH.Client*'` (WH risk med). src detail: winhance.md.

### feat.openssh-server-capability
`Remove-WindowsCapability -Online -Name 'OpenSSH.Server*'`. winutil only offers enabling `OpenSSH.Server~~~~0.0.1.0` (excluded as install). src detail: winhance.md, winutil-regtweaks.md.

### feat.wsl-disable
`Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart` (+ `VirtualMachinePlatform` if wanted). Only when State=Enabled. Reboot. src detail: winhance.md, winutil-regtweaks.md.

### feat.hyper-v-disable
Disable (only if Enabled): `Microsoft-Hyper-V-All`, `Microsoft-Hyper-V-Tools-All`, `Microsoft-Hyper-V-Hypervisor` (Windows Hypervisor Platform). Reboot. src detail: winhance.md.

### feat.windows-sandbox-disable
`Disable-WindowsOptionalFeature -Online -FeatureName Containers-DisposableClientVM -NoRestart`. src detail: winhance.md.

### feat.netfx3-disable
`Disable-WindowsOptionalFeature -Online -FeatureName NetFx3 -NoRestart` (only when Enabled). src detail: winhance.md.

### feat.reserved-storage-off
`DISM /Online /Set-ReservedStorageState /State:Disabled` and `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager\ShippedWithReserves=0` (DWORD). Revert: `/State:Enabled`, value 1; re-enable before feature updates. src detail: winutil-regtweaks.md.

### feat.component-cleanup-resetbase
`Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase`; optional `cleanmgr.exe /d C: /VERYLOWDISK`. Irreversible. src detail: winutil-regtweaks.md.

### feat.legacy-f8-boot-menu
`bcdedit /set {default} bootmenupolicy legacy` (revert: `standard`). src detail: winutil-regtweaks.md.

### misc.hide-settings-pages
`revitool registry hide-page --value "cortana,privacy-feedback,windowsinsider,home"` = `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\SettingsPageVisibility` (REG_SZ) `hide:cortana;privacy-feedback;windowsinsider;home;`. RV also hides `crossdevice` (Your Phone), RT/WU hide `aicomponents`, odk also `privacy-systemaimodels`. Merge lists into a single `hide:` string; "home" hides the Settings home page. src detail: playbook.md, optimizerduck-revitool.md, winutil-regtweaks.md.

### misc.hide-insider-page-wu-tray
`HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility\HideInsiderPage=1` (DWORD); `HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings\TrayIconVisibility=0`. src detail: playbook.md.

### misc.enable-sudo
`HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Sudo\Enabled=3` (DWORD; inline mode). 24H2+. src detail: playbook.md.

### misc.accessibility-reset
Delete `HKCU\Control Panel\Accessibility\{AudioDescription,Blind Access,HighContrast,Keyboard Preference,Keyboard Response,MouseKeys,On,ShowSounds,SlateLaunch,SoundSentry,StickyKeys,TimeOut,ToggleKeys}` (+DEFAULT) then set `Flags=0` (REG_SZ) on each; delete MouseKeys MaximumSpeed/TimeToMaximumSpeed. src detail: playbook.md.

### misc.typing-suggestions-off
`HKCU+HKLM\SOFTWARE\Microsoft\TabletTip\1.7`: EnableAutocorrection, EnableSpellchecking, EnableTextPrediction, EnablePredictionSpaceInsertion, EnableDoubleTapSpace = 0; `HKCU+HKLM\Software\Microsoft\Input\Settings`: InsightsEnabled, EnableHwkbTextPrediction, EnableHwkbAutocorrection, MultilingualEnabled = 0. Winhance "Input Insights" = HKCU Input\Settings\InsightsEnabled=0 (same). src detail: playbook.md, winhance.md.

### misc.clipboard-history-off
`HKCU\Software\Microsoft\Clipboard\EnableClipboardHistory=0` (+DEFAULT); `HKLM\SOFTWARE\Policies\Microsoft\Windows\System`: AllowClipboardHistory=1, AllowCrossDeviceClipboard=1 (policy keeps it allowed). src detail: playbook.md.

### misc.offline-maps
`HKLM\SYSTEM\Maps`: UpdateOnlyOnWifi=1, AutoUpdateEnabled=0. src detail: playbook.md.

### misc.inking-workspace
`HKLM\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace`: AllowWindowsInkWorkspace=1, AllowSuggestedAppsInWindowsInkWorkspace=0. src detail: playbook.md.

## AI (Copilot/Recall)

### ai.remove-copilot-appx
Names (all users): `Microsoft.Copilot` (family `Microsoft.Copilot_8wekyb3d8bbwe`, Store XP9CXNGPPJ97XX / 9nht9rb2f4hd), `Microsoft.Windows.Ai.Copilot.Provider`, `MicrosoftWindows.Client.CoPilot`; WU also `Get-AppxPackage -AllUsers *Copilot* | Remove-AppxPackage` and `winget uninstall -e --name "Copilot"`. RV opt remove-winsxs-ai fallback: `revitool appx --all-users --remove Microsoft.Copilot`. Revert: Store reinstall. src detail: playbook.md, winutil-regtweaks.md, winhance.md, optimizerduck-revitool.md.

### ai.disable-copilot-policy
`HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot\TurnOffWindowsCopilot=1` and same under HKCU (DWORD); `HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ShowCopilotButton=0`; `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked\{CB3B0003-8088-4EDE-8769-8B354AB2FF8C}=""` (OD). Revert: delete. src detail: optimizerduck-revitool.md, winhance.md.

### ai.disable-recall-policy
`HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI`: DisableAIDataAnalysis=1 (RV, OD, WH), AllowRecallEnablement=0 (OD, WH), TurnOffSavingSnapshots=1 (OD, WH); HKCU `...\WindowsAI` DisableAIDataAnalysis=1, TurnOffSavingSnapshots=1 (OD; only when Recall installed). All DWORD. Build note: 26100.3915+ ; RV tags this "24H2". Revert: delete values. src detail: playbook.md, optimizerduck-revitool.md, winhance.md.

### ai.recall-feature-remove
`Disable-WindowsOptionalFeature -Online -FeatureName Recall -NoRestart` (OD, WH, WU) optionally `-Remove` (WU unattend FirstLogon, when enabled). Reboot. Revert: Enable-WindowsOptionalFeature. src detail: optimizerduck-revitool.md, winutil-regtweaks.md, winhance.md.

### ai.remove-ai-platform-packages
Appx names: `MicrosoftWindows.Client.AIX`, `MicrosoftWindows.Client.CoreAI` (WU: write `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\EndOfLife\<SID>\<CoreAI full name>` then Remove-AppxPackage), `Microsoft.AIFabric.CBS.1.6` (RT: preserve roaming; restore with `Add-AppxPackage -Register -DisableDevelopmentMode -Path C:\Windows\SystemApps\Microsoft.AIFabric.CBS.1.6_8wekyb3d8bbwe\AppxManifest.xml`), `Microsoft.Windows.AIHub`, `Microsoft.Office.ActionsServer`, `aimgr`, `Microsoft.WritingAssistant`, `Microsoft.Edge.GameAssist`, `WindowsWorkload.{OnnxRuntimeGenAI,SemanticTextSimilarity,ImageSearch,ContentExtraction,ScreenRegionDetection,TextRecognition,ImageContentModeration,ScreenSemanticsOCR,ImageSuperResolution,ObjectErase,ImageDescriptor,PortraitBlur,TextToSpeech,SpeechToText,ImageSegmentation,CreativeFilter,StudioEffects,SubtitleTranslation,Summarization,RewriteTextSuggestion}` and the Copilot+ names (see appx.copilot-plus-names). Also `Set-Service WSAIFabricSvc -StartupType Disabled` (WU). REQUIRED guard when AIFabric removed on 26x00.9278+/9550+: `HKLM\SYSTEM\ControlSet001\Policies\Microsoft\FeatureManagement\Overrides\1561856655=0` and `\497250959=0` (DWORD) so Explorer does not fall back to the Win10 ribbon (RT). Hide pages `aicomponents`, `privacy-systemaimodels`. Revert: delete overrides, re-register manifest, Store reinstall. src detail: optimizerduck-revitool.md, winutil-regtweaks.md, winhance.md.

### ai.winsxs-ai-removal
`revitool winpackage --install ai-removal` = CBS package `Revision-ReviOS-AI-Removal` (see feat.winsxs-system-components-removal for package mechanism). AiRemovalService does: hide `aicomponents`/`privacy-systemaimodels`, disable Recall feature, remove `Microsoft.Copilot` and `Microsoft.AIFabric.CBS.1.6`, set the FeatureManagement overrides above. RV opt `remove-winsxs-ai` default ON. Equivalent explicit sequence = ai.remove-copilot-appx + ai.recall-feature-remove + ai.remove-ai-platform-packages + ai.hide-ai-settings-pages. Uninstall: unhide pages, remove package, enable Recall, reinstall Copilot (Store 9nht9rb2f4hd), re-register AIFabric manifest, delete `...\Overrides\1561856655`. src detail: playbook.md, optimizerduck-revitool.md.

### ai.disable-click-to-do
`HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI\DisableClickToDo=1` and `HKCU\Software\Policies\Microsoft\Windows\WindowsAI\DisableClickToDo=1` (DWORD). Win11 24H2+. src detail: optimizerduck-revitool.md, winhance.md.

### ai.windows-ai-agent-policies
`HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI` DWORD: DisableSettingsAgent=1, DisableAgentConnectors=1, DisableAgentWorkspaces=1, DisableRemoteAgentConnectors=1, AllowCopilotRuntime=0. Default: delete. src detail: winhance.md.

### ai.copilot-shell-surfaces
HKCU `...\Explorer\Advanced` DWORD: ShowCopilotButton=0 (taskbar), TaskbarCompanion=0, CopilotPWAPin=0, RecallPin=0, ShowCopilotNudges=0; `HKCU\Software\Microsoft\Windows\Shell\Copilot\IsCopilotAvailable=0`; `HKCU\Software\Microsoft\Windows\Shell\Copilot\BingChat\IsUserEligible=0`. Defaults 1/delete. src detail: winhance.md, optimizerduck-revitool.md.

### ai.copilot-hardware-key
`HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CopilotKey\SetCopilotHardwareKey` (REG_SZ) = `""` ; default null. src detail: winhance.md.

### ai.copilot-mic-and-genai-privacy
`HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\generativeAI\Value`="Deny"; `...\systemAIModels\Value`="Deny"; `...\systemAIModels\RecordUsageData=0`; `HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy\LetAppsAccessGenerativeAI=2`, `LetAppsAccessSystemAIModels=2` (DWORD); HKCU `...\ConsentStore\microphone\Microsoft.Copilot_8wekyb3d8bbwe\Value`="Deny" and `...\Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe\Value`="Deny". Default "Allow"/delete. src detail: winhance.md.

### ai.consumer-ai-content
`HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent\DisableConsumerAccountStateContent=1`. RV avoids DisableWindowsConsumerFeatures (breaks Your Phone). src detail: winhance.md, playbook.md.

### ai.hide-ai-settings-pages
SettingsPageVisibility entries `aicomponents`, `privacy-systemaimodels` (merge with misc.hide-settings-pages; String `hide:aicomponents` in WU). src detail: winutil-regtweaks.md, optimizerduck-revitool.md.

### ai.notepad-ai-disable
`HKLM\SOFTWARE\Policies\WindowsNotepad\DisableAIFeatures=1` (DWORD). src detail: winutil-regtweaks.md.

### ai.paint-ai-disable
`HKLM\SOFTWARE\Policies\Microsoft\Paint` DWORD 1: DisableImageCreator, DisableCocreator, DisableGenerativeFill, DisableGenerativeErase, DisableRemoveBackground. src detail: winhance.md.

### ai.bing-copilot-ifeo-block
`HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\{BingChatInstaller.exe,BGAUpsell.exe,BCILauncher.exe}\Debugger=%windir%\System32\taskkill.exe` (RV ifeo.yml; TI). Revert: delete keys. src detail: playbook.md.

### ai.edge-ai-policies
`HKLM\SOFTWARE\Policies\Microsoft\Edge` DWORD: CopilotCDPPageContext=0, CopilotPageContext=0, HubsSidebarEnabled=0, EdgeEntraCopilotPageContext=0, Microsoft365CopilotChatIconEnabled=0, EdgeHistoryAISearchEnabled=0, ComposeInlineEnabled=0, GenAILocalFoundationalModelSettings=1, BuiltInAIAPIsEnabled=0, AIGenThemesEnabled=0, DevToolsGenAiSettings=2, ShareBrowsingHistoryWithCopilotSearchAllowed=0. src detail: winhance.md.

### ai.office-copilot-policies
HKCU DWORDs: `Software\Policies\Microsoft\office\16.0\common\ai\training\optionalconnectedexperiencesenabled=0`; `...\common\privacy\controllerconnectedservicesenabled=2`, `usercontentdisabled=2`; `...\common\ai\contentsafetyserviceenabled=0`; `Software\Microsoft\Office\16.0\{Word,Excel}\Options\EnableCopilot=0`; `...\OneNote\Options\Other\{EnableCopilot,EnableCopilotNotebooks,EnableCopilotSkittle}=0`. src detail: winhance.md.

### ai.vivetool-recall-flag
`ViVeTool.exe /disable /id:47205210` (v0.3.4 from github.com/thebookisclosed/ViVe), WU unattend FirstLogon. Not recommended: external binary, flag may be obsolete. src detail: winutil-regtweaks.md.

## Edge/OneDrive/Teams

### edge.remove-edge
Full RV sequence (EDGE.ps1 -Mode EdgeBrowser, run as current user elevated; region must be non-EU for the BrowserReplacement trick):
1. Kill msedge, MicrosoftEdge*, MicrosoftEdgeUpdate, setup processes.
2. Delete value `NoRemove` under `HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge`.
3. Set `HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdateDev\AllowUninstall=1` (DWORD).
4. Create fake `%SystemRoot%\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\MicrosoftEdge.exe` (activates BrowserReplacement so Settings > Apps can uninstall).
5. Set `$env:windir=""` (so setup does not detect itself as protected).
6. Copy `cmd.exe` to `%SystemRoot%\ImmersiveControlPanel\sihost.exe` (spoofed parent; allowed parents: dllhost, msiexec, sihost, SystemSettings).
7. Run `setup.exe --uninstall --force-uninstall --delete-profile` (from `...\Edge\Application\<ver>\Installer`; or uninstall string) for ClientState `{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}` with the sihost.exe spoofed as parent.
8. Delete Edge shortcuts; remove appx `Microsoft.MicrosoftEdge`, `Microsoft.MicrosoftEdgeDevToolsClient`, `Microsoft.Edge.GameAssist` (Edge.Stable too); delete fake MicrosoftEdge.exe.
RV order: kill processes -> app-win32 (Edge/OneDrive/Teams) first, WinSxS second. WebView2 kept. Differences: winutil live variant: dummy `...\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\MicrosoftEdge.exe` then `"%ProgramFiles(x86)%\Microsoft\Edge\Application\*\Installer\setup.exe" --uninstall --system-level --force-uninstall --delete-profile`. Winhance EdgeRemoval.ps1 v1.4 (three steps): (a) legacy: CBS `Microsoft-Windows-Internet-Browser-Package~~` Visibility=1, delete Owners, `dism /online /Remove-Package`, Remove-AppxPackage Microsoft.MicrosoftEdge; (b) Chromium: fake MicrosoftEdge.exe, run `<uninstallString> --force-uninstall --silent` (msiexec `/quiet` variant), Remove-AppxPackage Microsoft.MicrosoftEdge.Stable, delete fake folder; (c) EdgeUpdate: back up `HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\ClientState` ("or else WebView won't work"), `MicrosoftEdgeUpdate.exe /unregsvc`, wait, `/uninstall`, re-import ClientState. Then cleanup of Program Files (x86)\Microsoft\*Edge*/*Temp*, shortcuts (desktop/quick launch/taskbar/start for all profiles), registry keys (`SOFTWARE\Microsoft\Edge`, `EdgeUpdate`, `Clients\StartMenuInternet\Microsoft Edge`, `App Paths\msedge.exe`, `Uninstall\Microsoft Edge`, eventlog entries, `RegisteredApplications`, `Classes\MicrosoftEdgeUpdate*/MSEdge*`), `C:\ProgramData\Microsoft\EdgeUpdate`, `C:\Windows\Temp\MsEdgeCrashpad`, `%LOCALAPPDATA%\Microsoft\Edge`; delete stale IFEO `msedge.exe`; delete scheduled tasks named *Edge*. RS offline ISO DISM `/Remove-Edge*` switches are ISO-only (excluded). Win10 fallback excluded. Revert: reinstall via winget `Microsoft.Edge` / Store XPFFTQ037JWMHS. Build: tested 24H2/25H2 per RV; Edge may return after Windows Update -> see edge.block-edge-reinstall. src detail: playbook.md, winutil-regtweaks.md, winhance.md.

### edge.block-edge-reinstall
`HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate`: InstallDefault=0, `Install{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}`=0 (Edge), `Install{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}`=1 (WebView2), `HKLM\SOFTWARE\Microsoft\EdgeUpdate\DoNotUpdateToEdgeWithChromium=1` (all DWORD; RV fixes.yml; comment: fix for VS WebView2 install). Also Deprovisioned keys for Microsoft.MicrosoftEdge.Stable, MicrosoftEdge, MicrosoftEdgeDevToolsClient ("still gets reinstalled after Windows Updates"; covered by appx.deprovision-markers). Revert: delete values. src detail: playbook.md.

### edge.keep-webview2
Guard behaviour, not a registry tweak: never run EDGE.ps1 `-Mode WebView` (ClientState `{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}`); exclude `*EdgeWebView*` from deletion; back up/restore EdgeUpdate ClientState; keep EdgeUpdate service. src detail: playbook.md, winhance.md.

### edge.edgeupdate-manual
Services `edgeupdate`, `edgeupdatem`, `MicrosoftEdgeElevationService` start=Manual (3). RV sets edgeupdate only (comment: Disabled breaks WebView2 install via Visual Studio); OD profile sets all three. Default: edgeupdate/edgeupdatem Automatic (delayed). src detail: playbook.md, optimizerduck-revitool.md.

### edge.remove-webview2
EDGE.ps1 `-Mode WebView` (ClientState `{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}`) and `-Mode EdgeUpdate` (runs UninstallCmdLine); unused by RV. ISO DISM `/Remove-EdgeWebView` excluded. src detail: playbook.md, winutil-regtweaks.md.

### edge.protocol-redirect
Winhance (credit AveYo OpenWebSearch): copy `ie_to_edge_stub.exe` to `C:\ProgramData\Winhance\OpenWebSearch\` before removal; `HKCR\microsoft-edge\shell\open\command=<stub> %1`; `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ie_to_edge_stub.exe`: UseFilter=1, `\0\FilterFullPath`, `\0\Debugger=conhost.exe --headless <OpenWebSearch.cmd>` (headless flag when build>25179, else `--width 1 --height 1`); `HKCR\MSEdgeHTM\shell\open\command` -> stub; task `\Winhance\OpenWebSearchRepair` (AtLogon, SYSTEM). OpenWebSearch.cmd opens real default browser (falls back to scanning `SOFTWARE\Clients\StartMenuInternet`). src detail: winhance.md.

### edge.reremoval-task
Task `\Winhance\EdgeRemoval` (AtStartup, SYSTEM, RunLevel Highest) running `powershell -ExecutionPolicy Bypass -NoProfile -Command "iex([IO.File]::ReadAllText('C:\ProgramData\Winhance\Scripts\EdgeRemoval.ps1'))"`; script exits early if no Edge found; also removes any *Edge* tasks. Self-update compares script version header. src detail: winhance.md.

### edge.policies-debloat
`HKLM\SOFTWARE\Policies\Microsoft\Edge` DWORD: PersonalizationReportingEnabled=0, ShowRecommendationsEnabled=0, HideFirstRunExperience=1, UserFeedbackAllowed=0, ConfigureDoNotTrack=1, AlternateErrorPagesEnabled=0, EdgeCollectionsEnabled=0, EdgeShoppingAssistantEnabled=0, MicrosoftEdgeInsiderPromotionEnabled=0, ShowMicrosoftRewards=0, WebWidgetAllowed=0, DiagnosticData=0, EdgeAssetDeliveryServiceEnabled=0, WalletDonationEnabled=0, DefaultBrowserSettingsCampaignEnabled=0; `...\Edge\ExtensionInstallBlocklist\1`="ofefcgjbeghpigppfmkologfjadafddi" (REG_SZ). Startup: `HKLM\Software\Policies\Microsoft\Edge\Recommended` BackgroundModeEnabled=0, StartupBoostEnabled=0. src detail: winutil-regtweaks.md.

### edge.no-desktop-shortcut
`HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate\CreateDesktopShortcutDefault=0`; delete `C:\Users\Public\Desktop\Microsoft Edge.lnk`. src detail: winutil-regtweaks.md.

### edge.data-optin-off
`HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection\MicrosoftEdgeDataOptIn=0` (DWORD). src detail: optimizerduck-revitool.md.

### edge.remove-onedrive
RV (ONED.cmd, not in OOBE/ISO): kill OneDrive*, OneDriveSetup, OneDriveStandaloneUpdater; run `OneDriveSetup.exe /uninstall` from System32/SysWOW64/per-user uninstall paths; remove `HKU\<sid>\...\Run\OneDrive` and `...\Uninstall\OneDriveSetup.exe`; delete `%USERPROFILE%\AppData\Local\Microsoft\OneDrive` and Start Menu OneDrive.lnk for all users; `HKCR\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\System.IsPinnedToNameSpaceTree=0` (hide nav pane); delete `%SystemDrive%\OneDriveTemp`, `%ProgramData%\Microsoft OneDrive`; appx `OneDrive`, `microsoft.microsoftskydrive`; plus RT `winpackage --install onedrive-removal` (CBS `Revision-ReviOS-OneDrive-Removal`). WU: `icacls %OneDrive% /deny *S-1-5-32-544:(D,DC)`, `%SystemRoot%\System32\OneDriveSetup.exe /uninstall`, kill FileCoAuth/Explorer, delete `%LocalAppData%\Microsoft\OneDrive`, `%ProgramData%\Microsoft OneDrive`, grant back, remove empty folder and user env var OneDrive, `Set-Service OneSyncSvc Disabled`. Winhance: Remove-AppxPackage `Microsoft.OneDriveSync`; uninstall strings from HKLM/HKU; delete `System32\OneDriveSetup.exe` and SysWOW64 copy (takeown/icacls; MoveFileEx on reboot if locked); delete tasks *OneDrive*; Default-user hive: delete `Run\OneDriveSetup`, set `SOFTWARE\Microsoft\OneDrive\EnableTHDFFeatures=0`; also delete `HKLM\SOFTWARE\Microsoft\OneDrive`, `HKLM\SOFTWARE\WOW6432Node\Microsoft\OneDrive`; task `\Winhance\OneDriveRemoval` (AtLogon). User files in `%USERPROFILE%\OneDrive` are preserved. Revert: reinstall OneDriveSetup.exe from Microsoft. src detail: playbook.md, winutil-regtweaks.md, winhance.md, optimizerduck-revitool.md.

### edge.onedrive-block-backup-prompts
`HKLM\SOFTWARE\Policies\Microsoft\OneDrive\KFMBlockOptIn=1` and `HKCU\SOFTWARE\Policies\Microsoft\OneDrive\KFMBlockOptIn=1` (DWORD); no effect if backup already active. Default: delete. src detail: winhance.md.

### edge.onedrive-disable-sync-policy
`HKLM\Software\Policies\Microsoft\Windows\OneDrive\DisableFileSyncNGSC`: RV deletes the key (revert.yml, "workaround" removal); winutil autounattend sets it to 0 (no-op). Not recommended; DisableFileSyncNGSC=1 would be the real disable. src detail: playbook.md, winutil-regtweaks.md.

### edge.remove-teams
RV: kill Teams/Update/ms-teamsupdate; remove appx `MicrosoftTeams`, `MSTeams`, `Flipgrid`; `msiexec /qn /norestart /X{A7AB73A3-CB10-4AA5-9D38-6AEFFBDE4C91}` (Teams Meeting Add-in for Office). Winhance: `Get-Process *teams* | Stop-Process` first to avoid slow removal, then remove-AppxPackage -AllUsers + provisioned. Deprovision key `MSTeams`. src detail: playbook.md, winutil-regtweaks.md, winhance.md, optimizerduck-revitool.md.

### edge.block-teams-autoinstall
`HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications\ConfigureChatAutoInstall=0` (DWORD). Revert: delete. Related taskbar Chat icon items in start group. src detail: playbook.md.
