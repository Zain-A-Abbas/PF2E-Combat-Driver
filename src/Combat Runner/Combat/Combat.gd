extends Control

# Info template is the box in the combat list that allows you to interact  with an individual enemy instance
const ENEMY_INFO_TEMPLATE = preload("res://Combat/EnemyInfoTemplate.tscn")
# Initiative is an enemy on the initiative
const ENEMY_INITIATIVE = preload("res://Combat/EnemyInitiative.tscn")

@onready var enemies: VBoxContainer = %Enemies
@onready var enemy_sheet: Sheet = %EnemySheet
@onready var initiative_container: VBoxContainer = %InitiativeContainer

func _ready():
	EventBus.encounter_save_directory_chosen.connect(save_validated)
	EventBus.encounter_load_directory_chosen.connect(load_validated)

# Adding an enemy from a pre-existing sheet
func add_enemy_from_sheet(enemy_data: Dictionary):
	# Creates an info template
	var new_sheet_enemy = ENEMY_INFO_TEMPLATE.instantiate()
	enemies.add_child(new_sheet_enemy)
	
	# Initializes encounter data
	var enemy_combat_data = EnemyEncounterData.new()
	enemy_combat_data.initialize(enemy_data)
	
	# Uses that encounter data to fill up the info template
	new_sheet_enemy.setup_enemy(enemy_combat_data)
	new_sheet_enemy.viewing_enemy.connect(view_enemy_sheet)
	add_enemy_to_initiative(new_sheet_enemy)

# Creates a new initiative count, adds it to the initiative container, then sets it to an enemy sheet and node
func add_enemy_to_initiative(enemy):
	# Goes through every enemy, and makes sure their names are unique before adding to initiative
	check_names()
	
	# Creates an initiative object
	var new_initiative_count = ENEMY_INITIATIVE.instantiate()
	# Adds it to the initiative list, sets it up
	initiative_container.add_child(new_initiative_count)
	new_initiative_count.setup_initiative(enemy)
	new_initiative_count.enemy_node = enemy
	
	enemy.deleted_enemy.connect(remove_enemy)
	enemy.renamed_enemy.connect(update_initiative_name)
	
	sort_initiative()

# Sorts Initiative
func sort_initiative():
	var initiatives = initiative_container.get_children()
	initiatives.sort_custom(sort_initiative_nodes)
	var i: int = 0
	for initiative_node in initiatives:
		initiative_container.move_child(initiative_node, i)
		i += 1

static func sort_initiative_nodes(a, b):
	return a.initiative > b.initiative

func update_initiative_name(enemy, new_name: String):
	for child in initiative_container.get_children():
		if child.enemy_node == enemy:
			child.rename_enemy(new_name)

# Ensures that every name in the combat is unique when creating an enemy instance
func check_names():
	var new_enemy = enemies.get_child(-1)
	for preexisting_enemy in enemies.get_children():
		if preexisting_enemy != new_enemy && new_enemy.enemy_name == preexisting_enemy.enemy_name:
			new_enemy.name_bar.text += "+"
			new_enemy.enemy_name += "+"

# Runs when you highlight an enemy to view its sheet
func view_enemy_sheet(enemy_data):
	enemy_sheet.setup(enemy_data)

# When an enemy is removed
func remove_enemy(enemy: Node):
	for child in initiative_container.get_children():
		if child.enemy_node == enemy:
			child.queue_free()
	enemy.queue_free()

# Saving and loading

func save_encounter():
	if enemies.get_child_count() == 0:
		return
	SaveDialog.choose_save_directory()

func save_validated():
	var save_file_location = SaveDialog.current_path
	var save_data := EncounterFile.new()
	var file_save = FileAccess.open(save_file_location, FileAccess.WRITE)
	
	var i: int = 0
	for child in enemies.get_children():
		var enemy_combat_data = child.create_combat_file()
		var enemy_dict_entry: String = "enemy" + str(i)
		save_data.enemies[enemy_dict_entry] = enemy_combat_data
		i += 1
	
	file_save.store_var(save_data.enemies)
	file_save.close()

# Loads an encounter file
func open_encounter():
	LoadDialog.choose_load_directory()

func load_validated():
	# Prompts the user for where the file is, then opens and reads the file
	var load_file_location = LoadDialog.current_path
	var load_file := FileAccess.open(load_file_location, FileAccess.READ)
	var encounter_data = load_file.get_var(true)
	
	# For each enemy, create new encounter data and an info template, add the info template to enemies
		# then fill the info template with info and pass it to the initiative
	for enemy in encounter_data.values():
		var new_encounter_data = EnemyEncounterData.new()
		var loaded_enemy = ENEMY_INFO_TEMPLATE.instantiate()
		enemies.add_child(loaded_enemy)
		loaded_enemy.setup_enemy(new_encounter_data.initialize_from_save_data(enemy))
		loaded_enemy.viewing_enemy.connect(view_enemy_sheet)
		add_enemy_to_initiative(loaded_enemy)

# SIGNALS

func _on_reroll_initiative_button_pressed():
	if initiative_container.get_child_count() == 0:
		return
	for child in initiative_container.get_children():
		child.reroll_initiative()
	sort_initiative()


func _on_copy_initiative_button_pressed():
	if initiative_container.get_child_count() == 0:
		return
	var initiative_copy_text: String = ""
	for child in initiative_container.get_children():
		initiative_copy_text += child.enemy_name.text + " - " + str(child.initiative) + "\n"
	DisplayServer.clipboard_set(initiative_copy_text)


func _on_encounter_tracker_tab_changed(tab):
	#print("tab changed to " + str(tab))
	pass
