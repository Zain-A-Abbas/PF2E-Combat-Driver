# A combat manager for PF2E

⚠ This software is not supported, endorsed, or approved by Paizo Inc, or any associated groups.

Combat Driver allows you to create and share individual combat encounters for the PF2E tabletop system while letting you comprehensivley search and filter through a list of monsters and NPCs available for the game.
You are also able to create new enemy sheets, and customize pre-existing ones.

## How To Use
In the current incomplete state, the project must be opened in Godot 4.3. An exported binary will be available when it is mostly complete.

## Work In Progress

This project is still in its early stages, and is thus incomplete for the time being. The major features that currently function:
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

## Screenshots
![image](https://github.com/user-attachments/assets/bdebaf4b-d99e-4323-b8bb-fc46a65628c1)
![image](https://github.com/user-attachments/assets/3b3a801c-80a0-4cc4-bf32-ecc8271d09b9)
