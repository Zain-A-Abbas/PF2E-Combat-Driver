# A combat manager for PF2E

⚠ This software is not supported, endorsed, or approved by Paizo Inc, or any associated groups.

Combat Driver allows you to create and share individual combat encounters for the PF2E tabletop system while letting you comprehensivley search and filter through a list of monsters and NPCs available for the game.
You are also able to create new enemy sheets, and customize pre-existing ones.

## Installation
The windows installation can be found on the release page. First time opening the software will take ~30 seconds, and then a normal amount of time thereafter. Binaries for other operating systems are not available yet, but they can be exported through Godot.

## Work In Progress
This project is not yet feature complete. The major features at time of writing:
* Searching through enemies
* Filtering and sorting enemies in different conditions
* Creation of custom enemies, both from scratch and through roadmaps to automatically allocate stats
* Modification of pre-existing enemies
* Bundling up enemies as encounters, along with tracking HP
* Saving and loading encounters
* Dice roller + Clicking on rolls on an enemy sheet to quickly do a D20 roll for that number
* Listing encounter strength based on party level/size

Features that are to be added:
* Allowing for clicking on multi-element damage rolls to immediately roll them
* Creating elite/weak enemy variants with the click of a button
* State tracking

Known bugs:
* Enemies with multiple spell lists will have every spell be displayed on every spell list.
* In some rare cases, ability descriptions are not accurately displayed.

This project is created in Godot 4.3.

Enemy data is from: https://github.com/foundryvtt/pf2e


## Other
The user interface is in some areas inspired by [Kyle Olson's Combat Manager](http://combatmanager.com/) for the previous edition of the game.
For anyone compiling the program on their own, the "Data" folder from the src folder must be placed alongside the binary.

Custom enemies are in the following folders based on operating system:
* Windows: %APPDATA%\Godot\app_userdata\[project_name]
* macOS: ~/Library/Application Support/Godot/app_userdata/[project_name]
* Linux: ~/.local/share/godot/app_userdata/[project_name]


## Screenshots
![image](https://github.com/user-attachments/assets/bdebaf4b-d99e-4323-b8bb-fc46a65628c1)
![image](https://github.com/user-attachments/assets/3b3a801c-80a0-4cc4-bf32-ecc8271d09b9)
