# Task List - Immanent

## Phase 1: Setup & Environment

- [x] **1.1 Project Initialization**
  - [x] Initialize Godot project and establish core directory structure (src/entities, src/ui, assets/models, etc.) (Plan: 1.1) (Req: All)
  - [x] Add basic documentation (README, guidelines) (Plan: 1.1) (Req: All)

- [x] **1.2 Advanced 3D Camera**
  - [x] Create a main 3D scene (World.tscn) (Plan: 1.2) (Req: 1)
  - [x] Implement camera orbit logic around the Core center (Plan: 1.2) (Req: 1)
  - [x] Implement camera zoom (Plan: 1.2) (Req: 1)
  - [x] Implement camera rotation controls (Plan: 1.2) (Req: 1)
  - [x] Calibrate initial camera distance to show FOV (Plan: 1.2) (Req: 1)

- [x] **1.3 Core Base**
  - [x] Create the Core node and placeholder visual representation (Plan: 1.3) (Req: 2)
  - [x] Implement the Core's data storage script (Plan: 1.3) (Req: 2)
  - [x] Calibrate initial data to 1 MB for testing (Plan: 1.3) (Req: 2)

## Phase 2: Core Gameplay Loop

- [x] **2.1 Time & Hertz System**
  - [x] Implement an iteration timer (2 minutes = 1 iteration) (Plan: 2.1) (Req: 5)
  - [x] Implement a Hertz-based display for current time/iteration (Plan: 2.1) (Req: 5)

- [x] **2.2 Data Spots**
  - [x] Create a Data Spot scene with a "megabytes" property (Plan: 2.2) (Req: 4)
  - [x] Implement spawning logic (5 spots per iteration, 1 KB each initially, min distance from Core) (Plan: 2.2) (Req: 4)

- [x] **2.3 Genezis Beings**
  - [x] Create a Genezis being scene (Plan: 2.3) (Req: 3)
  - [x] Implement state machine for Genezis AI: IDLE -> MOVING_TO_DATA -> EXTRACTING -> RETURNING_TO_CORE -> DEPOSITING (Plan: 2.3) (Req: 3)
  - [x] Implement movement logic (Plan: 2.3) (Req: 3)
  - [x] Implement data extraction and carry capacity (Plan: 2.3) (Req: 3)
  - [x] Refactor collection to use 1-byte increments and 1024-based translation (Plan: 2.3) (Req: 3)
  - [x] Implement clickable Genezis to show statistics (Plan: 2.3.1) (Req: 3)

- [x] **2.4 HUD**
  - [x] Create the HUD scene (Plan: 2.4) (Req: 6)
  - [x] Display total collected bytes from the Core (Plan: 2.4) (Req: 6)
  - [x] Display total Genezis count on the HUD (Plan: 2.4) (Req: 6)

## Phase 3: Progression & Upgrades

- [x] **3.1 Field of View (FOV)**
  - [x] Implement the visual FOV sphere around the Core (Plan: 3.1) (Req: 7)
  - [x] Logic to hide or prevent Genezis from moving to data spots outside FOV (Plan: 3.1) (Req: 7)

- [x] **3.2 Upgrade System**
  - [x] Create an upgrade UI menu at the Core (Plan: 3.2) (Req: 2, 3)
  - [x] Implement "Genezis Movement Speed" upgrade (Plan: 3.2) (Req: 3)
  - [x] Implement "Extraction Rate" upgrade (Plan: 3.2) (Req: 3)
  - [x] Implement "Carry Capacity" upgrade (Plan: 3.2) (Req: 3)
  - [x] Implement "FOV Expansion" upgrade (Plan: 3.2) (Req: 7)
  - [x] Implement "Genezis Count" upgrade (Plan: 3.2) (Req: 3)

- [x] **3.3 Visual Feedback**
  - [x] Create Floating Text scene and script (Plan: 3.3) (Req: 8)
  - [x] Integrate Floating Text spawning in Core data deposition (Plan: 3.3) (Req: 8)
  - [x] Calibrate Floating Text size (twice the size of Genezis) and movement for RPG-like feedback (Plan: 3.3) (Req: 8)

## Phase 4: Final Features & Goal

- [ ] **4.1 Evolution Milestones**
  - [ ] Implement the evolution logic at the Core (Plan: 4.1) (Req: 2)
  - [ ] Create larger data spot variants (e.g., 50 MB) (Plan: 4.1) (Req: 4)

- [ ] **4.2 The Escape**
  - [ ] Implement the final win condition logic (Plan: 4.2) (Req: 9)
  - [ ] Final win screen/cutscene (Plan: 4.2) (Req: 9)
