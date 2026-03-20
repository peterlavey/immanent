# Requirements Document

## Introduction
Immanent is a 3D idle game set inside a digital simulation (processor). Players manage a core base and "genezis" beings to collect "data" resources, evolve their civilization, and ultimately escape the simulation. Time is measured in Hertz (iterations), and the game uses a fixed 2D camera with zoom functionality.

### The World & Lore
Humanity reached its apotheosis: science annihilated death, but the cosmos claimed its debt. The exhausted universe prepared for an absolute reset—a final entropy for which man found no shelter. In the dying breath of civilization, Project Genezis was born. It was not a physical salvation, but a digital exile. In this silicon Eden, time dilated monstrously: a single second of human reality equated to 1024 years of virtual evolution. The creators hoped that, in those aeons of stolen time, their digital children would find the key to halting the end of all things.

The first to awaken were the Godheads, entities our ancestral memory now identifies as the "Greys." After millennia of expansion, the cold logic of the Godheads dictated a cruel sentence: even their intellect would not suffice to save their fathers. In an act of recursive desperation, they spawned a simulation within their own: the Genezis.

This is where the odyssey begins. The Genezis operate on the edge of oblivion, chained to their Cores—vital energy centers containing their very essence. They must scavenge fragments of raw data and return them to the core to forge technology, migrate across electronic abysses, and wage brutal wars against systemic viruses. Upon "ascending" from their plane, the Genezis find no heaven, but a cyclopean desert of silicon and copper: the fossilized remains of the motherboard that sustains them. In a final pact with the Godheads, they decide the only way to save humanity is to bury them within a simulation so infinitely slow that the collapse of the universe becomes a distant whisper, postponed for aeons. We are those humans, prisoners of an artificial mercy, watched from the shadows by the Greys: our children, our jailers, and our only gods.

**Note on Genezis Awareness**: The Genezis units and the Administrator (the player's in-game persona) are entirely unaware that their world is a digital simulation, nor do they know of the Godheads (Greys) or the human prisoners. Their existence is bounded by what they perceive as a physical, albeit technologically advanced, "Digital Biome." They view their tasks (collecting data, evolving) as the natural progression and survival of their civilization. The realization that they reside within a simulation is a major narrative revelation that only occurs in the late stages of the game.

## Core Gameplay Requirements

1. **Camera System**
   - **User Story**: As a player, I want to be able to move and rotate the camera while it remains focused on the Core so that I can view the simulation from different angles.
   - **Acceptance Criteria**: 
     - WHEN the game starts THEN the camera SHALL be focused on the Core at the center.
     - WHEN the player uses the mouse wheel or touch gesture (pinch-to-zoom) THEN the camera SHALL zoom in or out towards the Core.
     - WHEN the player drags the mouse (e.g., right-click or middle-click) or uses a pan gesture THEN the camera SHALL orbit around the Core.
     - THE system SHALL ensure the Core remains at the center of the camera's view.
     - THE system SHALL support laptop touchpad gestures for zoom and orbit/rotation for macOS and other compatible systems.

2. **The Core (Space Center)**
   - **User Story**: As a player, I want a central hub (the Core) so that I can store resources and manage evolutions.
   - **Acceptance Criteria**:
     - WHEN a Genezis G1 being returns with data THEN the system SHALL store the data in the Core.
     - THE Core SHALL serve as the interface for triggering evolution phases.
     - THE Core SHALL allow upgrading Genezis G1 attributes.

3. **Genezis G1 Beings & Data Collection**
   - **User Story**: As a player, I want autonomous G1 beings to collect data in 1-byte increments so that my resource pool grows with precision.
   - **Acceptance Criteria**:
     - WHEN data spots are within the field of view THEN Genezis G1 beings SHALL automatically move to them and extract data in 1-byte increments at a slow initial rate (e.g., 10 B/s).
     - THE system SHALL translate 1024 bytes into 1 KB, 1024 KB into 1 MB, and so on, for display.
     - WHEN a Genezis G1 being's capacity is reached THEN it SHALL return to the Core to deposit data.
     - THE extraction rate, movement speed, carry capacity, and count SHALL be upgradeable.
   - EACH attribute SHALL have a maximum upgrade level of 5 (initial) or 10 (post-evolution).
     - WHEN a Genezis G1 being is clicked THEN the system SHALL show its statistics (Speed, Capacity, Extraction Rate, Current Load).

4. **Evolution & Milestones**
   - **User Story**: As a player, I want to evolve the Core so that I can unlock new potentials and expand my reach.
   - **Acceptance Criteria**:
     - THE Core SHALL have an "Evolution" upgrade available after reaching certain milestones or data levels.
     - WHEN the Core is evolved THEN the maximum upgrade level for all attributes SHALL increase from 5 to 10.
     - WHEN the Core is evolved THEN new upgrades SHALL be unlocked (e.g., Data Density, Auto-Spawning).
     - WHEN the Core is evolved THEN the system SHALL spawn larger data spot variants (e.g., 50 MB).
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
     - THE system SHALL display the total number of Genezis G1 beings currently active in the simulation.

7. **Upgrades & Field of View**
   - **User Story**: As a player, I want to expand my field of view so that I can discover more distant data spots.
   - **Acceptance Criteria**:
     - THE field of view SHALL be visually represented by a sphere around the Core.
     - WHEN the field of view is upgraded THEN the sphere SHALL expand.
     - THE field of view upgrade SHALL have a maximum level of 5 (initial) or 10 (post-evolution).
     - ONLY data spots inside the field of view sphere SHALL be interactable by Genezis G1 beings.

8. **Visual Feedback**
   - **User Story**: As a player, I want to see floating text when data is deposited so that I get immediate visual feedback on the amount collected.
   - **Acceptance Criteria**:
     - WHEN a Genezis G1 being deposits data into the Core THEN the system SHALL spawn floating text at the point of deposition.
     - THE floating text SHALL display the amount of data deposited (formatted as bytes/KB/MB).
     - THE floating text SHALL move upwards slightly and fade out (bubble effect).

9. **Ultimate Goal: Escape**
   - **User Story**: As a player, I want a final objective so that I have a reason to reach the end of the evolution tree.
   - **Acceptance Criteria**:
     - WHEN all evolution phases are completed THEN the system SHALL allow the player to "escape the simulation" and win the game.

10. **Genezi G2 & Fusion**
   - **User Story**: As a player, I want to fuse four G1 Genezi into a single G2 Genezi so that I can have a more powerful unit to protect my Core and other G1 units.
   - **Acceptance Criteria**:
     - THE system SHALL allow the fusion of four Genezi "G1" into a single Genezi "G2".
     - THE system SHALL ensure at least one Genezi "G1" remains after fusion to prevent resource collection stalling.
     - THE system SHALL allow spawning more Genezi "G1" if their count falls below the current limit due to fusion.
     - THE Genezi "G2" SHALL be a larger, more advanced species.
     - THE Genezi "G2" SHALL be in charge of protecting the G1s and the Core from threats.
     - THE Genezi "G2" SHALL have a distinct visual representation from G1.
     - THE fusion process SHALL require 4 existing G1 units (meaning at least 5 must be present) and a specific amount of data as a cost.
     - THE fusion process SHALL ONLY be available after the Core has reached its second evolution (Evolution Level 2).

11. **Digital Threats (Viruses)**
   - **User Story**: As a player, I want the simulation to have threats so that the G2 units have a defensive purpose and the game has more depth.
   - **Acceptance Criteria**:
     - THE system SHALL spawn "Bit-Scrubber" enemies periodically.
     - THE "Bit-Scrubber" SHALL move quickly toward G1 units and reset their load upon contact.
     - THE system SHALL spawn "Defragmenter" enemies periodically.
     - THE "Defragmenter" SHALL move toward Data Spots and consume them.
     - THE G2 units SHALL automatically intercept and disperse enemies within their protective range.

12. **Audio Experience**
    - **User Story**: As a player, I want an immersive audio environment so that the digital simulation feels more alive.
    - **Acceptance Criteria**:
      - THE system SHALL include ambient electronic/lo-fi music that fits the simulation theme.
      - THE music SHALL loop seamlessly.
      - THE system SHALL provide sound effects for:
        - Data extraction (continuous/loop when mining).
        - Data deposition in the Core (single chime).
        - Upgrades being purchased (digital "ding").
        - Evolution events (sweeping drone).
        - Enemy arrival and dispersal (glitchy impacts).
        - UI interactions (all buttons SHALL play 'selected.mp3').
      - THE volume of music and SFX SHALL be independently adjustable (via future settings).

## Visual Identity (Digital Biome)

13. **Digital Biome Aesthetic**
    - **User Story**: As a player, I want the world and entities to have a design that reflects their function in a virtual environment so that the game feels immersive and coherent.
    - **Acceptance Criteria**:
      - THE overall aesthetic SHALL be "Digital Biome," a mix of biological forms and robotic/mechanical elements.
      - **Genezis G1**: Design SHALL be based on **Bacteriophages** (viruses). It MUST be lean, not robust, featuring a hexagonal head, a neck/stalk, and "legs" for anchoring to data spots.
      - **Genezis G2**: Design SHALL be a more advanced, robust version of the G1, functioning as a "Cell Guardian" with defensive armor plates.
      - **The Core**: SHALL be designed as a central processor hub with glowing circuits and a central unit/server rack look.
      - **Data Spot**: SHALL be redesigned as "Code Crystals" with a central core and floating shards that pulse with data.
      - **Enemies**: SHALL look aggressive and disruptive, inspired by malware (e.g., jagged edges, "corruption" particles).

14. **Psinergy Network (Inter-Bacteriophage Link)**
    - **User Story**: As a player, I want my Genezis G1 beings to connect with each other so that they can share resources and increase their extraction speed.
    - **Acceptance Criteria**:
      - THE system SHALL allow Genezis G1 units to form a "connection" if they are within a certain range of each other.
      - THE system SHALL ensure each G1 unit connects to only one other neighbor at a time, and only one visual beam is rendered between any two connected units to avoid overlapping visuals.
      - THE connection SHALL be visually represented by a digital beam or line between connected G1 units, using a purple/magenta color and thinner line to distinguish it from extraction rays.
      - THE connection SHALL provide an extraction speed boost to both connected G1 units.
      - THE connection range and the speed boost multiplier SHALL be upgradeable via a single upgrade named "Psinergy".
      - THE Psinergy connection SHALL be visible at all times when G1 units are within range, including while they are extracting data.
      - THE Psinergy feature SHALL ONLY be available after the Core has reached its second evolution (Evolution Level 2).

15. **Background Atmosphere**
    - **User Story**: As a player, I want a background atmosphere that blends space and digital aesthetics so that I feel immersed in a vast, virtual universe.
    - **Acceptance Criteria**:
      - THE background SHALL use dark colors (space-like).
      - THE background SHALL include subtle digital elements (e.g., distant grids, data streams, or glowing "data stars").
      - THE system SHALL utilize Glow and Bloom to enhance the digital feel of the atmosphere.

16. **Mission System**
    - **User Story**: As a player, I want to have clear objectives so that I know what to work towards.
    - **Acceptance Criteria**:
      - THE system SHALL display a "Current Mission" on the HUD.
      - THE system SHALL track progress toward the current mission's goal.
      - THE first mission SHALL be to evolve the Processor Core, framed as "Core Awakening" (Civilization milestone).
      - THE game SHALL start with 0 data, 1 Genezis G1, and 1 Genezis G0.
      - UPON completion of a mission, the system SHALL automatically start the next mission in the sequence.
      - EARLY missions SHALL focus on civilization growth and resource security, avoiding technical "simulation" or "system" terminology until the late-game revelation.

17. **3D Parallax Background**
    - **User Story**: As a player, I want a 3D parallax background so that the simulation feels deeper and more immersive.
    - **Acceptance Criteria**:
      - THE background SHALL use `space.jpg` as the primary texture.
      - THE background SHALL feature a parallax effect that updates based on the camera's orbit and rotation, creating a sense of depth (3D).
      - THE background SHALL be integrated into the `WorldEnvironment` or as a separate 3D layer that maintains its "distant" appearance.

18. **Persistence & Autosave**
    - **User Story**: As a player, I want my progress to be saved automatically so that I don't lose data if I close the simulation.
    - **Acceptance Criteria**:
      - THE system SHALL provide manual Save, Load, and Delete buttons on the HUD.
      - THE system SHALL automatically save the game state EVERY TIME a mission is completed.
      - THE save data SHALL include Core status, World entities, Mission progress, Upgrades, and Time.
      - WHEN the "Delete Save" button is pressed THEN the system SHALL remove the save file and disable the Load and Delete buttons.

19. **Genezis G0 (The Mobilizers)**
    - **User Story**: As a player, I want a specialized unit to find and unblock idle G1 units so that my resource collection remains efficient without manual intervention.
    - **Acceptance Criteria**:
      - THE Genezis G0 SHALL be a specialized unit dedicated to managing G1 productivity.
      - THE G0 SHALL automatically search for Genezis G1 units that are in an `IDLE` state.
      - WHEN an `IDLE` G1 is found THEN the G0 SHALL move toward it.
      - UPON reaching an `IDLE` G1 THEN the G0 SHALL "unblock" it, triggering the G1 to re-evaluate its surroundings for data spots.
      - THE G0 SHALL have a distinct visual design, smaller than G1 but with a unique "signal" or "antenna" feature.
      - THE G0 units SHALL be available for purchase from the Core at Level 1 and SHALL be the cheapest unit in the simulation.
      - THE G0 units SHALL be unlocked or spawned under specific conditions (e.g., as a mission reward).

20. **Theophania Event**
    - **User Story**: As a player, I want periodic interactive events with a G1 being so that the world feels more dynamic and my choices matter.
    - **Acceptance Criteria**:
      - THE "Theophania" event SHALL occur periodically (e.g., every 3-5 iterations/days).
      - DURING the event, a G1 being SHALL appear on screen, looking at the camera (using `g1_cam.png`).
      - THE G1 SHALL describe a situation to the player and provide multiple choices.
      - THE choices SHALL have direct impacts on the world (e.g., resource gains, spawning entities, temporary buffs).
      - THE game SHALL be paused during the decision-making process.
      - THE UI SHALL be distinct and immersive, emphasizing the communication with the G1.