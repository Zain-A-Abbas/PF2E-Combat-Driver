extends RichTextLabel
@onready var d_2_button: Button = %d2Button
@onready var d_4_button: Button = %d4Button
@onready var d_6_button: Button = %d6Button
@onready var d_8_button: Button = %d8Button
@onready var d_10_button: Button = %d10Button
@onready var d_12_button: Button = %d12Button
@onready var d_20_button: Button = %d20Button
@onready var d_100_button: Button = %d100Button
@onready var custom_roll_line: LineEdit = %CustomRollLine
@onready var custom_roll_button: Button = %CustomRollButton

var last_enemy: String

class RolledDice:
	var roll_name: String
	var roll_results: String
	var roll_total: int

# Called when the node enters the scene tree for the first time.
func _ready():
	d_2_button.connect("dice_rolled", roll_dice)
	d_4_button.connect("dice_rolled", roll_dice)
	d_6_button.connect("dice_rolled", roll_dice)
	d_8_button.connect("dice_rolled", roll_dice)
	d_10_button.connect("dice_rolled", roll_dice)
	d_12_button.connect("dice_rolled", roll_dice)
	d_20_button.connect("dice_rolled", roll_dice)
	d_100_button.connect("dice_rolled", roll_dice)
	EventBus.dice_roll.connect(sheet_roll)


func roll_dice(dice_faces: int):
	if text != "":
		text += "\n"
	var dice_result: int = randi_range(1, dice_faces)
	text += "d" + str(dice_faces) + " = " + str(dice_result)

func d20_with_mod(mod: int, enemy_name: String):
	if text != "":
		text += "\n"
	var dice_result: int = randi_range(1, 20)
	var dice_total: int = dice_result + mod
	text += enemy_name + " d20" + " (" + str(dice_result) +  ") + " + str(mod) + " = " + str(dice_total)

func sheet_roll(roll_data: Dictionary, enemy_name: String):
	var roll_text: String = ""
	# If enemy isn't the last one in the roll text, then add a new line and heir name
	if enemy_name != last_enemy && enemy_name != "":
		if text != "":
			text += "\n"
		roll_text += "[b]" + enemy_name + "[/b]" + ":"
	last_enemy = enemy_name
	if roll_data["type"] == "d20":
		roll_text += "\n"
		var key: String = roll_data["rolls"].keys()[0]
		var rolled: RolledDice = interpret_roll(roll_data["rolls"][key], key)
		roll_text += " " + rolled.roll_name + ": " + rolled.roll_results + " = " + str(rolled.roll_total)
	elif roll_data["type"] == "damage" || roll_data["type"] == "custom":
		#var total_damage: int = 0
		var keys: Array = roll_data["rolls"].keys()
		for key in keys:
			if roll_data["type"] == "damage" || text != "":
				roll_text += "\n"
			var rolled: RolledDice = interpret_roll(roll_data["rolls"][key], key)
			roll_text += " " + rolled.roll_results + " = " + str(rolled.roll_total) + " " + rolled.roll_name
			#total_damage += rolled.roll_total
	text += roll_text

func interpret_roll(roll: String, roll_name: String) -> RolledDice:
	var rolled: RolledDice = RolledDice.new()
	rolled.roll_name = roll_name
	rolled.roll_total = 0
	rolled.roll_results = ""
	
	var roll_numbers: PackedStringArray = roll.split("+", false)
	for number in roll_numbers:
		var dice_roll: bool = number.contains("d")
		
		var result: int = 0
		if dice_roll:
			var number_split: PackedStringArray = number.split("d")
			if number_split[0] == "":
				number_split[0] = "1"
			if rolled.roll_results != "":
				rolled.roll_results += " + "
			rolled.roll_results += number + " ("
			for roll_count in int(number_split[0]):
				if roll_count > 0:
					rolled.roll_results += ", "
				result += randi_range(1, int(number_split[1]))
				rolled.roll_results += str(result)
			rolled.roll_results += ")"
		else:
			result = int(number)
			if rolled.roll_results != "":
				if result > 0:
					rolled.roll_results += " + "
				else:
					rolled.roll_results += " - "
			rolled.roll_results += str(abs(result))
		rolled.roll_total += result
	
	return rolled

func roll_custom_dice(custom_text: String):
	var dice: Dictionary = {
		"type": "custom",
		"rolls": {
			"": custom_text.replace(" ", "")
		},
	}
	sheet_roll(dice, "")

func _on_clear_dice_pressed():
	text = ""
	last_enemy = ""


func _on_custom_roll_button_pressed() -> void:
	roll_custom_dice(custom_roll_line.text)
