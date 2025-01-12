extends Node
class_name EnemyFilterData

# File location
var database_reference: String

var creature_name: String

var level: int
var hp: int
var ac: int

var scores := {}

var saves := {}
var perception : int

# Extra speed, resistance, and weakness types are added when adding the enemy to the array
var speed := {
	"land": 0,
}

var immunities := []
var resistances := {}
var weaknesses := {}

var alignment: String

var rarity: String

var size: String : get = get_size

func get_size():
	match size:
		"tiny":
			return "tiny"
		"sml", "sm":
			return "small"
		"med":
			return "medium"
		"lrg", "lg":
			return "large"
		"huge":
			return "huge"
		"grg":
			return "gargantuan"
		_:
			return size

var traits: Array[String] = []

# Adds all the relevant filtering data to this object
func initialize(enemy_data, file_location):
	# Stores the file location
	database_reference = file_location
	
	# Adds the system for easier data retrieval here
	var enemy_system_data = enemy_data["system"]["attributes"]
	var enemy_traits = enemy_data["system"]["traits"]
	
	
	creature_name = enemy_data["name"]
	level = enemy_data["system"]["details"]["level"]["value"]
	hp = enemy_system_data["hp"]["max"]
	ac = enemy_system_data["ac"]["value"]
	
	scores["str"] = enemy_data["system"]["abilities"]["str"]["mod"]
	scores["dex"] = enemy_data["system"]["abilities"]["dex"]["mod"]
	scores["con"] = enemy_data["system"]["abilities"]["con"]["mod"]
	scores["int"] = enemy_data["system"]["abilities"]["int"]["mod"]
	scores["wis"] = enemy_data["system"]["abilities"]["wis"]["mod"]
	scores["cha"] = enemy_data["system"]["abilities"]["cha"]["mod"]
	
	saves["fortitude"] = enemy_data["system"]["saves"]["fortitude"]["value"]
	saves["reflex"] = enemy_data["system"]["saves"]["reflex"]["value"]
	saves["will"] = enemy_data["system"]["saves"]["will"]["value"]
	perception = enemy_data["system"]["attributes"]["perception"]["value"]
	
	speed["land"] = enemy_system_data["speed"]["value"]
	# Adds every type of speed that is not land speed
	if enemy_system_data["speed"].has("otherSpeeds"):
		for speed_type in enemy_system_data["speed"]["otherSpeeds"]:
			# Type of speed (fly swim etc.)
			var speed_category = speed_type["type"]
			# How many feet per action
			var speed_feet = speed_type["value"]
			speed[speed_category] = speed_feet
	
	# Adds any immunities, weaknesses, and resistances the creature has
	# Immunities are only a binary, so stored in an array
	if enemy_system_data.has("immunities"):
		for immunity in enemy_system_data["immunities"]:
			immunities.append(immunity["type"])
	
	if enemy_system_data.has("weaknesses"):
		for weakness in enemy_system_data["weaknesses"]:
			var weakness_type = weakness["type"]
			var weakness_value = weakness["value"]
			weaknesses[weakness_type] = weakness_value
	
	if enemy_system_data.has("resistances"):
		for resistance in enemy_system_data["resistances"]:
			var resistance_type = resistance["type"]
			var resistance_value = resistance["value"]
			resistances[resistance_type] = resistance_value
	
	
	alignment = enemy_data["system"]["details"]["alignment"]["value"]
	rarity = enemy_traits["rarity"]
	size = enemy_traits["size"]["value"]
	for creature_trait in enemy_traits["value"]:
		traits.append(creature_trait)
