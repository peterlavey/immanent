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

2. **Basic 3D Scene & Camera** (Plan: 1.2)
   - Implement the 3D world with a 2D fixed camera.
   - Implement zoom functionality.
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

3. **Genezis Beings Behavior** (Plan: 2.3)
   - Implement the Genezis AI: move to data spot -> extract -> return to core.
   - Implement basic extraction and capacity logic.
   - Priority: High
   - Requirements: Req 3

4. **HUD & Resource Display** (Plan: 2.4)
   - Implement the HUD to display current data/bytes.
   - Priority: Medium
   - Requirements: Req 6

## Phase 3: Progression & Upgrades (Medium Priority)
Goal: Implement the upgrade systems and field of view expansion.

1. **Field of View (FOV) Sphere** (Plan: 3.1)
   - Implement the visual sphere representing FOV.
   - Implement the logic to restrict Genezis interactions within FOV.
   - Priority: Medium
   - Requirements: Req 7

2. **Upgrade System** (Plan: 3.2)
   - Implement the Core's upgrade interface.
   - Apply upgrades to Genezis (Speed, Capacity, Extraction Rate, Count).
   - Apply upgrades to FOV radius.
   - Priority: Medium
   - Requirements: Req 2, Req 3, Req 7

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
   - Requirements: Req 8

## Dependencies & Risks
- **Dependency**: Godot Engine integration.
- **Risk**: Performance issues with many Genezis beings (mitigate with optimized scripts).
- **Consideration**: Balancing the upgrade costs and iteration length.
