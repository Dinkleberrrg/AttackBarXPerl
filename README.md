# AttackBarXPerl

Small add-on for WoW 1.12 (OctoWoW) that restyles the swing timers of [AttackBar](https://github.com/Siventt/AttackBar) to match the X-Perl unit frames.

## What it does
- Removes AttackBar's grey box, tooltip border and thick casting bar border.
- Uses X-Perl's bar texture and the width of the unit frames.
- Docks the player and enemy bars directly below the X-Perl frames.

## Requirements
- AttackBar
- XPerl (X-Perl UnitFrames)

## Settings
There is no menu. Height, spacing, font size and texture are constants at the top of `AttackBarXPerl.lua`.

## Note
`XPerl_SwingTimer` is the standalone successor and no longer needs AttackBar. Using both at the same time gives duplicate bars.

## Removal
Delete the folder.
