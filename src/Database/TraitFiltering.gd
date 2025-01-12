extends FilteringMenu


@onready var ancestry_subfilter: Subfilter = %AncestrySubfilter
@onready var creature_type_subfilter: Subfilter = %CreatureTypeSubfilter
@onready var elemental_subfilter: Subfilter = %ElementalSubfilter
@onready var energy_subfilter: Subfilter = %EnergySubfilter
@onready var monster_subfilter: Subfilter = %MonsterSubfilter
@onready var planar_subfilter: Subfilter = %PlanarSubfilter
@onready var weapon_subfilter: Subfilter = %WeaponSubfilter

@onready var filters_container: VBoxContainer = %FiltersContainer

@onready var include_and_check: CheckBox = %IncludeAndCheck
@onready var include_or_check: CheckBox = %IncludeOrCheck

# "False" means including enemies as long as they have a ticked trait, true means including every trait that is ticked
var include_and_or: bool = true : set = set_inclusion

func _ready():
	# Assigning these values automatically creatres the trait buttons within each subfilter
	ancestry_subfilter.traits = ["Aasimar", "Anadi", "Android", "Aphorite", "Ardande", "Automaton", "Azarketi", "Beastkin", "Catfolk", "Changeling", "Conrasu", "Dhampir", "Duskwalker", "Dwarf", "Elf", "Fetchling", "Fleshwarp", "Ganzi", "Geniekin", "Ghoran", "Gnoll", "Gnome", "Goblin", "Goloma", "Grippli", "Half-Elf", "Halfling", "Half-Orc", "Hobgoblin", "Human", "Ifrit", "Kashrishi", "Kitsune", "Kobold", "Leshy", "Lizardfolk", "Nagaji", "Orc", "Oread", "Poppet", "Ratfolk", "Reflection", "Shisk", "Shoony", "Skeleton", "Sprite", "Strix", "Suli", "Sylph", "Talos", "Tengu", "Tiefling", "Undine", "Vanara", "Vishkanya"]
	creature_type_subfilter.traits  = ["Aberration", "Animal", "Astral", "Beast", "Celestial", "Construct", "Dragon", "Dream", "Elemental", "Ethereal", "Fey", "Fiend", "Fungus", "Giant", "Humanoid", "Monitor", "Negative", "Ooze", "Petitioner", "Plant", "Positive", "Spirit", "Time", "Undead"]
	elemental_subfilter.traits = ["Air", "Earth", "Fire", "Metal", "Water", "Wood"]
	energy_subfilter.traits = ["Acid", "Cold", "Electricity", "Fire", "Negative", "Positive"]
	monster_subfilter.traits = ["Aasimar", "Acid", "Aeon", "Aesir", "Agathion", "Air", "Alchemical", "Amphibious", "Anadi", "Angel", "Anugobu", "Aquatic", "Arcane", "Archon", "Asura", "Azata", "Boggard", "Caligni", "Catfolk", "Changeling", "Charau-ka", "Clockwork", "Cold", "Couatl", "Daemon", "Darvakka", "Demon", "Dero", "Devil", "Dhampir", "Dinosaur", "Div", "Drow", "Duergar", "Duskwalker", "Earth", "Electricity", "Fetchling", "Fire", "Formian", "Genie", "Ghoran", "Ghost", "Ghoul", "Ghul", "Gnoll", "Golem", "Gremlin", "Grioth", "Grippli", "Hag", "Hantu", "Herald", "Ifrit", "Ikeshti", "Illusion", "Incorporeal", "Inevitable", "Kaiju", "Kami", "Kobold", "Kovintus", "Leshy", "Lilu", "Lizardfolk", "Locathah", "Merfolk", "Mindless", "Morlock", "Mortic", "Mummy", "Munavri", "Mutant", "Nagaji", "Nymph", "Oni", "Orc", "Oread", "Paaridar", "Phantom", "Protean", "Psychopomp", "Qlippoth", "Rakshasa", "Ratajin", "Ratfolk", "Sahkil", "Samsaran", "Sea", "Devil", "Serpentfolk", "Seugathi", "Shabti", "Shapechanger", "Siktempora", "Skeleton", "Skelm", "Skulk", "Sonic", "Soulbound", "Sporeborn", "Spriggan", "Sprite", "Stheno", "Suli", "Swarm", "Sylph", "Tane", "Tanggal", "Tengu", "Tiefling", "Titan", "Troll", "Troop", "Undine", "Urdefhan", "Vampire", "Vanara", "Velstrac", "Vishkanya", "Water", "Wayang", "Werecreature", "Wight", "Wild", "Hunt", "Wraith", "Wyrwood", "Xulgath", "Zombie"]
	planar_subfilter.traits = ["Air", "Earth", "Fire", "Negative", "Positive", "Shadow", "Water"]
	weapon_subfilter.traits = ["Alchemical", "Azarketi", "Catfolk", "Clockwork", "Dwarf", "Elf", "Ghorani", "Gnome", "Goblin", "Grippli", "Halfling", "Kobold", "Orc", "Tengu", "Vanara", "Vishkanya"]
	fill_filter_container()

func fill_filter_container():
	filter_container = []
	for filter_button in find_children("", "TraitFilterButton", true, false):
		if filter_button is TraitFilterButton:
			filter_container.append(filter_button)
	for button in filter_container:
		button.trait_filter_button_pressed.connect(trait_filter_button_changed)

func trait_filter_button_changed(text: String, filter_state: int):
	for button in filter_container:
		if button.trait_text.text == text:
			button.filter_state = filter_state

func _on_reset_button_pressed():
	for child in find_children("*", "SubFilter", true, false):
		child.reset_filters()


func _on_trait_search_text_changed(new_text):
	for filter_button in find_children("*", "FilterButton", true, false):
		if new_text == "":
			filter_button.visible = true
		else:
			filter_button.visible = filter_button.trait_name.to_lower().contains(new_text.to_lower())

func set_inclusion(val):
	include_and_or = val
	include_and_check.button_pressed = include_and_or
	include_and_check.disabled = include_and_or
	include_or_check.button_pressed = !include_and_or
	include_or_check.disabled = !include_and_or

func _on_alt_apply_button_pressed():
	_on_apply_button_pressed()


func _on_include_and_check_pressed():
	include_and_or = true

func _on_include_or_check_pressed():
	include_and_or = false
