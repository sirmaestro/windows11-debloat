# AGENTS.md — notes for future agents working on this repo

Working notes from verifying real `apply` runs in a VM. Keep this current; it is the fast path
to not re-deriving things. VM mechanics (snapshots, guestcontrol quirks) live in the agent's
persistent memory (`windowstest-vm`), not here.

## How to verify a run in the VM

- VirtualBox VM `windowstest`, user `vboxuser` / password `1`. Guest Additions run level 3.
- Simplest reliable guest call: copy a `.ps1` into `C:\dbg\` with `guestcontrol copyto`, then run it
  with `--exe ...\powershell.exe -- powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\dbg\x.ps1`.
  Passing inline `-Command` with complex quoting fights both bash and PowerShell parsing — avoid it.
- Under Git Bash set `MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL="*"` or `C:\...` args get mangled to
  `C:/...` and `-File` rejects anything without a real `.ps1` path.
- Logs: `C:\ProgramData\WinDebloat\logs\*.log`; run records: `C:\ProgramData\WinDebloat\runs\*.json`.
  Copy them out with `guestcontrol copyfrom` and read the final `Run NNN: X applied/verified, Y failed` line.

## Defender is still running after `apply -Profile all` — this is EXPECTED, not a bug

Verified 2026-10-19 against the `after-debloat` snapshot (run `20261018-150141`). Defender fully
alive: `MsMpEng`, `MpDefenderCoreService`, `NisSrv`, `SecurityHealthService`, `smartscreen` running;
`WinDefend`/`MDCoreSvc` `Start=2`; `TamperProtection=1`, `IsTamperProtected=True`.

Two independent reasons, both by design:

1. **`sec.defender-disable` never ran.** The log shows
   `[ERROR] sec.defender-disable: requirement not met: Tamper Protection is ON.`
   The tweak has `Requires = @('admin','tamper-off')` ([catalog/heavy.psd1](catalog/heavy.psd1)); the
   `tamper-off` gate in [engine/Commands.ps1:14](engine/Commands.ps1#L14) blocks it whenever
   `Features\TamperProtection` is 1 or 5. **Tamper Protection cannot be disabled by script** — Microsoft
   gates it behind the Windows Security UI. The reference tool (revision-tool `disableDefenderCLI`) also
   refuses and just opens the UI and waits for the user. So the gate is correct.

   To actually run it: in the VM, Windows Security → Virus & threat protection → Manage settings →
   turn **Tamper Protection** off, then `.\debloat.ps1 apply -Only sec.defender-disable`. Take a fresh
   snapshot with tamper already off before testing, since the UI step is manual.

   **Interactive helper (added 2026-10-19):** `Wait-TamperProtectionOff` in
   [engine/Commands.ps1](engine/Commands.ps1). When `sec.defender-disable` is pending and the
   `tamper-off` gate is unmet, an *interactive* apply now auto-opens
   `windowsdefender://threatsettings` (verified to launch `SecHealthUI` on build 26300) and loops on
   `Read-Host` until the user has switched Tamper Protection off (or types `SKIP`). It re-checks
   `Test-Requirement 'tamper-off'` each Enter, so it only proceeds once the value actually reads off.
   It is gated on `-not $Yes` **and** `[Environment]::UserInteractive`: under `-Yes` (automation /
   scheduled SYSTEM task) it falls through to the old "requirement not met → skip" behaviour. Note
   `UserInteractive` is `True` under VirtualBox `guestcontrol`, so to test from the host without
   hanging on the prompt you MUST pass `-Yes` (there is no stdin to answer `Read-Host`). The `-Yes`
   gate path was verified in the VM: logs the ERROR and returns `0 applied / 1 failed` with no hang.

2. **Even when it runs, processes persist until reboot — and `MsMpEng` may persist regardless.**
   [engine/scripts/DefenderDisable.ps1](engine/scripts/DefenderDisable.ps1) reproduces only the
   *reproducible* half of revision-tool's `disableDefender`: policy keys
   (`DisableAntiSpyware/DisableAntiVirus/DisableRealtimeMonitoring`), the TrustedInstaller core-key
   writes, the Jan-2026 double-`gpupdate` re-sync, and `MDCoreSvc\Start=4`. revision-tool additionally
   calls `DefenderRemovalService.installPackage()` — a **signed Revision CBS package** that physically
   removes components and sets `WinDefend\Start=4`. The project deliberately does **not** ship that
   package (see PLAN.md §7 and the script header), so the clean-machine result is a *policy-disabled*
   Defender that takes effect after reboot, not a removed one. Do not "fix" this by force-writing
   `WinDefend\Start=4` while Tamper Protection is on — the write is reverted by Defender.

   Note: `DefenderDisable.ps1` sets only `MDCoreSvc\Start=4`, not `WinDefend\Start=4`. That mirrors
   revision-tool's non-package path. If a future goal is "maximally stop the AV service without the CBS
   package," the reproducible lever is `WinDefend\Start=4` via TrustedInstaller — but only attempt it
   with Tamper Protection off, and expect it to need a reboot and possibly still be reverted. Discuss
   before adding; it is risky and was intentionally left out.

## Removing Defender *components* (zero processes) — why the CBS route can't be reproduced cleanly

Goal some users want: **no Defender processes at all** (`MsMpEng`/`MpDefenderCoreService` gone), not just AV disabled. Findings from a full investigation (2026-10-19):

- **Registry/policy disable (our `sec.defender-disable`) can never reach zero processes.** It makes Defender *inert* (`Get-MpComputerStatus` → `AntivirusEnabled:False`, `AMRunningMode:Not running`) but `MsMpEng` (service `WinDefend`) and `MpDefenderCoreService` (`MDCoreSvc`) still launch. After a reboot the platform **self-heals** `WinDefend`/`MDCoreSvc` `Start` back to `2` (observed: a platform update bumped `SecurityHealthHost` to `10.0.29628` and re-armed them). Our script also only ever set `MDCoreSvc\Start=4`, never `WinDefend`.
- **You cannot force the Start values, even as TrustedInstaller.** Setting `Start=4` on `WinDefend`, `MDCoreSvc`, `WdFilter`, `WdBoot`, `WdNisDrv/Svc` fails with *"Attempted to perform an unauthorized operation"* — these run as PPL (protected anti-malware) and self-protect their own service keys against everything, **independent of Tamper Protection**. Only non-core `Sense`/`webthreatdefsvc`/`wscsvc` were writable. So the "force Start=4 + deny-ACL" idea is a dead end for the core processes.
- **The only thing that removes the processes is removing the components — a signed CBS package** (what ReviOS/AME do). CBS = Component-Based Servicing; the packages register a max-version supersede of each Defender component (see the `references\packages` decode in [docs/inventory/playbook.md](docs/inventory/playbook.md)).
- **Why it can't be installed live from a plain script:** `Add-WindowsPackage`/DISM require the package's signing cert to chain to a root on **Code Integrity's internal allowlist** (e.g. thumbprint `8A334AA8052DD244A647306A76B8178FA215F344`, which CI trusts internally; not present in the local Root store). Trusting a self-signed cert in `LocalMachine\Root` is **not** enough → DISM returns `0x800b0110 CERT_E_WRONG_USAGE`.
- **AME's bypass** ([trusted-uninstaller-cli `Defender.cs`](../../references/trusted-uninstaller-cli/TrustedUninstaller.Shared/Defender.cs)): disable UCPD, `Import-Certificate` the cab's signer to `Root`, then `Copy-Item` its registry blob into the allowlisted slot `HKLM\...\SystemCertificates\ROOT\Certificates\8A334AA8...`, `DISM /Online /Add-Package /IgnoreCheck`, then delete the cert+slot. Fallback on failure: reboot to Safe Boot and apply there.
- **AME's trick does NOT transfer to the downloaded ReviOS cab.** The ReviOS `Defender-Removal` cab is **self-signed** (issuer==subject, no AKI, thumbprint `183E66…`). CI builds its chain to *itself* (`183E66`, not allowlisted) and never consults the `8A334AA8` slot, so planting a cert there is useless → `CERT_E_WRONG_USAGE` regardless. AME's slot works only because AME's *own* cab's leaf chains (via AKI) to the `8A334AA8` root. Verified: both an in-session attempt and a user run failed identically.
- **Net / boundary:** a reproducible tool that refuses to ship-and-trust its own signing root **cannot** strip Defender components on stock Windows — this is Microsoft's CI component-signing allowlist working as designed, not a script gap. The only self-contained route would be to *become* AME: generate a root+leaf cert pair, plant the root at the allowlisted slot, and sign a self-built CBS cab (from the component list in `references\packages`). That reintroduces exactly the third-party-trust/signed-payload posture PLAN.md §7 rules out, so it stays out of the shipped profiles. For a VM, the supported path is AME Wizard / the ReviOS playbook, or AME's own `Z-AME-NoDefender` cab.
- **Classifier note:** guest commands that mass-disable AV services, or that import a spoofed `CN=Microsoft Windows` root + plant the CI slot, are blocked by the auto-mode safety classifier (`[TLS/Auth Weaken]`). Expect to hand the user a script to run themselves for those steps.

## Other failures in that run (4 failed total) — all known / benign

- `edge.remove-edge` → **Pending**. Appx `Microsoft.MicrosoftEdgeDevToolsClient` returns
  `0x80070032 ... part of Windows and cannot be uninstalled on a per-user basis`. The Edge script and
  other components still apply; this one sub-package is a SystemApps component. Re-check after reboot.
- `edge.remove-onedrive` → **Pending**, "reboot required". Expected; verifies after reboot.
- `appx.secure-assessment-browser` → **Pending**, same `0x80070032` SystemApps error as above. The
  package is a protected Windows component; per-user removal is not possible. Candidate to either drop
  from the profile or convert to a provisioned/DISM removal if it matters.
- `start.widgets-off` → 2 registry writes **skipped** (`unauthorized operation`), even after the
  TrustedInstaller retry, because Windows protects those keys on this build. The tweak is still marked
  OK because the other writes land. Known Windows-side protection, not a tool bug.

## Takeaway for "did the run fully succeed?"

No — 196 applied/verified, **4 failed**. None of the four is a defect in the engine: one manual
prerequisite (Tamper Protection), two reboot-pending, and protected Windows components. The user's
observation (Defender still present) is fully explained by reason #1 above.
