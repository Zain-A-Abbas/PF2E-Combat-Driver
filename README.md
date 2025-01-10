# A combat manager for PF2E

⚠ This software is not supported, endorsed, or approved by Paizo Inc, or any associated groups.

Combat Driver allows you to create and share individual combat encounters for the PF2E tabletop system while letting you comprehensively search and filter through a list of monsters and NPCs available for the game.
You are also able to create new enemy sheets, and customize pre-existing ones.

## Installation
The windows installation can be found on the [Itch.io](https://threedaysguy.itch.io/combat-driver) page. First time opening the software will take ~30 seconds, and then a normal amount of time thereafter. Binaries for other operating systems are not available yet, but they can be exported through Godot.

## Work In Progress
This project is not yet feature complete. The major features at time of writing:
* Searching through enemies.
* Filtering and sorting enemies in different conditions.
* Creation of custom enemies, both from scratch and through roadmaps to automatically allocate stats
* Modification of pre-existing enemies.
* Bundling up enemies as encounters, along with tracking the HP of the encounter.
* Saving and loading encounters in JSON format.
* Dice roller, and clicking on rolls on an enemy sheet to quickly do a D20 roll for that number.​
* Listing encounter strength based on party level/size.

Features that are to be added:
* Allowing for clicking on multi-element damage rolls to immediately roll them.
* Creating elite/weak enemy variants with the click of a button.
* State tracking.
* Printing sheets.
* Dark mode.

Known bugs:
* Enemies with multiple spell lists will have every spell be displayed on every spell list.
* In some rare cases, ability descriptions are not accurately displayed.

This project is created in Godot 4.3.

Enemy data is from: https://github.com/foundryvtt/pf2e


## Other
The user interface is in some areas inspired by [Kyle Olson's Combat Manager](http://combatmanager.com/) for the previous edition of the game.
For anyone compiling the program on their own, the "Data" folder from the src folder must be placed alongside the binary.

Custom enemies are in the following folders based on operating system:
* Windows: %APPDATA%\Combat Driver\Enemies\custom-enemies
* macOS: ~/Library/Application Support/Combat Driver\Enemies\custom-enemies​
* Linux: ~/.local/share/Combat Driver\Enemies\custom-enemies​


## Screenshots
![image](https://github.com/user-attachments/assets/d0908304-1e5a-49a2-aabc-afc83cd1d230)
![image](https://github.com/user-attachments/assets/f3f5b5a3-1918-4307-b9aa-c48e16584f05)


