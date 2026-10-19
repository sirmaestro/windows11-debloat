## Explorer & Shell

- [ ] **shell.show-file-extensions** — Show file extensions: show .ext on all files (HideFileExt=0) · risk: low · src: RV,WU,OD,WH · rec: ✅ · 👤 · ReviOS lists it under Security
- [ ] **shell.show-hidden-files** — Show hidden files, folders and drives (Hidden=1) · risk: low · src: WU,OD,WH · rec: ➕ · 👤
- [ ] **shell.show-protected-os-files** — Show protected operating-system files (ShowSuperHidden=1) · risk: med · src: WH · rec: ⚠️ · 👤 · Easy to delete system files by accident
- [ ] **shell.show-lnk-extension** — Show .lnk extension on shortcuts when extensions are on · risk: low · src: WH · rec: ➕ · 🔒 · HKCR key; spots disguised shortcuts; some Start entries then show ".lnk"
- [ ] **shell.launch-to-this-pc** — Open File Explorer to This PC instead of Home (LaunchTo=1) · risk: low · src: RV,WU,OD,WH · rec: ✅ · 👤
- [ ] **shell.hide-home-gallery** — Remove Home and Gallery nodes from the Explorer navigation pane · risk: low · src: WU,OD,WH · rec: ➕ · 👤 · WH also sets HKLM NonEnum/HiddenByDefault
- [ ] **shell.hide-network-navpane** — Hide Network node in Explorer navigation pane · risk: low · src: — · rec: ➕ · 🔒 · No inventory source; mechanism unverified, see mech file
- [ ] **shell.recent-files-off** — Stop Quick Access recent files, recommendations and Office.com cloud files · risk: low · src: WH · rec: ➕ · 👤 · Different from Start-menu recent lists
- [ ] **shell.frequent-folders-off** — Stop Quick Access frequent folders (ShowFrequent=0) · risk: low · src: WH · rec: ➕ · 👤
- [ ] **shell.navpane-options** — Nav-pane tweaks: expand to current folder, show all folders, Libraries, cloud status, user folders · risk: low · src: WH · rec: ➕ · 👤🔒 · Mixed HKCU and HKLM keys
- [ ] **shell.this-pc-folders-hide** — Hide Desktop/Documents/Downloads/Music/Pictures/Videos folders under This PC · risk: low · src: WH · rec: ➕ · 🔒 · HKLM MyComputer NameSpace HiddenByDefault
- [ ] **shell.compact-view** — Compact Explorer view: decrease spacing between items (UseCompactMode=1) · risk: low · src: OD,WH · rec: ➕ · 👤
- [ ] **shell.item-checkboxes** — Checkboxes to select items in Explorer (AutoCheckSelect=1) · risk: low · src: OD,WH · rec: ➕ · 👤
- [ ] **shell.full-path-title** — Show full folder path in Explorer title bar (FullPath=1) · risk: low · src: RV,WH · rec: ✅ · 👤
- [ ] **shell.sync-provider-notifications-off** — Turn off OneDrive/sync-provider ads and banners in Explorer · risk: low · src: RV,OD,WH · rec: ✅ · 👤 · Complements removing OneDrive
- [ ] **shell.info-tips-off** — Disable pop-up descriptions for folder and desktop items (ShowInfoTip=0) · risk: low · src: RV,WH · rec: ✅ · 👤 · WH exposes it only as a toggle, ReviOS forces off
- [ ] **shell.shortcut-suffix-off** — Remove " - Shortcut" suffix from newly created shortcuts · risk: low · src: RV,WH · rec: ✅ · 👤
- [ ] **shell.shortcut-arrow-remove** — Remove arrow overlay from shortcut icons via blank .ico · risk: low · src: OD,WH · rec: ➕ · 🔒 · Needs a blank.ico shipped; HKLM
- [ ] **shell.desktop-icons** — Show This PC / Recycle Bin / User Files / Network / Control Panel on desktop; or hide all icons · risk: low · src: OD,WH · rec: ➕ · 👤
- [ ] **shell.hide-spotlight-desktop-icon** — Hide "Learn about this picture" Spotlight desktop icon (24H2) · risk: low · src: RV · rec: ✅ · 🔒 · Value is HKLM; also see look.spotlight-lockscreen-off
- [ ] **shell.explorer-window-behavior** — Separate process per window, restore windows at logon, folder-open and click behaviour · risk: low · src: WH · rec: ➕ · 👤
- [ ] **shell.view-misc** — Misc view options: status bar, drive letters first, empty drives, folder tips, type-ahead, merge conflicts · risk: low · src: WH · rec: ➕ · 👤 · Individual values listed in mech
- [ ] **shell.thumbnails-icons-only** — Always show icons, never thumbnails (IconsOnly=1) · risk: low · src: WH · rec: ➕ · 👤 · Also in WH Performance as opposite toggle; picks conflict with look.visual-effects
- [ ] **shell.icon-thumbnail-cache** — Larger icon cache (MaxCachedIcons) and keep thumbnail cache through disk cleanup · risk: low · src: WH · rec: ➕ · 🔒 · HKLM
- [ ] **shell.photo-viewer-restore** — Restore classic Photo Viewer and map image extensions to it · risk: low · src: RV,WH · rec: ➕ · 🔒 · Tie to appx Photos removal; ReviOS applies only when Photos removed
- [ ] **shell.legacy-notepad** — Use legacy Notepad as handler: NoOpenWith removal and disable Store Notepad redirect · risk: low · src: WH · rec: ➕ · 🔒 · Needs Notepad (Legacy) capability installed
- [ ] **shell.tablet-mode-desktop** — Always use desktop mode, never tablet mode prompts (SignInMode, TabletMode) · risk: low · src: RV · rec: ➕ · 👤 · Irrelevant on non-convertible PCs
- [ ] **shell.scrollbars-always-visible** — Disable auto-hiding (dynamic) scrollbars · risk: low · src: WU · rec: ➕ · 👤
- [ ] **shell.window-snap-settings** — Window snapping, Aero Shake off, Snap Assist flyout off · risk: low · src: WU,OD · rec: ➕ · 👤
- [ ] **shell.numlock-on** — Num Lock on at logon and boot (InitialKeyboardIndicators=2) · risk: low · src: WU,OD · rec: ➕ · 👤 · Write to HKU\.DEFAULT too so it applies at logon screen
- [ ] **shell.capslock-disable** — Disable Caps Lock key via Scancode Map · risk: low · src: OD · rec: ➕ · 🔒 ♻ · Revitool CLI feature; HKLM binary
- [ ] **shell.clipboard-history** — Enable clipboard history (Win+V) · risk: low · src: OD · rec: ➕ · 👤 · Privacy trade-off: history stays local
- [ ] **shell.settings-home-hide** — Hide Settings app Home page (SettingsPageVisibility=hide:home) · risk: low · src: WU · rec: ➕ · 👤 · Will conflict with any other SettingsPageVisibility write; merge lists
- [ ] **shell.toast-notifications-off** — Turn off toast notifications and Notification Center (minimal or full mode) · risk: med · src: WU,OD,WH · rec: ⚠️ · 👤 · Kills Calendar flyout; "full" also disables Wpn* services
- [ ] **shell.edge-swipe-off** — Disable touchscreen edge swipe (AllowEdgeSwipe=0) · risk: low · src: OD · rec: ➕ · 🔒 · HKLM policy; touch devices only
- [ ] **shell.verbose-logon** — Show verbose status messages at logon/logoff (VerboseStatus=1) · risk: low · src: WU,OD · rec: ➕ · 🔒
- [ ] **shell.detailed-bsod** — Show detailed BSOD parameters, disable sad emoticon · risk: low · src: WU · rec: ➕ · 🔒
- [ ] **shell.time-utc** — Hardware clock is UTC (RealTimeIsUniversal=1) · risk: med · src: WU · rec: ⚠️ · 🔒 · Only for Windows+Linux dual boot
- [ ] **shell.long-paths** — Enable Win32 long paths (LongPathsEnabled=1) · risk: low · src: WH · rec: ➕ · 🔒 · May also appear under Performance/Misc; dedupe on merge
- [ ] **shell.default-printer-management-off** — Stop Windows auto-switching default printer (LegacyDefaultPrinterMode=1) · risk: low · src: WH · rec: ➕ · 👤
- [ ] **shell.cross-device-resume-block** — Block Cross Device Resume host and policy · risk: low · src: RV · rec: ➕ · 🔒 · Tied to Your Phone removal; likely also listed in the Appx/Features group

## Start Menu & Taskbar

- [x] **start.remove-pinned-items** — Replace default Start pins with Store, Settings, Notepad, Paint, Explorer, Calculator; purge caches · risk: med · src: RV,WU,WH · rec: ✅ · 🔒 · ConfigureStartPins on Pro 24H2 unverified; WU Start layout fails on 25H2+; WH needs HKLM GPO key too
- [ ] **start.default-user-layout** — Seed Start/taskbar layout for new accounts via Default profile · risk: med · src: RV,WU,WH · rec: ➕ · 👤🔒 · HKU\.DEFAULT is not the new-user template; load Default NTUSER.DAT instead
- [ ] **start.pinned-folders-hidden** — Hide Documents/Downloads/Music/etc. folder shortcuts next to Start power button · risk: low · src: RV · rec: ✅ · 🔒 · Settings stays shown
- [ ] **start.recommendations-account-notifs-off** — Turn off Start Iris recommendations and account notifications · risk: low · src: RV,WH · rec: ✅ · 👤
- [ ] **start.hide-recommended-section** — Hide Start Recommended section (HideRecommendedSection plus IsEducationEnvironment) · risk: med · src: WU,OD,WH · rec: ➕ · 🔒 · Side effect: Spotlight lock screen stops; IsEducationEnvironment hack alters SKU behaviour
- [ ] **start.layout-lists-prefs** — Start layout (more pins), All-apps view, recent/most-used app lists, recent files · risk: low · src: WH · rec: ➕ · 👤 · All-apps view needs build 26100.7171
- [ ] **start.taskbar-search-mode** — Taskbar search box: hidden / icon only / icon+label / box · risk: low · src: RV,WU,OD,WH · rec: ✅ · 👤 · ReviOS = icon only (1); WU/WH = hidden (0)
- [ ] **start.web-search-off** — Disable Bing/web results in Start search (BingSearchEnabled=0, DisableSearchBoxSuggestions=1) · risk: low · src: RV,OD,WH · rec: ✅ · 👤 · BingSearchEnabled also needed on 25H2+
- [ ] **start.cortana-cloud-search-off** — Windows Search policy: cloud search, Cortana, web search, location off · risk: low · src: RV · rec: ✅ · 🔒 · ReviOS sets AllowCortana=1 (sic) despite comment
- [ ] **start.search-store-results-off** — Block Store results in Search (WinStore.Tasks.WindowsSearchTask) · risk: low · src: RV · rec: ➕ · 🔒 · 25H2 only
- [ ] **start.searchhost-webview2-block** — FeatureManagement overrides stop SearchHost spawning WebView2 · risk: med · src: RV · rec: ⚠️ · 🔒🔁 · Undocumented feature IDs
- [ ] **start.task-view-off** — Hide Task View button (ShowTaskViewButton=0) · risk: low · src: RV,WU,OD,WH · rec: ✅ · 👤
- [ ] **start.widgets-off** — Disable Widgets and News/Interests: policies, TaskbarDa=0 · risk: low · src: RV,WU,OD,WH · rec: ✅ · 👤🔒 · AllowNewsAndInterests=0 stops WebExperience reinstall; appx removal handled in Appx group
- [ ] **start.chat-meetnow-off** — Hide taskbar Chat (Teams), Meet Now and People bar · risk: low · src: RV,WU,OD · rec: ✅ · 👤🔒 · Meet Now/People are mostly Win10 leftovers
- [ ] **start.taskbar-alignment-left** — Align taskbar icons left (TaskbarAl=0) · risk: low · src: WU,OD,WH · rec: ➕ · 👤
- [ ] **start.end-task** — Add "End task" to taskbar right-click menu · risk: low · src: RV,WU,OD,WH · rec: ✅ · 👤
- [ ] **start.notification-area-cleanup** — Stop notification-area auto-cleanup and balloon feature ads (NoAutoTrayNotify, NoBalloonFeatureAdvertisements) · risk: low · src: RV · rec: ✅ · 👤 · Policy keys under HKCU
- [ ] **start.tray-icons-show-all** — Show all system tray icons instead of overflow · risk: low · src: WH · rec: ➕ · 👤 · Sets SystemTrayChevronVisibility and per-icon IsPromoted
- [ ] **start.tray-clock-battery** — Seconds in clock, battery percentage in tray · risk: low · src: WU,OD · rec: ➕ · 👤
- [ ] **start.taskbar-behavior** — Button grouping, auto-hide and delay, badges, flashing, multi-monitor, show-desktop corner, icon size · risk: low · src: OD,WH · rec: ➕ · 👤 · Individual values in mech
- [ ] **start.clean-taskbar-pins** — Remove all taskbar pins (Taskband Favorites) · risk: low · src: WU,WH · rec: ➕ · 👤 · Per existing user; for new users use start.default-user-layout
- [ ] **start.old-start-layout** — Revert to previous Start layout via FeatureManagement override · risk: med · src: WU · rec: ⛔ · 🔒 · winutil states it does not work on 25H2+

## Appearance

- [x] **look.dark-mode** — Dark mode for system and apps (AppsUseLightTheme=0, SystemUsesLightTheme=0) · risk: low · src: RV,WU,OD,WH · rec: ✅ · 👤 · ReviOS also applies dark.theme via Set-Theme.ps1
- [x] **look.transparency-off** — Disable transparency effects (EnableTransparency=0) · risk: low · src: RV,WU,OD,WH · rec: ✅ · 👤 · ReviOS bundles MinAnimate=0 here; kept in look.animations-off
- [ ] **look.wallpaper-revision** — Revision wallpapers and lock screen via WALLPAPER.ps1 · risk: low · src: RV · rec: ➕ · 👤🔒 · Needs bundled image assets (branding); user did not choose
- [ ] **look.accent-palette** — Custom accent colour palette and accent colour #0078D4 · risk: low · src: RV,WU · rec: ➕ · 🔒 · RV writes HKLM palette values; WU writes per-user accent keys
- [ ] **look.animations-off** — Minimize/taskbar animations off, VisualFXSetting=3 · risk: low · src: RV,WU,OD · rec: ➕ · 👤 · RV taskbar-animations branch is effectively "delete value"; verify
- [ ] **look.visual-effects** — Disable list shadow, translucent selection, window/pointer shadows, Aero Peek, drag full window · risk: low · src: WU,OD,WH · rec: ➕ · 👤 · Conflicts with nothing but changes UserPreferencesMask binary; collapse many WH toggles
- [ ] **look.jpeg-quality-100** — Wallpaper JPEG import quality 100 (no compression) · risk: low · src: RV,WH · rec: ✅ · 👤
- [ ] **look.beeps-off** — Turn off system beeps (Sound\Beep=no) · risk: low · src: RV · rec: ✅ · 👤 · Do not disable the Beep service; ReviOS reverted that to Automatic
- [ ] **look.startup-sound-off** — Disable startup sound and first-logon animation · risk: low · src: RV,WH · rec: ✅ · 🔒 · Also listed under Power; dedupe on merge
- [ ] **look.audio-ducking-off** — Communications ducking = Do nothing (UserDuckingPreference=3) · risk: low · src: RV,WH · rec: ➕ · 👤
- [ ] **look.menu-responsiveness** — MenuShowDelay=0, ActiveWndTrkTimeout=10, Explorer startup delay 0 · risk: low · src: RV,WU,OD,WH · rec: ✅ · 👤 · Do not lower MouseHoverTime below 400; ReviOS reverted (overlapping tooltips)
- [ ] **look.mouse-accel-off** — Disable Enhance Pointer Precision (MouseSpeed/Threshold1/2 = 0) · risk: low · src: RV,WU,OD,WH · rec: ✅ · 👤 · Also in Gaming group; dedupe on merge
- [ ] **look.keyboard-repeat-max** — Fastest keyboard repeat: KeyboardDelay=0, KeyboardSpeed=31 · risk: low · src: WU,OD · rec: ➕ · 👤
- [ ] **look.cursor-shadow-off** — Disable shadow under mouse pointer (UserPreferencesMask bit) · risk: low · src: WH · rec: ➕ · 👤 · Shares UserPreferencesMask with look.visual-effects; write once
- [ ] **look.sticky-keys-prompts-off** — Disable Sticky/Filter/Toggle Keys shortcut popups · risk: low · src: WU,OD,WH · rec: ✅ · 👤 · ReviOS achieves it via look.accessibility-reset
- [ ] **look.accessibility-reset** — Wipe Control Panel\Accessibility subkeys and set all Flags=0 (ReviOS) · risk: med · src: RV · rec: ⚠️ · 👤 · Breaks accessibility hotkeys, high contrast, MouseKeys; not safe for users who need them
- [ ] **look.spotlight-lockscreen-off** — Disable Spotlight, lock-screen tips/fun facts, third-party suggestions · risk: low · src: RV,WH · rec: ✅ · 👤🔒 · Overlaps Privacy ContentDeliveryManager item
- [ ] **look.lockscreen-disable** — Skip the lock screen entirely (NoLockScreen=1) · risk: low · src: WU · rec: ➕ · 🔒 · WH DisableLockWorkstation is different (blocks Win+L)
- [ ] **look.logon-blur-off** — Remove acrylic blur on logon screen · risk: low · src: WU · rec: ➕ · 🔒
- [ ] **look.dynamic-lighting-off** — Disable Dynamic Lighting ambient RGB control · risk: low · src: WH · rec: ➕ · 👤 · Only on devices with RGB peripherals

## Context Menu

- [x] **ctx.legacy-menu** — Classic Win10 right-click menu; removes "Show more options" step · risk: low · src: RV,WU,OD,WH · rec: ✅ · 👤 · Needs Explorer restart; default-user mirror for new accounts
- [ ] **ctx.take-ownership** — Add "Take Ownership" for files, folders, DLLs · risk: med · src: RV,WH · rec: ⚠️ · 🔒 · Easy to damage ACLs; ReviOS excludes C:\Users, Windows, Program Files(x86)
- [ ] **ctx.multi-select-limit** — Raise multi-select verb prompt threshold to 100 items · risk: low · src: RV · rec: ➕ · 👤
- [ ] **ctx.compress-to** — Add "Compress to" to classic menu (ZIP, 7z, TAR) · risk: low · src: WH · rec: ➕ · 🔒 · Needs 26100+
- [ ] **ctx.open-terminal** — Show "Open in Terminal" on folders and background · risk: low · src: WH · rec: ➕ · 🔒 · Removes Shell Extensions\Blocked entry
- [ ] **ctx.toggle-extensions-entry** — Add Show/Hide extensions item to context menu · risk: low · src: WH · rec: ➕ · 🔒 · Redundant with shell.show-file-extensions
- [ ] **ctx.utility-entries** — Add SFC /SCANNOW, DISM RestoreHealth, CHKDSK to desktop background menu · risk: low · src: WH · rec: ➕ · 🔒
- [ ] **ctx.ps1-edit-run** — Cascading Edit/Run-with menu for .ps1 files · risk: low · src: WH · rec: ➕ · 🔒
- [ ] **ctx.open-with-store-lookup-off** — Remove "Look for an app in the Store" in Open with (NoInternetOpenWith=1) · risk: low · src: RV · rec: ✅ · 👤🔒 · ReviOS sets HKCU and HKLM
- [ ] **ctx.cast-to-device-remove** — Remove "Cast to Device" entry via Shell Extensions Blocked · risk: low · src: — · rec: ➕ · 🔒 · No inventory source; general knowledge, verify GUID
- [ ] **ctx.share-remove** — Remove "Share" entry (ModernSharing) from context menu · risk: low · src: — · rec: ➕ · 🔒 · No inventory source; general knowledge, verify GUID
- [ ] **ctx.sendto-cleanup** — Remove default Send-to entries (Fax, Mail, Documents) · risk: low · src: — · rec: ➕ · 👤 · No inventory source; delete shortcuts in per-user SendTo folder
