# group4 mechanisms: Explorer & Shell, Start Menu & Taskbar, Appearance, Context Menu

## Conventions used below

- `EA` = `HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced`. "DWORD"/"SZ" = REG_DWORD/REG_SZ.
- ReviOS (RV) mirrors almost every HKCU write to `HKU\.DEFAULT` with identical data ("+DEFAULT"). CAVEAT: `HKU\.DEFAULT` is the LocalSystem profile hive (used for the logon screen and system services), NOT the template for new users. The real new-user template is `C:\Users\Default\NTUSER.DAT` (loaded e.g. as `HKU\DefaultUser`, which winutil's autounattend does). Implement 👤 items as: HKCU + (optionally) HKU\.DEFAULT as RV does + loaded Default-user hive + every existing loaded/unloaded user hive.
- RV runs these registry tasks as TrustedInstaller (so HKLM policy writes and HKCR writes succeed). 🔒 in the select file reflects HKLM/HKCR/protected-key writes.
- Shell refresh: after Explorer/Start changes, RV clears appx cache for `*Client.CBS*`, `*Windows.Search*`, `*TCUI*` (and `*StartMenuExperienceHost*` only with remove-pinned-items), runs `gpupdate.exe`, then `Stop-Process explorer -Force; Start-Process explorer`. Treat as a shared post-step: restart explorer once at the end (needed for ctx.legacy-menu, shell.hide-home-gallery, notifications, Start items).
- Several values exist in two forms: HKCU user setting vs HKLM policy. Policy keys under `...\Policies\...` gray out the Settings UI; user keys can be changed back by the user.
- Values below not marked otherwise are DWORD. WH = Winhance, "rec=" = Winhance's recommended value.

---

## Explorer & Shell

### shell.show-file-extensions
- `EA\HideFileExt` = 0 (DWORD) (shown); default 1. HKCU (+DEFAULT in RV, view.yml).
- Same in WU (WPFToggleShowExt), OD (Preferences.cs), WH (explorer-customization-show-file-ext).
- Revert: HideFileExt=1.
- src detail: playbook.md (Explorer & Shell, refs Security), winutil-regtweaks.md, optimizerduck-revitool.md, winhance.md.

### shell.show-hidden-files
- `EA\Hidden` = 1 (show); 2 = hide (default). HKCU.
- src detail: winutil-regtweaks.md, optimizerduck-revitool.md, winhance.md.

### shell.show-protected-os-files
- `EA\ShowSuperHidden` = 1 (WH rec=0; default 0). HKCU. Typically paired with Hidden=1.
- src detail: winhance.md.

### shell.show-lnk-extension
- `HKCR\lnkfile\NeverShowExt` (REG_SZ): delete value to show `.lnk` (when extensions enabled); default value `""`. WH: on=null (absent), off="". Needs TI/admin on HKCR.
- Warning (WH note): some Start menu entries then show ".lnk".
- src detail: winhance.md.

### shell.launch-to-this-pc
- `EA\LaunchTo` = 1 (This PC). Other WH values: 2 Home(default), 3 Downloads, 4 OneDrive; OD also 2 = Quick Access. HKCU (+DEFAULT in RV, explorer.yml).
- WU adds with remove-home-gallery: see shell.hide-home-gallery.
- src detail: playbook.md, winutil-regtweaks.md, optimizerduck-revitool.md, winhance.md.

### shell.hide-home-gallery
- `HKCU\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}\System.IsPinnedToNameSpaceTree` = 0 (Home). Key must be created if missing.
- `HKCU\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}\System.IsPinnedToNameSpaceTree` = 0 (Gallery).
- WH additionally (to also drop the nodes everywhere): `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\NonEnum\{GUID}` = 1 and `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{GUID}\HiddenByDefault` = 1 for each GUID (WH "Show" = 0/absent). WU/OD use only the HKCU values.
- Pair with LaunchTo=1 (else Explorer opens to a hidden Home). Restart explorer. Revert: IsPinnedToNameSpaceTree=1 or delete keys.
- src detail: winutil-regtweaks.md, optimizerduck-revitool.md, winhance.md.

### shell.hide-network-navpane
- NO source in inventories. Believed mechanism: `HKCR\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}\ShellFolder\Attributes` (DWORD) with the "hide from navigation pane" bit (0x00100000 area) set; key is owned by TrustedInstaller (need ownership/TI). Must read the current value first and set/clear only the relevant bit; do NOT guess a literal value. Alternative: WH-style `NonEnum\{F02C1A0D-...}` = 1 under `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\NonEnum` (unverified for Network). Verify on test VM before implementing.
- src detail: none (added per user request).

### shell.recent-files-off
- `HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\ShowRecent` = 0; `...\Explorer\ShowRecommendations` = 0; `...\Explorer\ShowCloudFilesInQuickAccess` = 0 (WH, Win11). Defaults 1 (cloud: absent). HKCU.
- Related but separate: Start recent lists in start.layout-lists-prefs.
- src detail: winhance.md.

### shell.frequent-folders-off
- `HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\ShowFrequent` = 0 (default 1). HKCU.
- src detail: winhance.md.

### shell.navpane-options
- WH values (all optional, user picks): `EA\NavPaneExpandToCurrentFolder` (1 on; default 1 per WH def), `EA\NavPaneShowAllFolders` (1 on, default 0), `EA\NavPaneShowAllCloudStates` (1 on, default 0).
- Libraries: `HKCU\Software\Classes\CLSID\{031E4825-7B94-4dc3-B131-E946B44C8DD5}\System.IsPinnedToNameSpaceTree` = 1 to show (no effect with ShowAllFolders), plus `HKLM\...\Policies\NonEnum\{031E4825-...}` and `HKLM\...\Explorer\Desktop\NameSpace\{031E4825-...}\HiddenByDefault` (rec=1 means hide Libraries).
- User folders in nav pane (HKLM, hide = set 1; show = delete): `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\NonEnum\{GUID}`=1 and `...\Explorer\Desktop\NameSpace\{GUID}\HiddenByDefault`=1 for Desktop {B4BFCC3A-DB2C-424C-B029-7FE99A87C641}, Documents {A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}, Downloads {374DE290-123F-4565-9164-39C4925E467B}, Music {1CF1260C-4DD0-4ebb-811F-33C572699FDE}, Pictures {3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}, Videos {A0953C92-50DC-43bf-BE83-3742FED03C9C}.
- Duplicate removable drives: key `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}` (and the WOW6432Node twin) present = show duplicates.
- src detail: winhance.md.

### shell.this-pc-folders-hide
- Per folder, HKLM (and WOW6432Node twin): `HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{GUID}\HiddenByDefault` = 1 (hide, WH rec for 24H2) / 0 (show). GUIDs: Desktop {B4BFCC3A-DB2C-424C-B029-7FE99A87C641}, Documents {D3162B92-9365-467A-956B-92703ACA08AF}, Downloads {088E3905-0323-4B02-9826-5D99428E115F}, Music {3DFDF296-DBEC-4FB4-81D1-6A3438BCF4DE}, Pictures {24AD3AD4-A569-4530-98E1-AB02F9417AA8}, Videos {F86FA3AB-70D2-4FC7-9C99-FCBF05467F3A}. WH marks these Win11-only; default is 1 (hidden by default) on current builds.
- src detail: winhance.md.

### shell.compact-view
- `EA\UseCompactMode` = 1 (default 0). HKCU.
- src detail: optimizerduck-revitool.md, winhance.md.

### shell.item-checkboxes
- `EA\AutoCheckSelect` = 1 (default 0). HKCU.
- src detail: optimizerduck-revitool.md, winhance.md.

### shell.full-path-title
- `HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState\FullPath` = 1 (DWORD). RV +DEFAULT (view.yml); WH default shown as 1.
- src detail: playbook.md, winhance.md.

### shell.sync-provider-notifications-off
- `EA\ShowSyncProviderNotifications` = 0 (DWORD; default 1/absent). HKCU (+DEFAULT in RV, view.yml).
- src detail: playbook.md, optimizerduck-revitool.md, winhance.md.

### shell.info-tips-off
- `EA\ShowInfoTip` = 0 (DWORD; default 1). HKCU (+DEFAULT; RV explorer.yml). WH exposes as toggle (rec=1 i.e. keep) - RV differs: RV turns off.
- src detail: playbook.md, winhance.md.

### shell.shortcut-suffix-off
- `HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\link` (REG_BINARY) = `00 00 00 00` (+DEFAULT). Revert: delete value (default absent).
- src detail: playbook.md, winhance.md.

### shell.shortcut-arrow-remove
- `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons\29` (REG_SZ) = `C:\Windows\blank.ico`. WH script creates `%SystemRoot%\blank.ico` from an embedded base64 transparent icon if missing; the tool must ship a blank .ico (OD uses same approach). Revert: delete value 29. Restart explorer / clear icon cache.
- src detail: optimizerduck-revitool.md, winhance.md.

### shell.desktop-icons
- Per icon, DWORD 0 = shown, 1 = hidden: `HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel\{GUID}` and (WH also) `...\HideDesktopIcons\ClassicStartMenu\{GUID}`. GUIDs: This PC {20D04FE0-3AEA-1069-A2D8-08002B30309D} (WH rec shown=0... WH rec value 1 = hide; def=1), Recycle Bin {645FF040-5081-101B-9F08-00AA002F954E} (default shown), User files {59031A47-3F72-44A7-89C5-5595FE6B30EE}, Control Panel {5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}, Network {F02C1A0D-BE21-4350-88B0-7367FC96EF3C}. Absent = hidden except Recycle Bin.
- Hide all desktop icons: `EA\HideIcons` = 1 (OD).
- Refresh desktop after (broadcast / restart explorer).
- src detail: optimizerduck-revitool.md, winhance.md.

### shell.hide-spotlight-desktop-icon
- `HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel\{2cc5ca98-6485-489a-920e-b3e88a6ccce3}` = 1 (DWORD). 24H2 "Learn more about this picture" icon. RV always. (Per-user hide key normally HKCU; RV chose HKLM.)
- src detail: playbook.md.

### shell.explorer-window-behavior
- `EA\SeparateProcess` = 1; `EA\PersistBrowsers` = 1 (restore windows at logon); `HKCU\...\Explorer\CabinetState\Settings` (REG_BINARY) 0 same window / 1 own window; `HKCU\...\Explorer\ShellState` (REG_BINARY) + `Explorer\IconUnderline` (DWORD, default 3) for single/double-click (WH options: double-click ShellState=1; single-click ShellState=0 with IconUnderline 3 or 2). Defaults: SeparateProcess 0, PersistBrowsers 0.
- Winhance values as given; any are optional.
- src detail: winhance.md.

### shell.view-misc
- All HKCU under `EA` unless noted: `ShowStatusBar`=1 (default 1); `ShowDriveLettersFirst` (on=absent, off=2; value 4 hides letters... WH lists only absent/2); `HideDrivesWithNoMedia`=0 (show empty drives; default 1); `FolderContentsInfoTip`=0 (hide size tips); `TypeAhead` 0 select / 1 type into search; `HideMergeConflicts`=0 (show prompts; rec=0); `SharingWizardOn`=0 (off; rec=0); `ShowEncryptCompressedColor`=1 (default); `ShowPreviewHandlers`=0 (off; rec=0); `ShowTypeOverlay`=1; `IconsOnly` (see shell.thumbnails-icons-only).
- WH marks most [pref]; choose a small default subset when implementing.
- src detail: winhance.md.

### shell.thumbnails-icons-only
- `EA\IconsOnly` = 1 (icons, no thumbnails; default 0). WH lists inverse in Performance ("Show thumbnails instead of icons" off = IconsOnly=1). HKCU.
- src detail: winhance.md.

### shell.icon-thumbnail-cache
- `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MaxCachedIcons` (REG_SZ) = "4096" or "8192"; default absent.
- `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache\Autorun` (DWORD) = 0 stops disk-cleanup purge of thumbnails (default 3; WH rec 3, "off"=0, on=3,1 ) and the same under `HKLM\SOFTWARE\WOW6432Node\...`.
- src detail: winhance.md.

### shell.photo-viewer-restore
- ReviOS (classic-photo-viewer.yml, option remove-appx-photos): registers `PhotoViewer.dll` -- ~90 values under `HKCR\PhotoViewer.FileAssoc.{Bitmap,JFIF,Jpeg,Gif,Png,Wdp}` (shell\open\command with `%SystemRoot%\System32\rundll32.exe "%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll", ImageView_Fullscreen %1`, DropTarget CLSID, etc.), `HKCR\Applications\photoviewer.dll`, `HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities` (+ `FileAssociations` for .jpg .jpeg .png .gif .bmp .tif .tiff .ico .jfif .dib .jpe .jxr .wdp), `HKCU` and `HKU\S-1-5-18\Software\Classes\.<ext>` default = `PhotoViewer.FileAssoc.Tiff` (Wdp for .wdp/.jxr), `HKCR\SystemFileAssociations\image\shell\Image Preview` (Photo Viewer "Open with"/preview verbs, listed in RV under Context Menu).
- RV final.yml runs `FILEASSOC.cmd`: copies `OEMDefaultAssociations.xml` to `%WINDIR%\System32` and runs `assoc.ps1` per user mapping .bmp .dib .jfif .jpe .jpeg .jpg .jxr .png .tif .tiff .wdp to `PhotoViewer.FileAssoc.*`. (RV default-on only when remove-appx-photos selected.)
- WH: only `HKCU\Software\Classes\.bmp` default = `PhotoViewer.FileAssoc.Tiff` plus a .reg import (full content not in inventory; WH reg import covers other extensions) and no OEM associations.
- Prereq: `%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll` still ships in 24H2 (verify). Gotcha: existing UserChoice hashes override; per-user ProgId pairing happens only at first login for new users.
- src detail: playbook.md, winhance.md.

### shell.legacy-notepad
- `HKLM\SOFTWARE\Classes\Applications\notepad.exe\NoOpenWith` (REG_SZ) delete (WH on=absent, off=""); `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe\UseFilter` (DWORD) = 0 (default 1; stops redirect to Store Notepad); script deletes `HKCU\Software\Microsoft\Windows\CurrentVersion\App Paths\notepad.exe` if present. Requires Notepad (Legacy) Windows capability installed (Features group).
- src detail: winhance.md.

### shell.tablet-mode-desktop
- `HKCU\Software\Microsoft\Windows\CurrentVersion\ImmersiveShell`: SignInMode=1, TabletMode=0, ConvertibleSlateModePromptPreference=2 (+DEFAULT). `EA`: TaskbarAppsVisibleInTabletMode=1, TaskbarAutoHideInTabletMode=0 (+DEFAULT). RV always (win-settings.yml).
- src detail: playbook.md.

### shell.scrollbars-always-visible
- `HKCU\Control Panel\Accessibility\DynamicScrollbars` = 0 (DWORD in WU). Revert: 1. Note: look.accessibility-reset deletes this whole Accessibility tree, which would drop the value; apply this after the reset.
- src detail: winutil-regtweaks.md.

### shell.window-snap-settings
- WU: `HKCU\Control Panel\Desktop\WindowArrangementActive` = 1 (REG_SZ) enables snapping.
- OD: `EA\DisallowShaking` = 1 (Aero Shake off); `EA\EnableSnapAssistFlyout` = 0 (Win11 snap flyout off).
- src detail: winutil-regtweaks.md, optimizerduck-revitool.md.

### shell.numlock-on
- `HKCU\Control Panel\Keyboard\InitialKeyboardIndicators` (REG_SZ) = "2" and `HKU\.DEFAULT\Control Panel\Keyboard\InitialKeyboardIndicators` = "2" (WU). OD: sets bit 2 of the existing value in both hives (keeps other bits). Takes effect next boot/logon. HKU\.DEFAULT is the one that matters for the logon screen.
- src detail: winutil-regtweaks.md, optimizerduck-revitool.md.

### shell.capslock-disable
- `HKLM\SYSTEM\CurrentControlSet\Control\Keyboard Layout\Scancode Map` (REG_BINARY) = `00 00 00 00 00 00 00 00 02 00 00 00 00 00 3A 00 00 00 00 00`. Reboot. Revert: delete value. Revitool CLI `caps-lock`.
- src detail: optimizerduck-revitool.md.

### shell.clipboard-history
- `HKCU\Software\Microsoft\Clipboard\EnableClipboardHistory` = 1 (DWORD). Revert 0.
- src detail: optimizerduck-revitool.md.

### shell.settings-home-hide
- `HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\SettingsPageVisibility` (REG_SZ) = `hide:home`. If other items also hide Settings pages (notifications/privacy-notifications from shell.toast-notifications-off full mode), merge into one semicolon list: `hide:home;notifications;privacy-notifications`.
- src detail: winutil-regtweaks.md, optimizerduck-revitool.md.

### shell.toast-notifications-off
- WU (ADV): `HKCU\Software\Policies\Microsoft\Windows\Explorer\DisableNotificationCenter` = 1; `HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications\ToastEnabled` = 0. Kills Calendar flyout.
- OD simple: `PushNotifications\ToastEnabled`=0, `LockScreenToastEnabled`=0 (HKCU).
- Revitool offMinimal: delete `DisableNotificationCenter` (HKLM+HKCU `...\Policies\Microsoft\Windows\Explorer`); `HKCU\Software\Policies\Microsoft\Windows\CurrentVersion\PushNotifications\NoToastApplicationNotification`=1; `HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\` `NOC_GLOBAL_SETTING_ALLOW_NOTIFICATION_SOUND`, `NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK`, `NOC_GLOBAL_SETTING_ALLOW_CRITICAL_TOASTS_ABOVE_LOCK`, `NOC_GLOBAL_SETTING_TOASTS_ENABLED` = 0; `ToastEnabled`=0 at HKLM+HKCU `...Policies\Microsoft\Windows\Explorer` and `...CurrentVersion\PushNotifications`; ConsentStore `userNotificationListener` `Value`="Deny" (HKLM+HKCU). offFull adds `DisableNotificationCenter`=1 (HKLM+HKCU), Wpn* services Start=4, hides Settings pages `notifications`, `privacy-notifications`. Restart explorer.
- Legacy balloons: `HKCU\Software\Policies\Microsoft\Windows\Explorer\EnableLegacyBalloonNotifications` = 1/0.
- RV (notifications.yml) separately: see start.notification-area-cleanup.
- Revert: delete policies, set toggles to 1.
- src detail: winutil-regtweaks.md, optimizerduck-revitool.md, winhance.md (notification toggles in Privacy/Notifications, not read in full).

### shell.edge-swipe-off
- `HKLM\SOFTWARE\Policies\Microsoft\Windows\EdgeUI\AllowEdgeSwipe` = 0; revert: delete.
- src detail: optimizerduck-revitool.md.

### shell.verbose-logon
- `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\VerboseStatus` = 1.
- src detail: winutil-regtweaks.md, optimizerduck-revitool.md.

### shell.detailed-bsod
- `HKLM\SYSTEM\CurrentControlSet\Control\CrashControl`: DisplayParameters=1, DisableEmoticon=1.
- src detail: winutil-regtweaks.md.

### shell.time-utc
- `HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation\RealTimeIsUniversal` = 1 (DWORD; WU uses QWORD). Dual-boot only; breaks time on Windows-only systems (clock off by TZ offset).
- src detail: winutil-regtweaks.md.

### shell.long-paths
- `HKLM\SYSTEM\CurrentControlSet\Control\FileSystem\LongPathsEnabled` = 1 (default 0).
- src detail: winhance.md.

### shell.default-printer-management-off
- `HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows\LegacyDefaultPrinterMode` = 1 (default 0).
- src detail: winhance.md.

### shell.cross-device-resume-block
- `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell\ShellUIHosts\CrossDeviceResumeHost\ProcessPath` = `%SystemRoot%\system32\ShellHost.exe` (REG_SZ; RV calls it the reliable method); `HKCU\Software\Microsoft\Windows\CurrentVersion\CrossDeviceResume\Configuration\IsResumeAllowed` = 0; `HKLM\SOFTWARE\Microsoft\PolicyManager\default\Connectivity\DisableCrossDeviceResume\value` = 1. RV applies only with option remove-appx-yourphone. Gotcha: ReviOS notes DisableWindowsConsumerFeatures breaks Your Phone (not set).
- src detail: playbook.md.

---

## Start Menu & Taskbar

### start.remove-pinned-items
Full ReviOS technique (STARTMENU.cmd + start-menu.yml + final.yml, all under option remove-pinned-items-startmenu, default ON). Capture ALL steps:
1. Policy: `HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start\ConfigureStartPins` (REG_SZ) = `{"pinnedList":[{"packagedAppId":"Microsoft.WindowsStore_8wekyb3d8bbwe!App"},{"packagedAppId":"windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel"},{"packagedAppId":"Microsoft.WindowsNotepad_8wekyb3d8bbwe!App"},{"packagedAppId":"Microsoft.Paint_8wekyb3d8bbwe!App"},{"desktopAppLink":"%APPDATA%\\Microsoft\\Windows\\Start Menu\\Programs\\File Explorer.lnk"},{"packagedAppId":"Microsoft.WindowsCalculator_8wekyb3d8bbwe!App"}]}` (TI privilege). Empty variant (WU autounattend SetStartPins.ps1 and WH): `{"pinnedList":[]}`.
2. Layout files (from RV Executables): `LayoutModification.xml` (empty StartLayout override: `<LayoutOptions StartTileGroupCellWidth="6"/><DefaultLayoutOverride><StartLayoutCollection><defaultlayout:StartLayout GroupCellWidth="6"/></StartLayoutCollection></DefaultLayoutOverride>`), `LayoutModification.json` (same 6-pin pinnedList JSON as above), `DefaultLayouts.xml` (FullDefaultLayoutTemplate with Education/Commercial 6-wide layouts). Copy to `%SystemDrive%\Users\Default\AppData\Local\Microsoft\Windows\Shell\` (mkdir first) for future users, AND into `<Local AppData>\Microsoft\Windows\Shell\` of every existing profile (RV enumerates `HKU` SIDs `S-*` / `AME_UserHive_*` that have a `Volatile Environment` key and reads `Shell Folders\Local AppData`).
3. For each existing profile delete `<LocalAppData>\Packages\Microsoft.Windows.StartMenuExperienceHost*\LocalState\start.bin`, `start2.bin`, `startN.bin` (pattern `start.\.bin` and `start\.bin`). WH does same via `HKLM\...\ProfileList` S-1-5-21-* with ProfileImagePath, skipping Public/Default/All Users/Default User, then kills `StartMenuExperienceHost`.
4. For each loaded user hive delete keys under `HKU\<sid>\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount` whose name matches `*start.tilegrid*` (reg delete /f on each).
5. `reg delete "HKU\<sid>\Software\Microsoft\Windows\CurrentVersion\Start" /v Config /f` (23H2 note: "removing StartMenu AppX cache is also required").
6. Delete legacy `%SystemDrive%\Windows\StartMenuLayout.xml` if present (import via Import-StartLayout is commented out in RV).
7. Revert #61 (CBS DLL restore): in `%SystemDrive%\Windows\SystemApps\MicrosoftWindows.Client.CBS_cw5n1h2txyewy` rename `WsxPackManager.dll.bak`, `WebExperienceHostApp.exe.bak`, `WebExperienceHost.dll.bak`, `SystemSettingsExtensions.dll.bak` back to original names when original is missing (older RV versions renamed them; replaced by "more reliable method").
8. Clear appx cache: `*StartMenuExperienceHost*` (only with this option), plus unconditional `*Client.CBS*`, `*Windows.Search*`, `*TCUI*` (final.yml), then `gpupdate.exe`, restart explorer.
9. Aside: STARTMENU.cmd also copies `settings.json` to `Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState` for Default and existing users (winget settings, belongs to Misc, not Start).
- WH additional (build gating, KB5062660 Jul 2025): `ConfigureStartPins` needs BOTH `HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start\ConfigureStartPins` and the GPO path `HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer\ConfigureStartPins` (REG_SZ `{"pinnedList":[]}`); on 26200.8521+ only the GPO path clears default Edge/Settings/Explorer pins. WH's Default-profile XML script (empty LayoutModification.xml to `C:\Users\Default\...\Shell\`) is flagged IsWindows10Only in WH.
- Build notes: ConfigureStartPins is officially Enterprise/Education-supported; behavior on Pro 24H2 is UNVERIFIED (RV works via the TI-written PolicyManager path). winutil flags its own old-layout tweak as not working on 25H2+. After this runs, pins show only on first Start launch for new profiles.
- Revert: delete ConfigureStartPins values; delete LayoutModification files; user re-pins manually (bin files recreate).
- src detail: playbook.md, winutil-regtweaks.md, winhance.md (+ spot-check references\playbook\src\Executables\STARTMENU.cmd, LayoutModification.*, DefaultLayouts.xml, Configuration\Tasks\registry\explorer\start-menu.yml, final.yml; Winhance StartMenuCustomizations.cs).

### start.default-user-layout
- Goal: new accounts get a clean Start/taskbar. Mechanisms across sources:
  - RV: layout files copied into `C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\` (see start.remove-pinned-items step 2) before profiles are created; plus HKCU->HKU\.DEFAULT mirroring (not the real template, see conventions).
  - WU autounattend: layout XML with empty `TaskbarPinList`; sets `HKU\default\Software\Policies\Microsoft\Windows\Explorer\StartLayoutFile` and `LockedStartLayout`=1, later cleared by an UnlockStartLayout scheduled task; deletes `HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband\{Favorites,FavoritesChanges,FavoritesRemovedChanges}` and `Quick Launch\User Pinned\TaskBar` files. WU also writes toggles (ShowTaskViewButton, TaskbarAl, SearchboxTaskbarMode, TaskbarEndTask) into the loaded Default-user hive.
  - Implementation: `reg load HKU\DefaultUser C:\Users\Default\NTUSER.DAT`, write every 👤 value there, `reg unload`. Setup-time only; no effect on existing users.
- src detail: playbook.md (Ordering notes), winutil-regtweaks.md, winhance.md.

### start.pinned-folders-hidden
- `HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start`: `AllowPinnedFolder{Documents,Downloads,FileExplorer,HomeGroup,Music,Network,PersonalFolder,Pictures,Videos}` = 0 (DWORD) and `AllowPinnedFolder<X>_ProviderSet` = 0; `AllowPinnedFolderSettings` = 1 with `_ProviderSet`=0. (RV comment: `_ProviderSet`=1 blocks user toggling; 0 allows.) RV start-menu.yml, TI.
- Also in same file: `HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoResolveSearch` = 1 (+DEFAULT) - "do not use search-based method when resolving shell shortcuts" (not a separate select item; bundle with this item).
- src detail: playbook.md.

### start.recommendations-account-notifs-off
- `EA\Start_IrisRecommendations` = 0, `EA\Start_AccountNotifications` = 0 (DWORD; defaults 1). HKCU (+DEFAULT). RV explorer.yml (Start_TrackProgs commented out).
- src detail: playbook.md, winhance.md.

### start.hide-recommended-section
- WU/WH: `HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start\HideRecommendedSection` = 1; `HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Education\IsEducationEnvironment` = 1; `HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer\HideRecommendedSection` = 1. WH also writes `HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer\HideRecommendedSection`. OD uses only the HKCU policy.
- Side effect (WU/WH): disables Spotlight on lock screen and Settings suggestions; WH forces Recommended to Show when those are re-enabled. Revert: delete values (WH: HideRecommendedSection and IsEducationEnvironment absent).
- Conflicts with nothing but overlaps start.recommendations-account-notifs-off (which is the milder version).
- src detail: winutil-regtweaks.md, optimizerduck-revitool.md, winhance.md.

### start.layout-lists-prefs
- WH, all HKCU: `EA\Start_Layout` 0 default / 1 more pins (rec) / 2 more recommendations; `HKCU\Software\Microsoft\Windows\CurrentVersion\Start\AllAppsViewMode` 0 category (def) / 1 grid / 2 list (rec) - needs build 26100.7171; `...\Start\ShowRecentList` (0 hide recently added; rec 0); `...\Start\ShowFrequentList` (0 hide most used; rec 0); `EA\Start_TrackDocs` (0 hide recent files in Start; rec 0).
- src detail: winhance.md.

### start.taskbar-search-mode
- `HKCU\Software\Microsoft\Windows\CurrentVersion\Search\SearchboxTaskbarMode` (DWORD). Win11 values: 0 hidden, 1 icon only, 2 box (WH default), 3 icon + label. NOTE OD says Win11: 0 hidden, 1 icon, 2 icon+label, 3 box - sources disagree on 2 vs 3; WH is read from source with `Search box(def)=2, icon and label=3`; verify on build. RV = 1 (+DEFAULT); WU = 0 (also set by WU Display tweak); WH rec = 0.
- src detail: playbook.md, winutil-regtweaks.md, optimizerduck-revitool.md, winhance.md.

### start.web-search-off
- `HKCU\Software\Microsoft\Windows\CurrentVersion\Search\BingSearchEnabled` = 0 (+DEFAULT; also `CortanaConsent`=0 in RV); `HKCU\Software\Policies\Microsoft\Windows\Explorer\DisableSearchBoxSuggestions` = 1 (+DEFAULT); WH also writes the HKLM twin `HKLM\Software\Policies\Microsoft\Windows\Explorer\DisableSearchBoxSuggestions`=1. OD perf variant uses only the policy. On 25H2+ BingSearchEnabled is needed because the redesigned Start reads the user key independent of GPO (WH note).
- src detail: playbook.md, optimizerduck-revitool.md, winhance.md.

### start.cortana-cloud-search-off
- RV search.yml: `HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search`: AllowCloudSearch=2, AllowCortanaAboveLock=0, AllowCortana=1 (sic; comment says Disabled - verify; intended value 0), AllowCortanaInAAD=0, AllowCortanaInAADPathOOBE=0, AllowSearchToUseLocation=0, ConnectedSearchUseWeb=0, ConnectedSearchUseWebOverMeteredConnections=0, DisableWebSearch=1, ConnectedSearchPrivacy=3. Plus `HKLM\SOFTWARE\Microsoft\Speech_OneCore\Preferences\VoiceActivationEnableAboveLockscreen` = 0. (All DWORD.) CortanaConsent noted as "1909 and lower" in RV.
- src detail: playbook.md.

### start.search-store-results-off
- `HKLM\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\WinStore.Tasks.WindowsSearchTask`: `ActivationType` = 4294967295 (DWORD), `Server` = "" (REG_SZ). 25H2 only per RV.
- src detail: playbook.md.

### start.searchhost-webview2-block
- `HKLM\SYSTEM\ControlSet001\Policies\Microsoft\FeatureManagement\Overrides`: values named `1694661260` = 0 and `3369582732` = 0 (DWORD) (feature SearchWebView2_Master, ids 43998308 / 3369582732). Undocumented; Windows Update may revert/change IDs.
- src detail: playbook.md.

### start.task-view-off
- `EA\ShowTaskViewButton` = 0 (DWORD; default 1). HKCU (+DEFAULT; WU also in DefaultUser).
- src detail: playbook.md, winutil-regtweaks.md, optimizerduck-revitool.md, winhance.md.

### start.widgets-off
- RV taskbar.yml: `HKLM\SOFTWARE\Policies\Microsoft\Windows Feeds\EnableFeeds` ... exact path `HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds\EnableFeeds` = 0; `HKCU\Software\Microsoft\Windows\CurrentVersion\Feeds\ShellFeedsTaskbarViewMode` = 2 (OD uses 0); `EA\TaskbarDa` = 0 (+DEFAULT, errorAction Ignore - the value is protected on recent builds, may need TI or fail silently); `HKLM\SOFTWARE\Policies\Microsoft\Dsh\AllowNewsAndInterests` = 0 (stops WebExperience reinstall since 22621.1343). WH writes AllowNewsAndInterests under both HKLM and HKCU (HKCU\Software\Policies\Microsoft\Dsh).
- Appx: RV/WU remove `MicrosoftWindows.Client.WebExperience` and `Microsoft.WidgetsPlatformRuntime` (Appx group owns removal; WU kills `*Widget*` processes first).
- src detail: playbook.md, winutil-regtweaks.md, optimizerduck-revitool.md, winhance.md.

### start.chat-meetnow-off
- `HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Chat\ChatIcon` = 3 (DWORD; 3 = disabled); `EA\TaskbarMn` = 0 (+DEFAULT); `HKCU` and `HKLM` `SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\HideSCAMeetNow` = 1; `HKCU\Software\Policies\Microsoft\Windows\Explorer\HidePeopleBar` = 1. WU sets only TaskbarMn=0. OD's Meet Now is Win10-only (irrelevant on 24H2).
- src detail: playbook.md, winutil-regtweaks.md, optimizerduck-revitool.md.

### start.taskbar-alignment-left
- `EA\TaskbarAl` = 0 (left); 1 = center (default). HKCU; WU also in DefaultUser.
- src detail: winutil-regtweaks.md, optimizerduck-revitool.md, winhance.md.

### start.end-task
- `EA\TaskbarDeveloperSettings\TaskbarEndTask` = 1 (DWORD; default 0). Key `TaskbarDeveloperSettings` may need creating. HKCU (+DEFAULT).
- src detail: playbook.md, winutil-regtweaks.md, optimizerduck-revitool.md, winhance.md.

### start.notification-area-cleanup
- `HKCU\Software\Policies\Microsoft\Windows\Explorer`: NoAutoTrayNotify=1, NoBalloonFeatureAdvertisements=1 (+DEFAULT). RV revert.yml deletes `HKCU\...\Explorer\EnableAutoTray` (older tweak undone).
- src detail: playbook.md.

### start.tray-icons-show-all
- WH script (Win11): `HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\TrayNotify\SystemTrayChevronVisibility` = 0 (DWORD; 1 hides all into overflow), and for each subkey of `HKCU\Control Panel\NotifyIconSettings` set `IsPromoted` = 1 (script text truncated in inventory; verify). Restart explorer.
- src detail: winhance.md.

### start.tray-clock-battery
- `EA\ShowSecondsInSystemClock` = 1 (OD); `EA\IsBatteryPercentageEnabled` = 1 (WU). HKCU.
- src detail: winutil-regtweaks.md, optimizerduck-revitool.md.

### start.taskbar-behavior
- All `EA` HKCU DWORD (WH defaults/options): `TaskbarGlomLevel` 0 always / 1 when full / 2 never (OD same); `MMTaskbarGlomLevel` same for other displays; `MMTaskbarEnabled` (1 show on all displays); `MMTaskbarMode` 0 all / 1 main + window / 2 window only; `TaskbarBadges` (1 default); `TaskbarFlashing` (1 default); `TaskbarSn` (share window, 1 default); `TaskbarSd` (show-desktop corner, 1 default); `IconSizePreference` 0 always small / 1 never / 2 when full (default; needs 26100.4484; may not persist); `ExtendedUIHoverTime` ms (WH rec 1; default 400; RequiresRestart); `LastActiveClick` = 1 (OD). Auto-hide: `HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3\Settings` REG_BINARY, byte 8 = 3 (auto-hide) / 2 (normal), edit in place.
- src detail: optimizerduck-revitool.md, winhance.md.

### start.clean-taskbar-pins
- WH: `HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband\Favorites` (REG_BINARY) = empty byte array (delete to restore). WU (setup): also delete `Taskband\{Favorites,FavoritesChanges,FavoritesRemovedChanges}` and clear `%APPDATA%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar`. Restart explorer.
- src detail: winutil-regtweaks.md, winhance.md.

### start.old-start-layout
- WU: `HKLM\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\8\3036241548\EnabledState` = 1. winutil says "WILL NOT WORK" on newer builds (25H2+); likely n/a on 24H2+ too. Listed as not recommended.
- src detail: winutil-regtweaks.md.

---

## Appearance

### look.dark-mode
- `HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize`: AppsUseLightTheme=0, SystemUsesLightTheme=0 (DWORD; light = 1). RV +DEFAULT (final.yml, option configure-darkmode, default on).
- RV also runs `Set-Theme.ps1`: applies `%SystemRoot%\Resources\Themes\dark.theme` (no wallpaper) or builds `revi.theme` with SystemMode/AppMode Dark when wallpaper selected (2x2 matrix wallpaper x darkmode).
- WU autounattend (SetColorTheme.ps1) additionally: `ColorPrevalence`=0, `EnableTransparency`=0, accent #0078D4 via `Explorer\Accent` (AccentColorMenu, StartColorMenu), `DWM\AccentColor`, AccentPalette bytes 20-23, `DWM\ColorPrevalence`=0.
- WH: `Personalize` same two values (rec=Dark). Apply requires broadcasting WM_SETTINGCHANGE (apps pick up live).
- src detail: playbook.md, winutil-regtweaks.md, optimizerduck-revitool.md, winhance.md.

### look.transparency-off
- `HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize\EnableTransparency` = 0 (DWORD; default 1). RV configure-te (default on) ALSO writes `HKCU\Control Panel\Desktop\WindowMetrics\MinAnimate` = "0" (REG_SZ): that part is moved to look.animations-off here; implementers may emit both when this is selected to match RV. OD includes transparency in its "reduce visual effects"; WU autounattend writes it.
- src detail: playbook.md, winutil-regtweaks.md, optimizerduck-revitool.md, winhance.md.

### look.wallpaper-revision
- RV (option configure-wallpaper, default on): robocopy `Wallpapers\` to `%SystemRoot%\Web\Wallpaper\MeetRevision\v2`; `WALLPAPER.ps1 -Mode Desktop|LockScreen`; copy `WALLPAPER.ps1` and `WallpaperStartup.cmd` to `%SystemRoot%\Web\Wallpaper\MeetRevision`; during OOBE add `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce\RevisionWallpaperStartup` (REG_SZ) = `cmd /c "%SystemRoot%\Web\Wallpaper\MeetRevision\WallpaperStartup.cmd"`. Assets and scripts live in references\playbook (not inventoried). Branding: excluded unless user chooses.
- src detail: playbook.md.

### look.accent-palette
- RV: `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Accents\{0..3}\Theme{0,1}\Color` (DWORD) = 4279374354, 4278190294, 4294926889, 4282117119, 4278229247, 4283680768, 4294901930, 4294967064 (values in order across the key list in RV win-settings.yml; exact key-to-value mapping needs a re-read of that file). 
- WU: single accent #0078D4 through per-user DWM/Explorer\Accent keys (see look.dark-mode).
- src detail: playbook.md, winutil-regtweaks.md.

### look.animations-off
- RV: `HKCU\Control Panel\Desktop\WindowMetrics\MinAnimate` = "0" (REG_SZ) (shipped with transparency); `EA\TaskbarAnimations` = 0 (DWORD) - RV gate option `configure-explorer-taskbar-animations` is not defined in playbook.conf, so the "!"-branch deletes the value (verify intent).
- WU "visual effects best performance": MinAnimate="0"; `EA\TaskbarAnimations`=0; `HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\VisualFXSetting`=3 (custom); `HKCU\Control Panel\Desktop\UserPreferencesMask` (REG_BINARY) = `90 12 03 80 10 00 00 00`.
- OD: TaskbarAnimations=0 only for animations.
- src detail: playbook.md, winutil-regtweaks.md, optimizerduck-revitool.md.

### look.visual-effects
- WU: `HKCU\Control Panel\Desktop\DragFullWindows` = "0" (REG_SZ); `EA\ListviewAlphaSelect` = 0; `EA\ListviewShadow` = 0; `HKCU\Software\Microsoft\Windows\DWM\EnableAeroPeek` = 0; `UserPreferencesMask` binary above (same key as look.cursor-shadow-off).
- OD DisableVisualEffects: TaskbarAnimations=0, ListviewShadow=0, EnableTransparency=0, EnableAeroPeek=0.
- WH per-setting (collapsed): `DWM\AlwaysHibernateThumbnails` (1 saves taskbar thumbs), `UserPreferencesMask` bits for pointer shadow and window shadows (rec 0 each), `ListviewAlphaSelect` (translucent selection, default 1), `IconsOnly` (thumbnails).
- Write UserPreferencesMask once as a computed binary (read-modify-write; never blindly overwrite).
- src detail: winutil-regtweaks.md, optimizerduck-revitool.md, winhance.md.

### look.jpeg-quality-100
- `HKCU\Control Panel\Desktop\JPEGImportQuality` = 100 (DWORD) (+DEFAULT). WH "Allow wallpaper compression" off = 100.
- src detail: playbook.md, winhance.md.

### look.beeps-off
- `HKCU\Control Panel\Sound\Beep` = "no" (REG_SZ) (+DEFAULT). Gotcha (RV revert): do NOT set `Beep` service to Disabled; reverted to start=1 by ReviOS (broke something).
- src detail: playbook.md.

### look.startup-sound-off
- `HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System`: EnableFirstLogonAnimation=0, DisableStartupSound=1 (RV logon.yml). WH: `HKLM\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation\DisableStartupSound` = 1 and `HKLM\Software\Microsoft\Windows\CurrentVersion\EditionOverrides\UserSetting_DisableStartupSound` = 1.
- src detail: playbook.md, winhance.md.

### look.audio-ducking-off
- `HKCU\Software\Microsoft\Multimedia\Audio\UserDuckingPreference` = 3 (DWORD; Do nothing). WH options 0 mute all / 1 reduce 80% / 2 reduce 50% / 3 do nothing. Also WH: `HKCU\Software\Microsoft\Narrator\NoRoam\DuckAudio`=0.
- src detail: playbook.md, winhance.md.

### look.menu-responsiveness
- RV control-panel.yml (+DEFAULT): `HKCU\Control Panel\Desktop\MenuShowDelay` = "0" (REG_SZ); `ActiveWndTrkTimeout` = 10 (DWORD). `MouseHoverTime` NOT lowered: RV reverted to 400 (lower caused overlapping tooltips). OD: also `HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize\StartupDelayInMSec` = 0. WU uses MenuShowDelay="200". WH offers `HKCU\Control Panel\Mouse\MouseHoverTime` options (1..400; rec 1) - conflicts with the RV gotcha; do not adopt.
- Other RV control-panel.yml values likely owned by Perf group: AutoEndTasks="1", HungAppTimeout="2000", WaitToKillAppTimeout="2000", LowLevelHooksTimeout="1000" (all REG_SZ, HKCU + DEFAULT); `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\AllowOnlineTips`=0.
- src detail: playbook.md, winutil-regtweaks.md, optimizerduck-revitool.md, winhance.md (+ spot-check references\playbook control-panel.yml).

### look.mouse-accel-off
- `HKCU\Control Panel\Mouse`: MouseSpeed="0", MouseThreshold1="0", MouseThreshold2="0" (REG_SZ) (+DEFAULT). "On" = 1/6/10. OD/WH same; WH only writes MouseSpeed (rec 0). OD also `RawMouseThrottleEnabled`/`RawMouseThrottleDuration` (revitool, separate Gaming feature).
- src detail: playbook.md, winutil-regtweaks.md, optimizerduck-revitool.md, winhance.md.

### look.keyboard-repeat-max
- `HKCU\Control Panel\Keyboard\KeyboardDelay` = "0", `KeyboardSpeed` = "31" (REG_SZ). WU sets only KeyboardDelay.
- src detail: winutil-regtweaks.md, optimizerduck-revitool.md.

### look.cursor-shadow-off
- `HKCU\Control Panel\Desktop\UserPreferencesMask` (REG_BINARY) - pointer-shadow bit (WH: rec 0). Cursor scheme/size not covered by any inventory. Combine with look.visual-effects mask write.
- src detail: winhance.md.

### look.sticky-keys-prompts-off
- `HKCU\Control Panel\Accessibility`: `StickyKeys\Flags` ="26" (OD) / "506" (WU) / "10" (WU autounattend, also HKU\.DEFAULT and default user), `Keyboard Response\Flags`="2" (OD; WH rec "2"), `ToggleKeys\Flags`="34" (OD/WH rec). WH: `MouseKeys\Flags`="130", `HighContrast\Flags`="4194" (hotkey off). All REG_SZ. WH defaults (hotkeys on): Sticky 510, Filter 126, Toggle 62, MouseKeys 126, HighContrast 126. Note differing numbers: bit 0x4 (hotkey available) must be cleared.
- Also WH: `HKCU\Software\Microsoft\Narrator\NoRoam\WinEnterLaunchEnabled`=0; `Control Panel\Accessibility\Sound on Activation`=0, `Warning Sounds`=0 (DWORD).
- Conflict: look.accessibility-reset deletes and rewrites these keys (Flags=0); pick one.
- src detail: winutil-regtweaks.md, optimizerduck-revitool.md, winhance.md.

### look.accessibility-reset
- RV control-panel.yml (+DEFAULT): delete keys `HKCU\Control Panel\Accessibility\{AudioDescription,Blind Access,HighContrast,Keyboard Preference,Keyboard Response,MouseKeys,On,ShowSounds,SlateLaunch,SoundSentry,StickyKeys,TimeOut,ToggleKeys}`, then recreate each and set `Flags` = "0" (REG_SZ). Also delete `MouseKeys\MaximumSpeed` and `MouseKeys\TimeToMaximumSpeed` (listed twice in RV) and `reg add MouseKeys` key. WARNING: wipes accessibility configuration for the user and the default; also removes DynamicScrollbars if under same tree (it lives directly under Accessibility, not a subkey, so survives). Revert: no good default; recreate keys with Windows defaults (e.g. StickyKeys Flags 510).
- src detail: playbook.md (+ spot-check control-panel.yml).

### look.spotlight-lockscreen-off
- RV privacy/cdm.yml (+DEFAULT): `HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager` = 0: ContentDeliveryAllowed, SubscribedContentEnabled, `SubscribedContent-{310093,338389,314559,280815,314563,202914,338387,280810,280811,353698,338388}Enabled`, SoftLandingEnabled, SilentInstalledAppsEnabled, PreInstalledAppsEnabled, PreInstalledAppsEverEnabled, OemPreInstalledAppsEnabled, FeatureManagementEnabled, RemediationRequired, RotatingLockScreenEnabled, RotatingLockScreenOverlayEnabled, SystemPaneSuggestionsEnabled; delete keys `...\ContentDeliveryManager\Subscriptions` and `...\SuggestedApps`.
- RV cloud-content.yml: `HKLM\Software\Policies\Microsoft\Windows\CloudContent`: DisableSoftLanding=1, DisableTailoredExperiencesWithDiagnosticData=1, DisableCloudOptimizedContent=1; `HKCU\Software\Policies\Microsoft\Windows\CloudContent` (+DEFAULT): ConfigureWindowsSpotlight=2, IncludeEnterpriseSpotlight=0, DisableThirdPartySuggestions=1, DisableTailoredExperiencesWithDiagnosticData=1, DisableWindowsSpotlightFeatures=1, DisableWindowsSpotlightWindowsWelcomeExperience=1, DisableWindowsSpotlightOnActionCenter=1, DisableWindowsSpotlightOnSettings=1.
- WH fan-out uses the same ContentDeliveryManager values (plus Settings suggestions SubscribedContent-338393/353694/353696). This item is the lock-screen/Spotlight subset; the full CDM is also in Privacy (RV also in explorer\win-settings.yml). Dedupe when merging groups. Start side effect: start.hide-recommended-section also kills Spotlight.
- Gotcha (RV): setting DisableWindowsConsumerFeatures breaks Your Phone, so it is not set here.
- src detail: playbook.md, winhance.md (Privacy section lines), optimizerduck-revitool.md.

### look.lockscreen-disable
- `HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization\NoLockScreen` = 1 (DWORD). WH `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\DisableLockWorkstation` is a different tweak (blocks Win+L/lock), not used here.
- src detail: winutil-regtweaks.md, winhance.md.

### look.logon-blur-off
- `HKLM\SOFTWARE\Policies\Microsoft\Windows\System\DisableAcrylicBackgroundOnLogon` = 1 (DWORD).
- src detail: winutil-regtweaks.md.

### look.dynamic-lighting-off
- `HKCU\Software\Microsoft\Lighting\AmbientLightingEnabled` = 0; `HKCU\Software\Microsoft\Lighting\ControlledByForegroundApp` = 0 (DWORD; defaults 1).
- src detail: winhance.md.

---

## Context Menu

### ctx.legacy-menu
- Create key `HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32` with (Default) = "" (empty REG_SZ). RV +DEFAULT? (RV writes HKCU only per context-menu.yml; add to Default-user hive for new accounts). Restart explorer. Revert: delete the `{86ca1aa0-...}` key. This replaces "Show more options" with the full classic menu directly.
- src detail: playbook.md, winutil-regtweaks.md, optimizerduck-revitool.md, winhance.md.

### ctx.take-ownership
- RV (context-menu.yml, HKCR): `*\shell\runas` (MUIVerb "Take Ownership", HasLUAShield, NoWorkingDirectory, Position=middle) with `command` = `cmd.exe /c takeown /f "%1" && icacls "%1" /grant *S-1-3-4:F /c /l` (+ IsolatedCommand same); `Directory\shell\runas` with `takeown /f "%1" /r /d y && icacls "%1" /grant *S-1-3-4:F /t /c /l /q` and AppliesTo excluding C:\Users, C:\ProgramData, C:\Windows, System32, Program Files (x86); `dllfile\shell\runas` same as file; `exefile\shell\runas` restored to default `"%1" %*`. WH writes `HKCR\*\shell\TakeOwnership` (+ .reg import; content not inventoried) and notes Defender may need to be disabled for it.
- Revert: delete the runas/TakeOwnership keys (exefile runas back to default).
- src detail: playbook.md, winhance.md.

### ctx.multi-select-limit
- `HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\MultipleInvokePromptMinimum` = 100 (DWORD) (+DEFAULT); `HKCU\Software\Winaero.com\Winaero Tweaker\Changes\pageContextMenuSelectionLimit` = 1 (Winaero marker; optional).
- src detail: playbook.md.

### ctx.compress-to
- `HKCR\*\shell\CompressToFullMenu_ForOldContextMenu\ExplorerCommandHandler` (REG_SZ) = `{7AE6900F-6EB0-44A2-9CA1-DB2F7EF352AF}` (+ .reg import details not in inventory). Only visible in classic menu; build 26100+.
- src detail: winhance.md.

### ctx.open-terminal
- `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked\{9F156763-7844-4DC4-B2B1-901F640F5155}` (REG_SZ): delete to show "Open in Terminal"; value "" blocks it.
- src detail: winhance.md.

### ctx.toggle-extensions-entry
- `HKCR\AllFilesystemObjects\shell\Windows.ShowFileExtensions\ExplorerCommandHandler` (REG_SZ) = `{4ac6c205-2853-4bf5-b47c-919a42a48a16}` (+ .reg import; only in classic/"Show more options" menu).
- src detail: winhance.md.

### ctx.utility-entries
- HKCR\Directory\Background\shell entries: `SFC\MUIVerb`="SFC /SCANNOW" (+ command .reg); `RepairWindowsImage` (MUIVerb "Repair Windows Image", Icon `WmiPrvSE.exe`, HasLUAShield "", `command` = `PowerShell -ExecutionPolicy Bypass -windowstyle hidden -command "Start-Process cmd -ArgumentList '/s,/k, DISM /Online /Cleanup-Image /RestoreHealth' -Verb runAs"`); `CHKDSK\MUIVerb`="CHKDSK" (.reg import prompts for drive letter). Exact command lines for SFC/CHKDSK are in WH's .reg imports, not in inventory.
- src detail: winhance.md.

### ctx.ps1-edit-run
- `HKCR\SystemFileAssociations\.ps1\Shell\Edit-Run-with\MUIVerb` = "Edit or Run with" (cascading submenu: PowerShell, PowerShell 7, ISE, Notepad, +admin variants; WH .reg import, details not in inventory).
- src detail: winhance.md.

### ctx.open-with-store-lookup-off
- `HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer` and `HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer`: `NoInternetOpenWith` = 1 (DWORD) (+DEFAULT). Part of RV "restrict Internet communication" set (also NoPublishingWizard=1, NoWebServices=1, NoOnlinePrintsWizard=1 - owned by Privacy group).
- src detail: playbook.md.

### ctx.cast-to-device-remove
- NO inventory source. Standard method: `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked` value named `{7AD84985-87B4-4a16-BE58-8B72A5B390F7}` (REG_SZ, data ""). Requires Explorer restart. Verify GUID before use.
- src detail: none.

### ctx.share-remove
- NO inventory source. Standard method: `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked` value named `{e2bf9676-5f8f-435c-97eb-11607a5bedf7}` (ModernSharing, REG_SZ ""). Verify GUID before use.
- src detail: none.

### ctx.sendto-cleanup
- NO inventory source. Delete default shortcuts (Fax recipient, Mail recipient, Documents) from `%APPDATA%\Microsoft\Windows\SendTo` for each user and `C:\Users\Default\AppData\Roaming\Microsoft\Windows\SendTo` for new accounts. Some are hidden files.
- src detail: none.
