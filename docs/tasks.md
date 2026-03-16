# Task List - Immanent

## Phase 1: Setup & Environment

- [x] **1.1 Project Initialization**
  - [x] Initialize Godot project and establish core directory structure (src/entities, src/ui, assets/models, etc.) (Plan: 1.1) (Req: All)
  - [x] Add basic documentation (README, guidelines) (Plan: 1.1) (Req: All)
  - [x] Reorganize files into component-specific subfolders (e.g., src/entities/genezis_g1/)
  - [x] Organize files by relationship (e.g., genezis_g1 and genezis_g2 inside genezis folder)

- [x] **1.2 Advanced 3D Camera**
  - [x] Create a main 3D scene (World.tscn) (Plan: 1.2) (Req: 1)
  - [x] Implement camera orbit logic around the Core center (Plan: 1.2) (Req: 1)
  - [x] Implement camera zoom (Plan: 1.2) (Req: 1)
  - [x] Implement camera rotation controls (Plan: 1.2) (Req: 1)
  - [x] Implement camera movement by holding down the main click and dragging (Plan: 1.2) (Req: 1)
  - [x] Calibrate initial camera distance to show FOV (Plan: 1.2) (Req: 1)

- [x] **1.3 Core Base**
  - [x] Create the Core node and placeholder visual representation (Plan: 1.3) (Req: 2)
  - [x] Implement the Core's data storage script (Plan: 1.3) (Req: 2)
  - [x] Calibrate initial data to 3 MB for testing (Plan: 1.3) (Req: 2)

## Phase 2: Core Gameplay Loop

- [x] **2.1 Time & Hertz System**
  - [x] Implement an iteration timer (2 minutes = 1 iteration) (Plan: 2.1) (Req: 5)
  - [x] Implement a Hertz-based display for current time/iteration (Plan: 2.1) (Req: 5)

- [x] **2.2 Data Spots**
  - [x] Create a Data Spot scene with a "megabytes" property (Plan: 2.2) (Req: 4)
  - [x] Implement spawning logic (5 spots per iteration, 1 KB each initially, min distance from Core) (Plan: 2.2) (Req: 4)

- [x] **2.3 Genezis G1 Beings**
- [x] Create a Genezis G1 being scene (Plan: 2.3) (Req: 3)
- [x] Implement state machine for Genezis G1 AI: IDLE -> MOVING_TO_DATA -> EXTRACTING -> RETURNING_TO_CORE -> DEPOSITING (Plan: 2.3) (Req: 3)
- [x] Implement movement logic (Plan: 2.3) (Req: 3)
- [x] Implement data extraction and carry capacity (Plan: 2.3) (Req: 3)
- [x] Refactor collection to use 1-byte increments and 1024-based translation (Plan: 2.3) (Req: 3)
- [x] Implement clickable Genezis G1 to show statistics (Plan: 2.3.1) (Req: 3)
- [x] Implement surrounding logic for data spots to prevent piling up (Plan: 2.3.2) (Req: 3)
- [x] Fix G1 mining issues by relaxing FOV and distance checks (Plan: 2.3.3) (Req: 3)

- [x] **2.4 HUD**
  - [x] Create the HUD scene (Plan: 2.4) (Req: 6)
  - [x] Display total collected bytes from the Core (Plan: 2.4) (Req: 6)
  - [x] Display total Genezis G1 count on the HUD (Plan: 2.4) (Req: 6)
  - [x] Fix missing GenezisCountLabel in HUD.tscn (Plan: 2.4.1) (Req: 6)

## Phase 3: Progression & Upgrades

- [x] **3.1 Field of View (FOV)**
  - [x] Implement the visual FOV sphere around the Core (Plan: 3.1) (Req: 7)
  - [x] Logic to hide or prevent Genezis from moving to data spots outside FOV (Plan: 3.1) (Req: 7)

- [x] **3.2 Upgrade System**
  - [x] Create an upgrade UI menu at the Core (Plan: 3.2) (Req: 2, 3)
  - [x] Implement "Genezis G1 Movement Speed" upgrade (Plan: 3.2) (Req: 3)
  - [x] Implement "Extraction Rate" upgrade (Plan: 3.2) (Req: 3)
  - [x] Implement "Carry Capacity" upgrade (Plan: 3.2) (Req: 3)
  - [x] Implement "FOV Expansion" upgrade (Plan: 3.2) (Req: 7)
  - [x] Implement "Genezis G1 Count" upgrade (Plan: 3.2) (Req: 3)
  - [x] Split upgrades between Core and Genezis G1 clicks (Plan: 3.2.1) (Req: 2, 3)
  - [x] Remove legacy upgrade button and fix context-sensitive clicking (Plan: 3.2.2) (Req: 2, 3)
  - [x] Fix click interference from FOV and improve menu closing logic (Plan: 3.2.3) (Req: 2, 3)
  - [x] Upgrade costs increase as improvements are made (Plan: 3.2) (Req: 2, 3)
  - [x] Limit Genezis G1 and Core upgrades to a maximum of 5 (Plan: 3.2) (Req: 3, 7)
  - [x] Implement "Core Evolution" upgrade to expand limits and unlock new features (Plan: 4.1) (Req: 4.1)
  - [x] Ensure Genezis G1 stats update in real-time when purchasing upgrades (Plan: 3.2.4) (Req: 3, 6)
  - [x] Fix initial Genezis G1 not being clickable for upgrades (Plan: 3.2.5) (Req: 3)
  - [x] Disable upgrades that the player cannot afford (Plan: 3.2.6) (Req: 2, 3)
  - [x] Fix second G1 not mining data when appearing (Plan: 3.2.8) (Req: 3)
  - [x] Implement stuck detection for Genezis G1 to prevent idle loops or pathfinding failures.
  - [x] Improve G1 stuck recovery by varying target offsets and relaxing reachability thresholds.

  - [x] **3.3 Visual Feedback**
  - [x] Create Floating Text scene and script (Plan: 3.3) (Req: 8)
  - [x] Integrate Floating Text spawning in Core data deposition (Plan: 3.3) (Req: 8)
  - [x] Calibrate Floating Text size (twice the size of Genezis G1) and movement for RPG-like feedback (Plan: 3.3) (Req: 8)

## Phase 4: Final Features & Goal

- [x] **4.1 Evolution Milestones**
  - [x] Implement the evolution logic at the Core (Plan: 4.1) (Req: 4.1)
  - [x] Expand upgrade limits from 5 to 10 upon evolution (Plan: 4.1) (Req: 4.1)
  - [x] Implement new upgrades unlocked after evolution (Plan: 4.1) (Req: 4.1)
  - [x] Create larger data spot variants (e.g., 50 MB) (Plan: 4.1) (Req: 4.1)
  - [x] Ensure at least 4 "data" spots at the beginning within the "FOV"

- [ ] **4.2 The Escape**
  - [ ] Implement the final win condition logic (Plan: 4.2) (Req: 9)
  - [ ] Final win screen/cutscene (Plan: 4.2) (Req: 9)

- [x] **4.3 Genezi G2 & Fusion**
  - [x] Implement Genezi G2 entity with protective AI (Plan: 4.3) (Req: 10)
  - [x] Implement fusion logic (4 G1 -> 1 G2) in WorldManager (Plan: 4.3) (Req: 10)
  - [x] Implement visual merging (4 G1s moving to center) before G2 creation (Plan: 4.3) (Req: 10)
  - [x] Add fusion option to Genezis G1's upgrade menu (Plan: 4.3) (Req: 10)
  - [x] Require Evolution Level 2 for G2 fusion (Req: 10)
  - [x] Create visual representation for Genezi G2 (Plan: 4.3) (Req: 10)
  - [x] Add validation to Fusion to require at least 5 G1 units (leaving 1 spare) (Plan: 4.3) (Req: 10)
  - [x] Validate G1 limit based on current population to allow replenishing after fusion (Plan: 4.3) (Req: 10)
  - [x] Fix Upgrade Menu refresh bug after fusion by removing Genezis G1 from group before queue_free() (Plan: 4.3.1)
  - [x] Fix Godot editor 'File not found' errors by updating cached script references after renaming Genezis to Genezis G1.
  - [x] Spawn enemies when the first Genezis G2 is created for testing. (Plan: 4.3) (Req: 10, 11)
  - [x] Trigger Bit-Scrubber spawn on the first Genezis G2 generation.
  - [x] Trigger Defragmenter spawn on the second Genezis G2 generation.

## Phase 6: Visual Identity & Modeling

- [x] **6.1 Genezis G1 Redesign**
  - [x] Implement the "Bacteriophage" hexagonal head using a `CylinderMesh` or custom procedural mesh (Plan: 6.1) (Req: 13)
  - [x] Implement the "Neck/Stalk" using a `CylinderMesh` (Plan: 6.1) (Req: 13)
  - [x] Implement "Legs" for anchoring using `CylinderMesh` or `CSGBox3D` (Plan: 6.1) (Req: 13)
  - [x] Add mining animations (e.g., slight head pulsation when extracting) (Plan: 6.1) (Req: 13)
  - [x] Implement visual connection (beam) between G1 and Data Spots/Core during extraction and deposition

- [x] **6.2 Genezis G2 Redesign**
  - [x] Enhance G2 model with protective plates/armor based on the G1 base (Plan: 6.2) (Req: 13)
  - [x] Add defensive light/shield visual when in intercept mode (Plan: 6.2) (Req: 13)

- [x] **6.3 The Core Redesign**
  - [x] Build a "Processor Hub" using `CSGBox3D` and `CSGCylinder3D` (Plan: 6.3) (Req: 13)
  - [x] Add glowing circuitry materials (Plan: 6.3) (Req: 13)

- [x] **6.4 Enemy Visual Polish**
  - [x] Redesign Bit-Scrubber with jagged "corruption" elements (Plan: 6.4) (Req: 13)
  - [x] Redesign Defragmenter with "glitchy" geometry (Plan: 6.4) (Req: 13)

- [x] **6.5 Data Spot Redesign**
  - [x] Redesign Data Spot as a "Code Crystal" with a central core and floating shards (Plan: 6.5) (Req: 13)


- [x] **6.6 Background Atmosphere**
  - [x] Update `WorldEnvironment` with a dark space-digital theme (Plan: 6.6) (Req: 14)
  - [x] Configure `ProceduralSkyMaterial` with deep blues/blacks (Plan: 6.6) (Req: 14)
  - [x] Enable and calibrate Glow/Bloom for digital atmosphere (Plan: 6.6) (Req: 14)
  - [x] Add a grid or digital pattern to the environment visuals (Plan: 6.6) (Req: 14)

- [x] **5.1 Basic Enemy Infrastructure**
  - [x] Create base `Enemy.gd` with state machine and navigation (Plan: 5.1) (Req: 11)
  - [x] Implement "Bit-Scrubber" entity and visuals (Plan: 5.1) (Req: 11)
  - [x] Implement "Defragmenter" entity and visuals (Plan: 5.1) (Req: 11)
  - [x] Implement enemy spawning logic in `WorldManager` (Plan: 5.1) (Req: 11)

- [x] **5.2 Combat & Protection Logic**
  - [ ] Add `health` / `integrity` to Genezis and Enemies (Plan: 5.2) (Req: 11)
  - [x] Update Genezis G2 AI to include `INTERCEPT` and `ATTACK` states (Plan: 5.2) (Req: 10, 11)
  - [x] Implement shooting mechanic for Genezis G2 (Plan: 5.2) (Req: 10, 11)
  - [x] Implement dispersal logic (enemies are removed when health reach 0) (Plan: 5.2) (Req: 11)
  - [x] Implement defragmentation effect when enemies die (Plan: 5.2) (Req: 11)
  - [x] Implement visual feedback for combat (e.g., color flashes or small particles) (Plan: 5.2) (Req: 11)
  - [x] Implement enemy discovery description popups that pause the game (Plan: 5.2.1) (Req: 11)
  - [x] Fix missing EnemyDescriptionUI scene and connection in HUD (Plan: 5.2.2)
  - [x] Ensure other menus are closed when the enemy description appears to avoid interaction conflicts (Plan: 5.2.3)
  - [x] Fix input blocking and signal connection for EnemyDescriptionUI close button (Plan: 5.2.4)
  - [x] Fix crash "Invalid access to property or key 'global_position' on a base object of type 'previously freed'" by adding defensive instance validation.
  - [x] Implement Bit-Scrubber data theft visuals (laser/particles) and red floating text (Plan: 5.2.5)
  - [x] Implement Bit-Scrubber theft cooldown logic (Plan: 5.2.6)

## Phase 8: Missions & Levels

- [x] **8.1 Mission Infrastructure**
  - [x] Implement `MissionManager` to track objectives (Plan: 8.1) (Req: 15)
  - [x] Update HUD to display Mission name, description, and progress (Plan: 8.1) (Req: 15)
  - [x] Update game start to 0 data and 1 G1 (Plan: 8.1) (Req: 15)

- [x] **8.2 Level 1 Missions**
  - [x] Implement Mission 1: "Core Optimization" - Optimize the Core, earn 500 bytes reward (Plan: 8.2) (Req: 15)
  - [x] Implement Mission 2: "Security Protocol" - Fuse G1 to create 2 G2 Guardians (Plan: 8.2) (Req: 15)
  - [x] Implement Mission 3: "Data Harvest" - Accumulate a total of 1 MB (Plan: 8.2) (Req: 15)
  - [x] Fix mission HUD not advancing to the second mission
  - [x] Fix stack overflow when evolving core (Mission reward recursion)
  - [x] Ensure all upgrades apply to both existing and future Genezis beings (Plan: 3.2.9) (Req: 3)
  - [x] Implement data spot targeting optimization to prevent Genezis G1 miners from piling up (Plan: 3.2.7) (Req: 3)
  - [x] Fix G2 Fusion button not being enabled after Core evolution (Mission 2)
  - [x] Reduce G2 fusion cost (from 50 KB to 25 KB) and Core evolution level 3 cost (from 256 KB to 128 KB) and lowered the upgrade cost multiplier from 1.5 to 1.25 to improve mission progression and reduce frustration.

- [x] **6.7 Space Environment & 3D Floating**
  - [x] Remove the floor grid to create a space-like void (Plan: 6.7)
  - [x] Implement 3D spawning for Data Spots and Enemies (Plan: 6.7)
  - [x] Enable 3D movement and pathfinding for Genezis G1 and G2 (Plan: 6.7)
  - [x] Update camera to allow full spherical rotation (Plan: 6.7)

- [x] **6.8 Laptop Compatibility**
  - [x] Implement macOS/Laptop touchpad support for pinch-to-zoom (Plan: 6.7) (Req: 1)
  - [x] Enhance camera orbiting for trackpad pan gestures (Plan: 6.7) (Req: 1)
  - [x] Fix compilation error for gesture types by using generic `is_class` and `get` checks.
  - [x] Handle potential null values when using `get()` for gesture properties.
  - [x] Switch to `_unhandled_input` and `get_class()` for better reliability.
  - [x] Add fallback support for Ctrl + Mouse Wheel zoom (standard macOS behavior).
  - [x] Implement support for `command_or_control_autoremap` to catch macOS Command-based gestures.

- [ ] **5.3 Advanced Threats**
  - [ ] Implement "Logic Leak" enemy and negative extraction logic (Plan: 5.3) (Req: 12)
  - [ ] Implement "Code-Shadow" enemy and mimic behavior (Plan: 5.3) (Req: 12)
  - [ ] Implement "Null-Pointer" anomaly and patching mechanic (Plan: 5.3) (Req: 12)
  - [ ] Implement "Stack-Overflow" boss worm logic (Plan: 5.3) (Req: 12)
  - [ ] Implement "Firewall Guardian" turret and projectile system (Plan: 5.3) (Req: 12)

## Phase 7: Audio Implementation

- [x] **7.1 Audio Infrastructure**
  - [x] Create `assets/audio/music` and `assets/audio/sfx` directories (Plan: 7.1)
  - [x] Create `AudioManager.gd` singleton (Plan: 7.1) (Req: 12)
  - [x] Register `AudioManager` in project settings as an Autoload (Plan: 7.1) (Req: 12)
  - [x] Configure `default_bus_layout.tres` with Music and SFX buses (Plan: 7.1) (Req: 12)

- [x] **7.2 Music Integration**
  - [x] Add background music track (Plan: 7.2) (Req: 12)
  - [x] Implement music looping and basic volume control (Plan: 7.2) (Req: 12)
  - [x] Ensure music continues playing during pause (enemy description popups) (Plan: 7.2) (Req: 12)

- [x] **7.3 Sound Effects (SFX)**
  - [x] Implement SFX for Data Deposition in `Core.gd` (Plan: 7.3) (Req: 12)
  - [x] Implement SFX for UI Button clicks in `UpgradeMenu.gd` (Plan: 7.3) (Req: 12)
  - [x] Implement SFX for Evolution event (Plan: 7.3) (Req: 12)
  - [x] Implement SFX for Enemy arrival and dispersal (Plan: 7.3) (Req: 12)
  - [x] Implement SFX for G2 shooting (Plan: 7.3) (Req: 12)
  - [x] Implement SFX for Genezis G1 and G2 generation (Plan: 7.3) (Req: 12)

## Phase 10: Persistence & Optimization

- [x] **10.1 Save & Load System**
  - [x] Implement `SaveManager` to handle JSON serialization of game state (Plan: 10.1) (Req: 17)
  - [x] Integrate Save/Load buttons into the HUD (Plan: 10.1) (Req: 17)
  - [x] Implement state restoration for Core, World, Missions, Upgrades, and Time (Plan: 10.1) (Req: 17)
  - [x] Fix duplicate initial spawns when loading a saved game (Plan: 10.1) (Req: 17)
  - [x] Enable/Disable Load button based on save file existence (Plan: 10.1) (Req: 17)

- [x] **10.2 Autosave**
  - [x] Trigger autosave every time a mission is completed (Plan: 10.2) (Req: 17)

- [x] **10.3 Save/Load Fixes**
  - [x] Fix typed array assignment error in `SaveManager.gd` for `_discovered_enemies` (Plan: 10.3)
  - [x] Improve enemy type identification using `class_name` and `is` operator (Plan: 10.3)
  - [x] Fix save/load for G2 count, G1 stats, and Core data (Plan: 10.3)
  - [x] Implement save file deletion functionality in `SaveManager` and HUD (Plan: 10.3) (Req: 17)

## Phase 9: Visual Enhancements

- [x] **9.1 3D Parallax Background**
  - [x] Update `WorldEnvironment` to use `space.jpg` (now in `assets/textures/`) as a Panorama Sky (Plan: 9.1) (Req: 16)
  - [x] Create a `ParallaxBackground3D` layer with a sphere or large quads using the space texture (Plan: 9.1) (Req: 16)
  - [x] Implement camera rotation/orbit-based parallax logic in `Camera.gd` (Plan: 9.1) (Req: 16)
  - [x] Ensure the background appears "distant" but responds with depth to camera movements (Plan: 9.1) (Req: 16)
  - [x] Fix "mosaic" effect in background by disabling triplanar mapping and adjusting UV scale (Plan: 9.1) (Req: 16)
