# Plater (Temucraft)

Plater Nameplates for the World of Warcraft 3.3.5a client, made for the Temucraft server.

This is a fork of [Plater Nameplates](https://github.com/Tercioo/Plater-Nameplates) by Terciob and the Plater team,
release **Plater-v536.1** (commit `c7eefe8`, 10 October 2022). That is the last release before the Dragonflight
(10.0) code, built for Shadowlands 9.2.7 and Wrath Classic 3.4.0. Its Wrath Classic code paths are the closest
to 3.3.5. All credit for Plater, the Details! Framework and the bundled libraries goes to their authors; their
licence notes are kept in their folders (the fonts have the SIL Open Font License in `Plater/fonts`). The
upstream readme is in `Plater/README.md`.

The addon is in the `Plater` folder (the folder name keeps the saved variables `PlaterDB` working).
It needs **!TemucraftCompat**, which gives the 3.3.5 client the newer functions Plater uses: nameplate unit
tokens (`nameplate1`...), `C_NamePlate`, the `NAME_PLATE_*` events, pools, `C_UnitAuras`, the combat log in the
newer layout, power events, templates and widget methods.

## What changed for 3.3.5

The first commit is the upstream release as downloaded. The changes in the Lua files have a `Temucraft:` comment
next to them, except the calls renamed to `PlaterTemucraft.*` (`SetCVar`, `GetCVar`, `GetCVarBool`,
`UnitGroupRolesAssigned`, `UnitBuff`, `GetBuildInfo` in `Plater.lua` and `Plater_OptionsPanel.lua`).

- **TOC**: Interface 30300, title "Plater (Temucraft)", depends on !TemucraftCompat. The CurseForge packager
  lines are gone, and `Plater_Temucraft.lua` (new, the port helpers) loads after the libraries.
- **Locales**: the release packager fills the locale files from CurseForge, so a source copy has a placeholder
  that is a syntax error. The placeholders are removed; `enUS.lua` has the English strings from the Plater-v560
  source (same keys). Other languages use English.
- **The 3.3.5 plate is hidden, not the retail UnitFrame**: on `NAME_PLATE_CREATED` a small stand-in object takes
  the place of the retail `UnitFrame`. When Plater hides it, the regions and bars of the 3.3.5 plate are set to
  alpha 0 (not hidden, so the compat layer can still read the level, elite icon and so on); when Plater leaves a
  kind of unit to the default plates, they are shown again. The plate tick keeps them hidden when the client
  shows a part again (the cast bar of the target).
- **Plate names**: 3.3.5 plates have no name; Plater's frames are named `PlaterTemucraftNamePlateN...`.
- **Always parented to UIParent** (the "use UIParent" option is forced on): as a child of the 3.3.5 plate,
  Plater's frame would take the plate alpha, which the client lowers on every plate but the target.
- **Target, focus and mouseover**: a 3.3.5 plate only knows its unit while it is one of those. When a plate gets
  or loses that unit, Plater updates the target marks, and the first time a plate's GUID is known the plate is
  set up again (npc colors, scripts by npc id).
- **Casts**: shown only for plates that are the target, focus or mouseover. The compat layer sends the
  `UNIT_SPELLCAST_*` events of those units again with the plate token and the newer arguments, and the Details!
  Framework cast bar reads `UnitCastingInfo` / `UnitChannelInfo` with the newer return values (spell id from the
  cast events or the combat log).
- **Auras**: read with `UnitAura` in the newer return order; the 10.0 slot code is turned off. Plates without a
  real unit show no auras. `UNIT_AURA` reaches Plater for plate tokens; aura tooltips use the real unit.
- **Console variables**: Plater's `SetCVar` / `GetCVar` calls go through `PlaterTemucraft.SetCVar` and friends.
  Retail nameplate variables that 3.3.5 doesn't have are skipped (and read as "0" in the options);
  `nameplateMotion` becomes `spreadnameplates`.
- **Roles and build**: `UnitGroupRolesAssigned` (3.3.5 gives three booleans) and `GetBuildInfo` (no fourth value
  on 3.3.5) are read through the compat versions with the newer return values.
- **Combo points**: `UnitPower`/`UnitPowerMax` with the combo point type use `GetComboPoints`; the combo point
  atlases are drawn from the 3.3.5 combo point texture (compat).
- **Details! Framework**: `GetBuildInfo` and cast/aura functions with newer return values, the spell book scan
  skips the General tab by index (3.3.5 gives no offspec id), and the tutorial alert used an undefined global.
- **Plater.xml**: 3.3.5 XML has no `mixin`, `parentArray`, `ignoreParentScale`, `useParentLevel` or
  `textureSubLevel`; the border template does its mixin and texture list in `OnLoad`.
- **LibDBIcon**: texture file ids replaced with paths (3.3.5 has no file ids).
- `.pkgmeta` and the `.github` workflow of the CurseForge packager were removed.

## What can't work on 3.3.5

- **Plates without a real unit** (not target, focus or mouseover) only have what the plate shows: name, level,
  health, reaction color, elite and boss icons, raid mark, threat glow. No auras, no casts, no power, no GUID
  (until the plate has been the target or mouseover once), so npc colors and scripts that need the npc id
  only apply after that.
- **Range check** for plates without a real unit always says "in range" (the client can't tell the distance).
- **Personal resource bar / player plate**: 3.3.5 has no plate for yourself.
- **Plate size and click area** are set by the client; the nameplate size options only change how Plater draws.
- **Nameplate CVars** of newer clients (distance, stacking options, alpha, overlap) don't exist; only
  `spreadnameplates` is used for stacking.
- **Retail-only features** stay off: unit widgets, Mythic+ affixes, encounter journal, specializations, PvP
  talents, Evoker essence, absorbs and heal prediction (no data on 3.3.5), quest boss and world quest checks.
- **Masks and atlases** (most resource textures except combo points and DK runes, mask textures) don't draw.
- **Mods and scripts** from Wago that call newer API directly (for example `UnitAura` expecting the newer return
  order, or `C_` functions that compat doesn't have) may fail; the bundled script library is unchanged.
- The bundled Details! Framework is version 379. If another addon loads a newer `DetailsFramework-1.0`, LibStub
  uses that one, without these 3.3.5 changes.

## Checking

The port is checked statically against the 3.3.5 API and !TemucraftCompat (`port_check`); what it still lists
is in the Temucraft project notes (`plater-port-plan.md`). It has not been run in game yet.
