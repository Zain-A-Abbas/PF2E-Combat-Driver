extends Label
@onready var d_2_button: Button = %d2Button
@onready var d_4_button: Button = %d4Button
@onready var d_6_button: Button = %d6Button
@onready var d_8_button: Button = %d8Button
@onready var d_10_button: Button = %d10Button
@onready var d_12_button: Button = %d12Button
@onready var d_20_button: Button = %d20Button
@onready var d_100_button: Button = %d100Button

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
	EventBus.d20_rolled.connect(d20_with_mod)


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


func _on_clear_dice_pressed():
	text = ""
