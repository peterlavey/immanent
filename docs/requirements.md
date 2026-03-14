# Requirements Document

## Introduction
Immanent is a 3D idle game set inside a digital simulation (processor). Players manage a core base and "genezis" beings to collect "data" resources, evolve their civilization, and ultimately escape the simulation. Time is measured in Hertz (iterations), and the game uses a fixed 2D camera with zoom functionality.

## Core Gameplay Requirements

1. **Camera System**
   - **User Story**: As a player, I want to be able to move and rotate the camera while it remains focused on the Core so that I can view the simulation from different angles.
   - **Acceptance Criteria**: 
     - WHEN the game starts THEN the camera SHALL be focused on the Core at the center.
     - WHEN the player uses the mouse wheel or touch gesture THEN the camera SHALL zoom in or out towards the Core.
     - WHEN the player drags the mouse (e.g., right-click or middle-click) THEN the camera SHALL orbit around the Core.
     - THE system SHALL ensure the Core remains at the center of the camera's view.

2. **The Core (Space Center)**
   - **User Story**: As a player, I want a central hub (the Core) so that I can store resources and manage evolutions.
   - **Acceptance Criteria**:
     - WHEN a genezis being returns with data THEN the system SHALL store the data in the Core.
     - THE Core SHALL serve as the interface for triggering evolution phases.
     - THE Core SHALL allow upgrading Genezis attributes.

3. **Genezis Beings & Data Collection**
   - **User Story**: As a player, I want autonomous beings to collect data in 1-byte increments so that my resource pool grows with precision.
   - **Acceptance Criteria**:
     - WHEN data spots are within the field of view THEN Genezis beings SHALL automatically move to them and extract data in 1-byte increments at a slow initial rate (e.g., 10 B/s).
     - THE system SHALL translate 1024 bytes into 1 KB, 1024 KB into 1 MB, and so on, for display.
     - WHEN a Genezis being's capacity is reached THEN it SHALL return to the Core to deposit data.
     - THE extraction rate, movement speed, carry capacity, and count SHALL be upgradeable.
     - WHEN a Genezis being is clicked THEN the system SHALL show its statistics (Speed, Capacity, Extraction Rate, Current Load).

4. **Data Spots & Spawning**
   - **User Story**: As a player, I want new data spots to appear periodically so that I have a continuous supply of resources.
   - **Acceptance Criteria**:
     - WHEN a new "day" (iteration) starts THEN the system SHALL spawn 5 data spots initially.
     - EACH initial data spot SHALL contain 1 KB of data (1,024 bytes).
     - AS evolution progresses THEN the system SHALL spawn larger data spots.

5. **Time & Iterations (Hertz)**
   - **User Story**: As a player, I want time to be measured in iterations so that the simulation theme is reinforced.
   - **Acceptance Criteria**:
     - THE system SHALL measure time in Hertz.
     - ONE initial iteration SHALL last exactly 2 minutes.
     - WHEN an iteration ends THEN the next "day" of resource spawning SHALL begin.

6. **HUD (Heads-Up Display)**
   - **User Story**: As a player, I want to see my collected data balance so that I can track my progress.
   - **Acceptance Criteria**:
     - THE system SHALL display the total number of collected bytes on the screen.
     - THE system SHALL display the total number of Genezis beings currently active in the simulation.

7. **Upgrades & Field of View**
   - **User Story**: As a player, I want to expand my field of view so that I can discover more distant data spots.
   - **Acceptance Criteria**:
     - THE field of view SHALL be visually represented by a sphere around the Core.
     - WHEN the field of view is upgraded THEN the sphere SHALL expand.
     - ONLY data spots inside the field of view sphere SHALL be interactable by Genezis beings.

8. **Visual Feedback**
   - **User Story**: As a player, I want to see floating text when data is deposited so that I get immediate visual feedback on the amount collected.
   - **Acceptance Criteria**:
     - WHEN a Genezis being deposits data into the Core THEN the system SHALL spawn floating text at the point of deposition.
     - THE floating text SHALL display the amount of data deposited (formatted as bytes/KB/MB).
     - THE floating text SHALL move upwards slightly and fade out (bubble effect).

9. **Ultimate Goal: Escape**
   - **User Story**: As a player, I want a final objective so that I have a reason to reach the end of the evolution tree.
   - **Acceptance Criteria**:
     - WHEN all evolution phases are completed THEN the system SHALL allow the player to "escape the simulation" and win the game.