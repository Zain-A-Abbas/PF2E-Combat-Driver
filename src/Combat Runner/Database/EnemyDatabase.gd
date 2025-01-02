extends Control

const ENEMY_DATABASE = "res://Data/Enemies/"

enum SORT_MODE {
	ALPHABETICAL,
	LEVEL
}

@onready var enemy_list: ItemList = %EnemyList
@onready var enemy_sheet: Sheet = %EnemySheet


# The filter menus; the filtering traits and numbers are retrieved directly from them
@onready var size_filter_menu: FilteringMenu = %SizeFilterMenu
@onready var rarity_filter_menu: FilteringMenu = %RarityFilterMenu
@onready var trait_filter_menu: PanelContainer = %TraitFilterMenu
@onready var numbers_filtering: PanelContainer = %NumbersFiltering
@onready var search_bar: LineEdit = %SearchBar
@onready var enemy_creator = %EnemyCreator
@onready var enemy_creator_window: Window = %EnemyCreatorWindow


signal add_enemy(enemy_data)

# Holds all enemy data
var enemies: Array[EnemyFilterData]
# Holds enemies that have been filtered and sorted
var filtered_sorted_enemies: Array[EnemyFilterData] = enemies
var sorting_mode: SORT_MODE = SORT_MODE.ALPHABETICAL : set = set_sorting
func set_sorting(val):
	if sorting_mode == val:
		return
	sorting_mode = val
	sort_filter_enemies()

# Called when the node enters the scene tree for the first time.
func _ready():
	add_enemies()


# Adds enemies to the enemies array
func add_enemies():
	enemies.clear()
	
	# Open the enemy database folder
	var directory := DirAccess.open(ENEMY_DATABASE)
	# Search through every subfolder, as enemies are placed into fodlers corresponding to rulebook source
	
	for subfolder in directory.get_directories():
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
			enemies.append(enemy_filter_data)
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
	for enemy in filtered_sorted_enemies:
		enemy_list.add_item(enemy.creature_name)

static func sort_alphabetic(enemy_a: EnemyFilterData, enemy_b: EnemyFilterData):
	return enemy_a.creature_name < enemy_b.creature_name

static func sort_level(enemy_a: EnemyFilterData, enemy_b: EnemyFilterData):
	return enemy_a.level < enemy_b.level


# Filters

func filter_enemies(enemies_to_filter: Array[EnemyFilterData]) -> Array[EnemyFilterData]:
	var filtering := enemies_to_filter.duplicate()
	filtering = name_filter(filtering, search_bar.text)
	filtering = general_filter(filtering, "rarity")
	filtering = general_filter(filtering, "size")
	filtering = general_filter(filtering, "traits")
	filtering = number_filter(filtering)
	return filtering

func name_filter( enemies_to_filter: Array[EnemyFilterData], search_name: String ) -> Array[EnemyFilterData]:
	
	if search_name == "":
		return enemies_to_filter
	
	# Enemies to include
	var include_enemies: Array[EnemyFilterData] = []
	
	for enemy in enemies_to_filter:
		if enemy.creature_name.to_lower().contains(search_name.to_lower()):
			include_enemies.append(enemy)
	
	return include_enemies
	
func outOfBounds(value: int, f: NumberFilterData):
	return !(value >= f.lower_bound && value <= f.upper_bound)
	

func number_filter( enemies_to_filter: Array[EnemyFilterData] ) -> Array[EnemyFilterData]:
	var filterData : Array[NumberFilterData] = numbers_filtering.get_number_filter_data()
	var validEnemies : Array[EnemyFilterData] = enemies_to_filter
	#main filter
	for filter: NumberFilterData in filterData:
		if filter.lower_bound == 0 && filter.upper_bound == 0:
			continue
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
	return validEnemies

# Sorts by rarity, traits and size; They share a function because of how similar they are
func general_filter( enemies_to_filter: Array[EnemyFilterData], rarity_size_traits: String ) -> Array[EnemyFilterData]:
	
	
	# Enemies to include and enemies to remove
	var include_enemies: Array[EnemyFilterData] = []
	var remove_enemies: Array[EnemyFilterData] = []
	
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
	
	
	# If no filters are interacted with in the corresponding filter menu, then do not even iterate through the enemies
	if current_filter_menu.has_no_filters():
		return enemies_to_filter
	
	# Goes through every enemy, stacks them up to the filter
	for enemy in enemies_to_filter:
		for filter_button in current_filter_menu.filter_container:
			
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
		var final_enemies: Array[EnemyFilterData] = []
		for enemy in include_enemies:
			if !remove_enemies.has(enemy):
				final_enemies.append(enemy)
		return final_enemies
	
	# If no enemies are set to include, then just add every enemy not excluded
	if !remove_enemies.is_empty():
		var final_enemies: Array[EnemyFilterData] = []
		for enemy in enemies_to_filter:
			if !remove_enemies.has(enemy):
				final_enemies.append(enemy)
		return final_enemies
	
	return enemies_to_filter

func new_enemy():
	enemy_creator_window.show()

# Signals

func _on_enemy_list_item_selected(index):
	var enemy_file = FileAccess.open(filtered_sorted_enemies[index].database_reference, FileAccess.READ)
	var json_conversion = JSON.new()
	json_conversion.parse(enemy_file.get_as_text())
	var enemy_data = json_conversion.get_data()
	enemy_sheet.setup(enemy_data)


func _on_button_pressed():
	sorting_mode = SORT_MODE.ALPHABETICAL

func _on_button_2_pressed():
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

func _on_search_bar_text_changed(new_text):
	sort_filter_enemies()

func _on_numbers_filter_button_pressed():
	numbers_filtering.visible = !numbers_filtering.visible

func _on_add_to_combat_button_pressed():
	emit_signal("add_enemy", enemy_sheet.enemy_data)

func _on_new_enemy_button_pressed():
	new_enemy()


func _on_enemy_creator_sheet_created():
	enemy_creator_window.hide()
	add_enemies()


func enemy_creator_closed() -> void:
	enemy_creator_window.hide()
