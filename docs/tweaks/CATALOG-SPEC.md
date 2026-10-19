# Catalog authoring spec

Turn ticked tweaks into `catalog/*.psd1` entries for the engine in `engine/`. Read these first:
- `engine/Actions/*.ps1` header comments = every action type and its fields (Registry, Service, Appx, Capability, Feature, ScheduledTask, File, Hosts, Env, Bcdedit, Exec, Script).
- `tests/fixtures/catalog/selftest.psd1` = a worked example of the file format.
- `engine/Catalog.ps1` (`Test-ActionDefinition`) = the validation rules.
- `engine/scripts/UpdatePause.ps1` = example of a `Script` action.

## File format
`catalog/<name>.psd1` is a PowerShell data file (NO scriptblocks, NO variables, NO expressions; only literals, `@()`, `@{}`, `$true/$false/$null`, single-quoted strings preferred):
```powershell
@{
    Tweaks = @(
        @{
            Id      = 'priv.telemetry-policy'        # exactly the id from TWEAKS.md
            Name    = 'Telemetry level 0 ...'        # from the TWEAKS.md line (shortened ok)
            Risk    = 'low'                           # low | med | high, from TWEAKS.md
            Phase   = 10                              # see below
            Source  = 'RV,RT,OD'                      # src tags from TWEAKS.md
            Note    = 'one short line (optional)'
            Reboot = $true                            # only if TWEAKS.md has the reboot marker
            RestartExplorer = $true                   # only for shell/Explorer visible changes
            Requires = @('tamper-off')                # optional: admin | tamper-off | no-pending-reboot
            Builds  = @{ Min = 26100 }                # optional, e.g. for 25H2-only (26200) items
            Actions = @( @{ Type = 'Registry'; ... }, ... )
        }
    )
}
```
Use single quotes; in a single-quoted string a literal `'` is written `''`. Registry paths use backslashes and a hive prefix: `HKLM\...`, `HKCU\...`, `HKU\.DEFAULT\...`, `HKCR\...`.

## Rules
1. Implement EXACTLY the mechanism in the matching `### <id>` section of `docs/tweaks/group<N>.mech.md` (and check `docs/inventory/*.md` if it is ambiguous). Do not invent extra changes. Do not add keys the mech file does not list.
2. **HKCU paths are written once.** The engine expands HKCU to every user profile plus the Default user template. Never write a separate `HKU\.DEFAULT` or `Default` copy for an HKCU tweak.
3. **Phase**: 10 registry/policy/env/hosts; 20 services, scheduled tasks, bcdedit, Exec; 30 Appx / Capability / Feature / File removals; 50 final shell items that need Explorer restart.
4. **TI**: set `TI = $true` on a Registry action when the mech/select line says TrustedInstaller (🔒) or the key is known to be TI-protected (Defender keys, Windows Runtime ActivatableClassId, some service keys). Service actions fall back to TI automatically.
5. Idempotent: every action must be checkable. Prefer Registry/Service/ScheduledTask/Appx/Feature/Capability/Hosts/Env/Bcdedit. Use `Exec` only if nothing else fits: `Test` must evaluate to `$true` when ALREADY applied, `Apply` does the change, `Revert` undoes it. Code is a single-quoted string; keep it short and PS 5.1 compatible (no `?:`, `??`, `&&`).
6. For multi-step/complex logic (>~6 lines) write `engine/scripts/<Prefix>-<Name>.ps1` returning `@{ Test={...}; Apply={...}; Undo={...} }` (see `UpdatePause.ps1`; scriptblocks must define their own constants; they can call engine functions: `Resolve-RegPath`, `Read-RegTarget`, `Write-Log`, `Invoke-AsTrustedInstaller`, `Get-UserTargets`). `Test` returns `$true/$false` or `@{Status='Applied|Pending|NotApplicable'; Detail=''; Prior=...}`.
7. Windows-version or hardware caveats: use `Builds = @{ Min = N }`; items for hardware that may not exist (Intel/AMD/NVIDIA) must be N/A-safe (e.g. `RequireKey = $true` on Registry actions that only apply if the parent key exists).
8. Appx removal: one Appx action per package Name from the mech file (wildcards ok). Do NOT add deprovision logic inside Appx actions (separate registry tweak handles it).
9. Conflicts: if the mech says two alternatives, implement the one that matches the ticked id only.
10. If the mechanism cannot be implemented safely (opaque CAB, unknown values), do NOT guess: omit the tweak and list it with the reason in your report.

## Verify before reporting (all unelevated, read-only)
```
powershell -NoProfile -ExecutionPolicy Bypass -File debloat.ps1 validate
powershell -NoProfile -ExecutionPolicy Bypass -File debloat.ps1 plan -Only '<your ids comma separated or prefix.*>' -Detail
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Invoke-Tests.ps1
```
`validate` must report no catalog errors for your files. `plan` must run without exceptions: statuses Pending/Applied/NotApplicable/Unknown are fine (Unknown = needs admin; mention which ids). NEVER run `apply`, `revert` or `schedule`, and never write to the registry/services yourself. Only create/edit the files you are assigned (catalog/<your files>.psd1 and engine/scripts/<yourprefix>-*.ps1). This PC already has ReviOS applied, so many items will show Applied: that is expected.
