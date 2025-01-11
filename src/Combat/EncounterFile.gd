extends Resource
class_name EncounterFile

var enemies = {}
var party_level: int
var party_count: int

func _get_property_list():
	var property_usage = PROPERTY_USAGE_STORAGE

	var properties = []
	properties.append({
		"name": "enemies",
		"type": TYPE_ARRAY,
		"usage": property_usage, # See above assignment.
	})
	
	return properties
