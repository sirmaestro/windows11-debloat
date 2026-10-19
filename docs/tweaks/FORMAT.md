# Pick-list format (shared spec for docs/tweaks/*.select.md and *.mech.md)

## select file: one line per selectable tweak, grouped under `## <Category>` headings

`- [ ] **<id>** — <name>: <what it does, <=18 words> · risk: low|med|high · src: RV,RT,WU,WH,OD,RS · rec: ✅|➕|⚠️|⛔ · <markers> · <note, optional, <=20 words>`

- id = `<prefix>.<kebab-name>`; prefixes: priv, sec, upd, net, misc, appx, feat, ai, edge, svc, task, perf, game, pwr, shell, start, look, ctx
- src tags: RV = ReviOS playbook, RT = revision-tool, WU = winutil, WH = Winhance, OD = optimizerDuck, RS = Registry-Tweaks-Scripts. List every source that offers the same tweak (merge duplicates!).
- rec: ✅ recommended (low risk and widely agreed, or ReviOS applies it always) · ➕ optional/situational/preference · ⚠️ risky - only if you know why · ⛔ not recommended (ReviOS reverted it because it broke something, Windows-10-only, dead code, redundant with another item, or conflicts)
- markers (only when true): 👤 per-user (HKCU; needs default-user mirroring) · 🔒 needs TrustedInstaller · 🔁 Windows Update tends to revert/reinstall it (drift) · ♻ reboot needed
- The checkbox must be `[ ]` EXCEPT for these items the user explicitly chose, which are `[x]`: disable hibernate+fast startup; remove Edge; remove OneDrive; remove Teams; remove Copilot+Recall (AI); remove Photos; remove Dev Home; remove Your Phone / Cross Device; dark mode; disable transparency effects; legacy (Win10) context menu; remove pinned Start items; disable Defender. NOT chosen (keep `[ ]`): Xbox apps removal, Revision wallpaper, automatic maintenance off, browser install.
- If two items conflict or one supersedes another, say so in the note (e.g. "conflicts with perf.x").
- Exclude: Windows-10-only items, ISO/WIM/OOBE-install-time-only items, ReviOS branding, installing software/browsers, tweaks that only exist to undo other tweaks. Winhance has many per-setting toggles: collapse closely related toggles into one item with the settings listed in the mech file; keep separate lines only where a user would plausibly want to choose independently. Aim for roughly 60-150 lines per group. For Appx removal: one line per app/package family (user picks apps).
- Gotchas the ReviOS playbook learned (breaks X) MUST be preserved in the note or rec of the affected item.

## mech file: one `### <id>` section per select line (same ids)

For each: exact mechanism (full registry paths\values=data+type, service=start type, appx package names, task paths, commands), differences between sources (e.g. ReviOS sets X, Winhance sets X and Y), build/version notes (24H2/25H2), revert hint (default value or 'delete'), and a `src detail:` line naming the inventory file(s) used. Keep it implementable: someone must be able to write the catalog entry from it without re-reading the inventories.
