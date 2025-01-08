extends Node

# I built this script to extract text from traits on aon

var traits = "Aberration Animal Astral Beast Celestial Construct Dragon Dream Elemental Ethereal Fey Fiend Fungus Giant Humanoid Monitor Negative Ooze Petitioner Plant Positive Spirit Time Undead"

func _ready():
	var trait_array: PackedStringArray = traits.split(" ", false)
	print(trait_array)
