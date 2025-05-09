extends Control

# Info template is the box in the combat list that allows you to interact  with an individual enemy instance
const ENEMY_INFO_TEMPLATE = preload("res://Combat/EnemyInfoTemplate.tscn")
# Initiative is an enemy on the initiative
const ENEMY_INITIATIVE = preload("res://Combat/EnemyInitiative.tscn")

@onready var enemies: VBoxContainer = %Enemies
@onready var enemy_sheet: Sheet = %EnemySheet
@onready var initiative_container: VBoxContainer = %InitiativeContainer

# Encouter strength
@onready var encounter_strength_label: Label = %EncounterStrengthLabel
@onready var level_spinbox: SpinBox = %LevelSpinbox
@onready var player_count_spinbox: SpinBox = %PlayerCountSpinbox

func _ready():
	EventBus.encounter_save_directory_chosen.connect(save_validated)
	EventBus.encounter_load_directory_chosen.connect(load_validated)
	print(ProjectSettings.globalize_path("user://enemies"))

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
	new_initiative_count.initiative_changed.connect(sort_initiative)
	new_initiative_count.setup_initiative(enemy)
	new_initiative_count.enemy_node = enemy
	
	enemy.deleted_enemy.connect(remove_enemy)
	enemy.renamed_enemy.connect(update_initiative_name)
	enemy.reordered_enemy.connect(check_reorder_buttons)
	
	sort_initiative()
	
	update_encounter_strength()

func check_reorder_buttons():
	for child in enemies.get_children():
		if child is EnemyInfoTemplate:
			child.verify_buttons()

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
	var new_enemy_name: String = new_enemy.enemy_name
	var enemy_names: Array[String] = []
	
	for preexisting_enemy in enemies.get_children():
		if preexisting_enemy != new_enemy:
			#new_enemy.name_bar.text += "+"
			#new_enemy.enemy_name += "+"
			enemy_names.append(preexisting_enemy.enemy_name)
	
	var same_name_count: int = 0
	while (enemy_names.has(new_enemy_name)):
		# 65 because that is when "A" starts
		new_enemy_name = new_enemy.enemy_name + " " + OS.get_keycode_string(65 + same_name_count)
		same_name_count += 1
	new_enemy.enemy_name = new_enemy_name
	new_enemy.name_bar.text = new_enemy_name

# Runs when you highlight an enemy to view its sheet
func view_enemy_sheet(enemy_data, enemy_name: String):
	enemy_sheet.setup(enemy_data, {"custom_name": enemy_name})

# When an enemy is removed
func remove_enemy(enemy: Node):
	for child in initiative_container.get_children():
		if child.enemy_node == enemy:
			child.queue_free()
	enemy.queue_free()

# Saving and loading

func save_encounter():
	if enemies.get_child_count() == 0:
		EventBus.error_popup.emit("Cannot save empty encounter.")
		return
	
	SaveDialog.choose_save_directory()

func save_validated(path: String):
	var save_file_location: String = path
	var save_data := EncounterFile.new()
	var file_save = FileAccess.open(save_file_location, FileAccess.WRITE)
	
	var i: int = 0
	for child in enemies.get_children():
		var enemy_combat_data = child.create_combat_file()
		var enemy_dict_entry: String = "enemy" + str(i)
		save_data.enemies[enemy_dict_entry] = enemy_combat_data
		i += 1
	
	save_data.party_count = int(player_count_spinbox.value)
	save_data.party_level = int(level_spinbox.value)
	
	file_save.store_var(save_data.enemies)
	file_save.store_64(save_data.party_count)
	file_save.store_64(save_data.party_level)
	file_save.close()

# Loads an encounter file
func open_encounter():
	LoadDialog.choose_load_directory()

func load_validated(path: String):
	# Prompts the user for where the file is, then opens and reads the file
	var load_file_location: String = path
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
	
	player_count_spinbox.value = load_file.get_64()
	level_spinbox.value = load_file.get_64()

func update_encounter_strength():
	var party_count: int = int(player_count_spinbox.value)
	var party_level: int = int(level_spinbox.value)
	var exp_obtained: int = 0
	for enemy in enemies.get_children():
		if enemy is EnemyInfoTemplate:
			if enemy.enemy_data != {}:
				var enemy_level: int = enemy.enemy_data["system"]["details"]["level"]["value"]
				if enemy_level <= party_level - 6:
					exp_obtained += 1
				elif enemy_level == party_level - 5:
					exp_obtained += 5
				elif enemy_level == party_level - 4:
					exp_obtained += 10
				elif enemy_level == party_level - 3:
					exp_obtained += 15
				elif enemy_level == party_level - 2:
					exp_obtained += 20
				elif enemy_level == party_level - 1:
					exp_obtained += 30
				elif enemy_level == party_level:
					exp_obtained += 40
				elif enemy_level == party_level + 1:
					exp_obtained += 60
				elif enemy_level == party_level + 2:
					exp_obtained += 80
				elif enemy_level == party_level + 3:
					exp_obtained += 120
				elif enemy_level >= party_level + 4:
					exp_obtained += 160
	
	#var trivial: int = 40 + (10 * (party_count) - 4)
	var low: int = 60 + (20 * (party_count - 4))
	var moderate: int = 80 + (20 * (party_count - 4))
	var severe: int = 120 + (30 * (party_count - 4))
	var extreme: int = 160 + (40 * (party_count - 4))
	
	var encounter_level: String
	
	if exp_obtained < low:
		encounter_level = "Trivial"
	elif exp_obtained < moderate:
		encounter_level = "Low"
	elif exp_obtained < severe:
		encounter_level = "Moderate"
	elif exp_obtained < extreme:
		encounter_level = "Severe"
	else:
		encounter_level = "Extreme"
	
	encounter_strength_label.text = encounter_level


# SIGNALS

func _on_reroll_initiative_button_pressed():
	if initiative_container.get_child_count() == 0:
		return
	for child in initiative_container.get_children():
		if child is EnemyInitiative:
			child.setup_initiative(null)
	sort_initiative()


func _on_copy_initiative_button_pressed():
	if initiative_container.get_child_count() == 0:
		return
	var initiative_copy_text: String = ""
	for child in initiative_container.get_children():
		initiative_copy_text += child.enemy_name.text + " - " + str(child.initiative) + "\n"
	DisplayServer.clipboard_set(initiative_copy_text)


func _on_encounter_tracker_tab_changed(_tab):
	#print("tab changed to " + str(tab))
	pass


func _on_encounter_spinboxes_changed(_value: float) -> void:
	update_encounter_strength()
