extends Control

enum SORT_MODE {
	ALPHABETICAL,
	LEVEL,
	ALPHABETICAL_REVERSE,
	LEVEL_REVERSE
}

const ENEMY_DATABASE = "res://Data/Enemies/"
const EnemyDatabaseSourceFile: String = "res://Database/EnemyDatabase.cs"

@onready var enemy_list: ItemList = %EnemyList
@onready var enemy_sheet: Sheet = %EnemySheet

@onready var sort_by_name_button: Button = %SortByNameButton
@onready var sort_by_level_button: Button = %SortByLevelButton
@onready var edit_enemy_button: Button = %EditEnemyButton
@onready var delete_enemy_button: Button = %DeleteEnemyButton

# The filter menus; the filtering traits and numbers are retrieved directly from them
@onready var size_filter_menu: FilteringMenu = %SizeFilterMenu
@onready var rarity_filter_menu: FilteringMenu = %RarityFilterMenu
@onready var trait_filter_menu: PanelContainer = %TraitFilterMenu
@onready var numbers_filtering: PanelContainer = %NumbersFiltering
@onready var source_filtering: PanelContainer = %SourceFiltering

@onready var search_bar: LineEdit = %SearchBar
@onready var enemy_creator = %EnemyCreator
@onready var enemy_creator_window: Window = %EnemyCreatorWindow

signal add_enemy(enemy_data)

# CSharp database loader
var csharp_database: Node

# Holds all enemy data
var enemies: Array[Node]
# Currently selceted enemy
var enemy_index: int

# Holds enemies that have been filtered and sorted
var filtered_sorted_enemies: Array[Node] = enemies
var sorting_mode: SORT_MODE = SORT_MODE.ALPHABETICAL : set = set_sorting
func set_sorting(val):
	if sorting_mode == val:
		return
	sorting_mode = val
	sort_filter_enemies()

# Called when the node enters the scene tree for the first time.
func _ready():
	var enemy_database = load(EnemyDatabaseSourceFile)
	csharp_database = enemy_database.new() 
	add_enemies()
	enemy_list.select(0)
	_on_enemy_list_item_selected(0)


# Adds enemies to the enemies array
func add_enemies():
	enemies.clear()
	
	# Open the enemy database folder
	# Search through every subfolder, as enemies are placed into fodlers corresponding to rulebook source
	var start_time: float = Time.get_ticks_msec()
	'for subfolder in directory.get_directories():
		var bestiary_folder := DirAccess.open(ENEMY_DATABASE + subfolder)
		for file in bestiary_folder.get_files():
			# Take their file location, use it to create an enemy file and then parse it as text to enemies vairable
			var enemy_file_location := ENEMY_DATABASE + subfolder + "/" + file
			var enemy_file = FileAccess.open(enemy_file_location, FileAccess.READ)
			var json_conversion = JSON.new()
			json_conversion.parse(enemy_file.get_as_text())
			var enemy_data = json_conversion.get_data()
			if enemy_data["type"] != "npc":
				continue
			var enemy_filter_data = EnemyFilterData.new()
			enemy_filter_data.initialize(enemy_data, enemy_file_location)
			enemies.append(enemy_filter_data)'
	var temp_enemies: Array = csharp_database.addEnemies()
	for enemy in temp_enemies:
		enemies.append(enemy)
	if !enemies.is_empty():
		source_filtering.setup(enemies[0].getSources())
	print("Time: " + str((Time.get_ticks_msec() - start_time) / 1000.0))
	sort_filter_enemies()
	
# Filters enemies, sorts them, then makes them visible
func sort_filter_enemies():
	enemy_list.clear()
	
	filtered_sorted_enemies = enemies
	
	filtered_sorted_enemies = filter_enemies(filtered_sorted_enemies)
	
	match sorting_mode:
		SORT_MODE.ALPHABETICAL:
			filtered_sorted_enemies.sort_custom(sort_alphabetic)
		SORT_MODE.LEVEL:
			filtered_sorted_enemies.sort_custom(sort_level)
		SORT_MODE.ALPHABETICAL_REVERSE:
			filtered_sorted_enemies.sort_custom(sort_alphabetic_reverse)
		SORT_MODE.LEVEL_REVERSE:
			filtered_sorted_enemies.sort_custom(sort_level_reverse)
	
	for i in filtered_sorted_enemies.size():
		enemy_list.add_item(filtered_sorted_enemies[i].enemyName)
		enemy_list.set_item_tooltip_enabled(i, false)

static func sort_alphabetic(enemy_a: Node, enemy_b: Node):
	return enemy_a.enemyName < enemy_b.enemyName

static func sort_level(enemy_a: Node, enemy_b: Node):
	return enemy_a.level < enemy_b.level

static func sort_alphabetic_reverse(enemy_a: Node, enemy_b: Node):
	return enemy_a.enemyName > enemy_b.enemyName

static func sort_level_reverse(enemy_a: Node, enemy_b: Node):
	return enemy_a.level > enemy_b.level


# Filters

func filter_enemies(enemies_to_filter: Array[Node]) -> Array[Node]:
	var filtering := enemies_to_filter.duplicate()
	filtering = name_filter(filtering, search_bar.text)
	filtering = general_filter(filtering, "rarity")
	filtering = general_filter(filtering, "size")
	filtering = general_filter(filtering, "traits")
	filtering = general_filter(filtering, "sources")
	filtering = number_filter(filtering)
	return filtering

func name_filter( enemies_to_filter: Array[Node], search_name: String ) -> Array[Node]:
	
	if search_name == "":
		return enemies_to_filter
	
	# Enemies to include
	var include_enemies: Array[Node] = []
	
	for enemy in enemies_to_filter:
		if enemy.enemyName.to_lower().contains(search_name.to_lower()):
			include_enemies.append(enemy)
	
	return include_enemies
	
func outOfBounds(value: int, f: NumberFilterData):
	return !(value >= f.lower_bound && value <= f.upper_bound)
	

func number_filter( enemies_to_filter: Array[Node] ) -> Array[Node]:
	var filterData : Array[NumberFilterData] = numbers_filtering.get_number_filter_data()
	var validEnemies : Array[Node] = enemies_to_filter
	for filter: NumberFilterData in filterData:
		if filter.lower_bound == 0 && filter.upper_bound == 0:
			continue
		print(filter.text)
		var validEnemiesSize : int = validEnemies.size()-1
		for i in range(validEnemiesSize, -1, -1):
			match filter.text:
				"Level":
					if outOfBounds(validEnemies[i].level, filter):
						validEnemies.remove_at(i)
				"HP":
					if outOfBounds(validEnemies[i].hp, filter):
						validEnemies.remove_at(i)
				"AC":
					if outOfBounds(validEnemies[i].ac, filter):
						validEnemies.remove_at(i)
				"Fortitude Save":
					if outOfBounds(validEnemies[i].saves["fortitude"], filter):
						validEnemies.remove_at(i)
				"Reflex Save":
					if outOfBounds(validEnemies[i].saves["reflex"], filter):
						validEnemies.remove_at(i)
				"Will Save":
					if outOfBounds(validEnemies[i].saves["will"], filter):
						validEnemies.remove_at(i)
				"Perception":
					if outOfBounds(validEnemies[i].perception, filter):
						validEnemies.remove_at(i)
				"Score":
					var score: String
					match filter.dropdown_option:
						0:
							score = "str"
						1:
							score = "dex"
						2:
							score = "con"
						3:
							score = "int"
						4:
							score = "wis"
						5:
							score = "cha"
					if outOfBounds(validEnemies[i].abilityScores[score], filter):
						validEnemies.remove_at(i)
				"Speed":
					var speed_type: String = NumberFilteringOption.SPEEDS[filter.dropdown_option].to_lower()
					if !validEnemies[i].speed.has(speed_type):
						validEnemies.remove_at(i)
					elif outOfBounds(int(validEnemies[i].speed[speed_type]), filter):
						validEnemies.remove_at(i)
				"Resistance":
					if filter.dropdown_option == 0:
						continue
					var resistance_type: String = NumberFilteringOption.ELEMENTS[filter.dropdown_option].to_lower()
					resistance_type = resistance_type.to_lower().replace(" ", "-")
					if !validEnemies[i].resistances.has(resistance_type):
						validEnemies.remove_at(i)
					elif outOfBounds(int(validEnemies[i].resistances[resistance_type]), filter):
						validEnemies.remove_at(i)
				"Weakness":
					if filter.dropdown_option == 0:
						continue
					var weakness_type: String = NumberFilteringOption.ELEMENTS[filter.dropdown_option]
					weakness_type = weakness_type.to_lower().replace(" ", "-")
					if !validEnemies[i].weaknesses.has(weakness_type):
						validEnemies.remove_at(i)
					elif outOfBounds(int(validEnemies[i].weaknesses[weakness_type]), filter):
						validEnemies.remove_at(i)
				"Immunity":
					if filter.dropdown_option == 0:
						continue
					var immunity_type: String = NumberFilteringOption.ELEMENTS[filter.dropdown_option].to_lower()
					immunity_type = immunity_type.to_lower().replace(" ", "-")
					if !validEnemies[i].immunities.has(immunity_type):
						validEnemies.remove_at(i)
	return validEnemies

# Sorts by rarity, traits and size; They share a function because of how similar they are
func general_filter( enemies_to_filter: Array[Node], rarity_size_traits: String ) -> Array[Node]:
	
	
	# Enemies to include and enemies to remove
	var include_enemies: Array[Node] = []
	var remove_enemies: Array[Node] = []
	
	# Don't search through the same trait multiple times
	var searched_traits: Array[String] = []
	
	# Holds the filters; assigned to the size, rarity, or trait filter menus
	var current_filter_menu
	
	# Assigns the container to compare for filtering
	match rarity_size_traits:
		"rarity":
			current_filter_menu  = rarity_filter_menu
		"size":
			current_filter_menu = size_filter_menu
		"traits":
			current_filter_menu = trait_filter_menu
		"sources":
			current_filter_menu = source_filtering
	
	
	# If no filters are interacted with in the corresponding filter menu, then do not even iterate through the enemies
	if current_filter_menu.has_no_filters():
		return enemies_to_filter
	
	# Goes through every enemy, stacks them up to the filter
	for enemy in enemies_to_filter:
		searched_traits = []
		
		for filter_button in current_filter_menu.filter_container:
			if rarity_size_traits == "traits":
				if searched_traits.has(filter_button.trait_name):
					continue
				searched_traits.append(filter_button.trait_name)
			
			# The value that is being compared between the enemy filter data and the filter node
			var comparison_value: Variant
			
			# Assigns the variable to compare for filtering
			match rarity_size_traits:
				"rarity":
					comparison_value  = enemy.rarity
				"size":
					comparison_value = enemy.size
				"traits":
					comparison_value = enemy.traits
				"sources":
					comparison_value = enemy.source
			
			if rarity_size_traits == "traits":
				for enemy_trait in comparison_value:
					# Lowercases what is compared so no case disrepancies occur
					if enemy_trait.to_lower() == filter_button.trait_name.to_lower():
						if filter_button.filter_state == FilterButton.FilterState.INCLUDE:
							include_enemies.append(enemy)
						elif filter_button.filter_state == FilterButton.FilterState.EXCLUDE:
							remove_enemies.append(enemy)
				if trait_filter_menu.include_and_or && filter_button.filter_state == FilterButton.FilterState.INCLUDE:
					if !comparison_value.has(filter_button.trait_name.to_lower()):
						if !remove_enemies.has(enemy):
							remove_enemies.append(enemy)
			else: 
				if comparison_value.to_lower() == filter_button.trait_name.to_lower():
					if filter_button.filter_state == FilterButton.FilterState.INCLUDE:
						include_enemies.append(enemy)
					elif filter_button.filter_state == FilterButton.FilterState.EXCLUDE:
						remove_enemies.append(enemy)
	
	# If there are any enemies ticked to include at all, just return all the ones who are not set to be excluded
	if !include_enemies.is_empty():
		var final_enemies: Array[Node] = []
		for enemy in include_enemies:
			if !remove_enemies.has(enemy):
				final_enemies.append(enemy)
		return final_enemies
	
	# If no enemies are set to include, then just add every enemy not excluded
	if !remove_enemies.is_empty():
		var final_enemies: Array[Node] = []
		for enemy in enemies_to_filter:
			if !remove_enemies.has(enemy):
				final_enemies.append(enemy)
		return final_enemies
	
	return enemies_to_filter

func new_enemy(editing: bool):
	enemy_creator.editing = editing
	enemy_creator.name_field.line_edit.editable = !editing
	enemy_creator_window.show()

# Signals

func _on_enemy_list_item_selected(index):
	enemy_index = index
	var enemy_file = FileAccess.open(filtered_sorted_enemies[enemy_index].fileReference, FileAccess.READ)
	var json_conversion = JSON.new()
	json_conversion.parse(enemy_file.get_as_text())
	var enemy_data = json_conversion.get_data()
	
	delete_enemy_button.visible = false
	edit_enemy_button.visible = false
	if enemy_data.has("custom_enemy"):
		if enemy_data["custom_enemy"]:
			delete_enemy_button.visible = true
			edit_enemy_button.visible = true
	enemy_sheet.setup(enemy_data)


func _on_sort_by_name_pressed():
	if sorting_mode == SORT_MODE.ALPHABETICAL:
		sorting_mode = SORT_MODE.ALPHABETICAL_REVERSE
	else:
		sorting_mode = SORT_MODE.ALPHABETICAL

func _on_sort_by_level_pressed():
	if sorting_mode == SORT_MODE.LEVEL:
		sorting_mode = SORT_MODE.LEVEL_REVERSE
	else:
		sorting_mode = SORT_MODE.LEVEL



## Filter buttons

func _on_size_filter_button_pressed():
	size_filter_menu.visible = !size_filter_menu.visible

func _on_size_filter_menu_apply_filter():
	size_filter_menu.visible = false
	#$Database/MarginContainer/SortingFiltering/SizeFilterButton.button_pushed()
	sort_filter_enemies()


func _on_rarity_filter_button_pressed():
	rarity_filter_menu.visible = !rarity_filter_menu.visible

func _on_rarity_filter_menu_apply_filter():
	rarity_filter_menu.visible = false
	#$Database/MarginContainer/SortingFiltering/RarityFilterButton.button_pushed()
	sort_filter_enemies()


func _on_traits_filter_button_pressed():
	trait_filter_menu.visible = !trait_filter_menu.visible

func _on_trait_filter_menu_apply_filter():
	trait_filter_menu.visible = false
	sort_filter_enemies()

func _on_numbers_filtering_apply_filter():
	numbers_filtering.visible = false
	sort_filter_enemies()

func _on_search_bar_text_changed(_new_text):
	sort_filter_enemies()

func _on_source_filtering_apply_filter() -> void:
	source_filtering.visible = false
	sort_filter_enemies()

func _on_numbers_filter_button_pressed():
	numbers_filtering.visible = !numbers_filtering.visible

func _on_sources_filter_button_pressed() -> void:
	source_filtering.visible = !source_filtering.visible

func _on_add_to_combat_button_pressed():
	add_enemy.emit(enemy_sheet.enemy_data)

func _on_new_enemy_button_pressed() -> void:
	new_enemy(false)

func _on_edit_enemy_button_pressed() -> void:
	new_enemy(true)


func _on_enemy_creator_sheet_created(file_address: String):
	enemy_creator_window.hide()
	file_address = ProjectSettings.globalize_path(file_address)
	var new_db_enemy: Node = csharp_database.processSingleEnemy(file_address)
	if !new_db_enemy:
		return
	enemies.append(new_db_enemy)
	source_filtering.add_source_on_runtime(new_db_enemy.source)
	sort_filter_enemies()


func enemy_creator_closed() -> void:
	enemy_creator_window.hide()


func _on_delete_enemy_button_pressed() -> void:
	EventBus.confirm_popup.emit("Delete custom enemy?", "Confirm", "Cancel")
	EventBus.popup_confirmed.connect(delete_confirm, CONNECT_ONE_SHOT)

func delete_confirm(confirmed: bool):
	if !confirmed:
		return
	# If so then delete the file reference and, and remove the listitem current index from the listitem and the enemies array 
	
	var current_enemy: Node
	var file_path: String = filtered_sorted_enemies[enemy_index].fileReference
	for i in enemies.size():
		if enemies[i].fileReference == file_path:
			current_enemy = enemies[i]
			enemies.remove_at(i)
			break
	enemy_list.remove_item(enemy_index)
	filtered_sorted_enemies.remove_at(enemy_index)
	DirAccess.remove_absolute(file_path)
	current_enemy.queue_free()
