# Testing Retrospective - Upgrade Menu Overflow Fix

## Overview
The issue was that buttons in the Upgrade Menu were sometimes larger than their container, especially when labels became long due to cost formatting or requirement messages (e.g., "FUSE GENEZIS (4 G1 -> 1 G2) (REQUIRES EVOLUTION LEVEL 2)").

## Changes
1.  **Increased Menu Width**: The `UpgradeMenu` control in `UpgradeMenu.tscn` was widened from 300px to 400px to provide more horizontal space.
2.  **Enabled Text Wrapping**: 
    -   Modified `UpgradeMenu.tscn` to set `autowrap_mode = 2` (Word wrap) for all static buttons.
    -   Modified `UpgradeMenu.gd` to set `autowrap_mode = TextServer.AUTOWRAP_WORD_SMART` for all dynamically created buttons (Evolution, Fusion, Psinergy, G0).

## Verification (Manual Analysis)
-   **Static Buttons**: `SpeedButton`, `ExtractionButton`, `CapacityButton`, and `GenezisG1CountButton` now have `autowrap_mode = 2` in the TSCN file.
-   **Dynamic Buttons**: In `_ready()`, `evolution_button`, `fusion_button`, `psinergy_button`, and `genezis_g0_button` are initialized with `autowrap_mode = TextServer.AUTOWRAP_WORD_SMART`.
-   **Layout**: The `VBoxContainer` will now allow buttons to expand vertically if their text wraps, and the parent `Panel` (with `MarginContainer`) will contain them properly as long as the vertical space is sufficient. The menu height was also increased to 500px to accommodate wrapped text.

## Retrospective
The fix addresses both the root cause (fixed width with non-wrapping text) and provides extra safety by increasing the container size. This is a robust approach for Godot UI overflow issues.
