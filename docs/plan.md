# Implementation Plan - Immanent

## Overview
This plan outlines the development phases for "Immanent," a 3D idle game focusing on resource collection and evolution within a digital simulation. The project follows Clean Architecture and SOLID principles, prioritizing simple, functional, and testable code.

## Phase 1: Basic Simulation Environment & Infrastructure (High Priority)
Goal: Set up the fundamental project structure and the static elements of the simulation.

1. **Project Initialization** (Plan: 1.1)
   - Set up the Godot environment (based on `project.godot`).
   - Establish directory structure (src, assets, docs, tests).
   - Priority: High
   - Requirements: All

2. **Advanced 3D Camera** (Plan: 1.2)
   - Implement the 3D camera that orbits around the Core.
   - Implement zoom functionality towards the center.
   - Implement rotation/orbiting via mouse/touch input.
   - Priority: High
   - Requirements: Req 1

3. **The Core Base Implementation** (Plan: 1.3)
   - Create the Core visual model and its position in the world.
   - Implement basic resource storage logic (Data/Bytes).
   - Priority: High
   - Requirements: Req 2

## Phase 2: Core Gameplay Mechanics (High Priority)
Goal: Implement the primary loop of data collection and time management.

1. **Time Management (Hertz System)** (Plan: 2.1)
   - Implement the iteration clock (2 minutes per iteration).
   - Define the "Hertz" unit of time.
   - Priority: High
   - Requirements: Req 5

2. **Data Spot Spawning** (Plan: 2.2)
   - Implement the spawning logic for data spots.
   - Ensure spots spawn within the initial field of view.
   - Priority: High
   - Requirements: Req 4

3. **Genezis G1 Beings Behavior** (Plan: 2.3)
   - Implement the Genezis G1 AI: move to data spot -> extract (in bytes) -> return to core.
   - Implement capacity logic using byte increments (1024 base translation).
   - Implement Genezis G1 selection and statistics display (Plan: 2.3.1).
   - Priority: High
   - Requirements: Req 3

51: 4. **HUD & Resource Display** (Plan: 2.4)
    - Implement the HUD to display current data/bytes.
    - Implement the HUD to display current Genezis G1 count.
    - Priority: Medium
    - Requirements: Req 6

## Phase 3: Progression & Upgrades (Medium Priority)
Goal: Implement the upgrade systems and field of view expansion.

1. **Field of View (FOV) Sphere** (Plan: 3.1)
   - Implement the visual sphere representing FOV.
   - Implement the logic to restrict Genezis G1 interactions within FOV.
   - Priority: Medium
   - Requirements: Req 7

2. **Upgrade System** (Plan: 3.2)
   - Implement the Core's upgrade interface.
   - Apply upgrades to Genezis G1 (Speed, Capacity, Extraction Rate, Count).
   - Apply upgrades to FOV radius.
   - Priority: Medium
   - Requirements: Req 2, Req 3, Req 7

3. **Visual Feedback (Floating Text)** (Plan: 3.3)
   - Implement floating text bubble for data deposits.
   - Move text upwards and fade out.
   - Priority: Medium
   - Requirements: Req 8

## Phase 4: Evolution & Win Condition (Low Priority)
Goal: Implement the final evolution stages and the game's conclusion.

1. **Evolution Phases** (Plan: 4.1)
   - Define evolution milestones and requirements.
   - Implement larger data spot variants for advanced phases.
   - Priority: Low
   - Requirements: Req 2, Req 4

2. **The "Escape" Win Condition** (Plan: 4.2)
   - Implement the final "Escape the Simulation" event.
   - Priority: Low
   - Requirements: Req 9

3. **Genezi G1 Fusion & G2 Implementation** (Plan: 4.3)
   - Implement the fusion logic for G1 to G2.
   - Implement the Genezi G2 protective behaviors and visual.
   - Priority: Medium
   - Requirements: Req 10

## Phase 5: Digital Threats & Combat (Medium Priority)
Goal: Implement digital threats (viruses) and defense mechanics.

1. **Digital Threats (Viruses)** (Plan: 5.1)
   - Create base enemy scene and AI.
   - Implement "Bit-Scrubber" (targets G1 load).
   - Implement "Defragmenter" (consumes Data Spots).
   - Priority: Medium
   - Requirements: Req 11

2. **G2 Combat & Protection** (Plan: 5.2)
   - Implement G2 defensive behavior to intercept enemies.
   - Implement basic health/integrity system and dispersal logic.
   - Priority: Medium
   - Requirements: Req 10, Req 11

3. **Advanced Digital Threats** (Plan: 5.3)
   - Implement "Logic Leak" (negative extraction/core drain).
   - Implement "Code-Shadow" (G1 mimic/core saboteur).
   - Implement "Null-Pointer" (FOV dead zone/patching mechanic).
   - Implement "Stack-Overflow" (multi-segmented boss worm).
   - Implement "Firewall Guardian" (turret/projectile defense).
   - Priority: Low
   - Requirements: Req 12

## Phase 6: Visual Overhaul (High Priority)
Goal: Redesign entities to match the "Digital Biome" aesthetic.

1. **Genezis G1: Bacteriophage Model** (Plan: 6.1)
   - Implement the "Bacteriophage" design using Godot nodes (Hexagonal head, neck, legs).
   - Priority: High
   - Requirements: Req 13

2. **Genezis G2: Guardian Model** (Plan: 6.2)
   - Redesign G2 as a robust "Cell Guardian" version of G1.
   - Priority: Medium
   - Requirements: Req 13

3. **The Core: Processor Hub** (Plan: 6.3)
   - Redesign the Core as a central unit with glowing circuits and mechanical components.
   - Priority: Medium
   - Requirements: Req 13

4. **Enemies: Malware Redesign** (Plan: 6.4)
   - Update Bit-Scrubber and Defragmenter to look more like digital "corruption".
   - Priority: Medium
   - Requirements: Req 13

 5. **Data Spot: Code Crystal** (Plan: 6.5)
   - Redesign the Data Spot as a "Code Crystal" with floating shards.
   - Priority: Medium
   - Requirements: Req 13

6. **Background Atmosphere: Space-Digital** (Plan: 6.6)
   - Implement a dark, space-like sky with digital grid/star elements.
   - Configure Glow/Bloom for better visual quality.
   - Priority: Medium
   - Requirements: Req 14
   - Status: Completed

7. **Laptop Compatibility: Touchpad Gestures** (Plan: 6.7)
   - Implement macOS/Laptop touchpad support for pinch-to-zoom.
   - Enhance camera orbiting to respond correctly to trackpad pan gestures.
   - Priority: Medium
   - Requirements: Req 1
   - Status: Completed

## Phase 7: Audio & Atmosphere (Medium Priority)
Goal: Add immersive music and sound effects to the simulation.

1. **Audio Infrastructure** (Plan: 7.1)
   - Create `AudioManager` singleton to manage global music and SFX.
   - Set up audio buses (Master, Music, SFX) in Godot.
   - Priority: Medium
   - Requirements: Req 12

2. **Ambient Music** (Plan: 7.2)
   - Integrate seamless looping ambient electronic music.
   - Implement fade-in/out logic for scene transitions.
   - Priority: Medium
   - Requirements: Req 12

3. **Sound Effects (SFX)** (Plan: 7.3)
   - Implement SFX for:
     - Data collection/deposition.
     - UI interactions (upgrades, menu clicks).
     - Combat (shots, dispersal, enemy arrival).
     - Evolution milestones.
   - Priority: Medium
   - Requirements: Req 12

## Phase 10: Persistence & Optimization (Medium Priority)
Goal: Implement game state persistence and performance optimizations.

1. **Save & Load System** (Plan: 10.1)
   - Implement `SaveManager` for JSON serialization.
   - Integrate manual Save/Load buttons in HUD.
   - Priority: Medium
   - Requirements: Req 17

2. **Autosave Feature** (Plan: 10.2)
   - Trigger `SaveManager.save_game()` upon mission completion.
   - Priority: Medium
   - Requirements: Req 17

3. **Delete Save Feature** (Plan: 10.3)
   - Implement `delete_save()` in `SaveManager`.
   - Add Delete button to HUD and handle UI state.
   - Priority: Low
   - Requirements: Req 17
193:
194:## Phase 8: Missions & Objectives (Medium Priority)
195:Goal: Provide a structured progression system with specific tasks.
196:
197:1. **Mission System Framework** (Plan: 8.1)
198:   - Implement `MissionManager` to track current mission and progress.
199:   - Create HUD interface for mission display.
200:   - Priority: Medium
201:   - Requirements: Req 15
202:
203:2. **Level 1 Missions** (Plan: 8.2)
204:   - Define initial mission sequence.
205:   - Mission 1: "First Steps" - Create 1 Genezis G2.
206:   - Mission 2: "Information Gathering" - Collect 1 MB of data.
207:   - Priority: Medium
208:   - Requirements: Req 15

## Phase 9: Visual Enhancements (High Priority)
Goal: Enhance the simulation's visual depth and atmosphere.

1. **3D Parallax Background** (Plan: 9.1)
   - Implement a parallax effect using `space.jpg` to create a 3D sense of depth.
   - Use a `PanoramaSkyMaterial` for the base background.
   - Use a separate, slower-moving 3D layer for the parallax effect.
   - Priority: High
   - Requirements: Req 16

## Phase 11: Advanced G1 Networks (High Priority)
Goal: Implement G1 connection-based upgrades (Psinergy).

1. **Psinergy Logic** (Plan: 11.1)
   - Implement proximity detection between G1 units.
   - Visualize connections using beams at all times when in range.
   - Apply extraction speed boost when connected.
   - Priority: High
   - Requirements: Req 14

2. **Psinergy Upgrade** (Plan: 11.2)
   - Add a single "Psinergy" upgrade to the Upgrade Menu that increases both range and boost.
   - Restrict upgrades to Core Level 2+.
   - Priority: High
   - Requirements: Req 14
