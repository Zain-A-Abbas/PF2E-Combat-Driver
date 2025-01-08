@tool
extends Button

@export var dice_amount: int = 2 : set = set_dice

signal dice_rolled(sides)

func set_dice(val: int):
	if val != 100:
		text = "d" + str(val)
	else:
		text = "d%"
	dice_amount = val

func _pressed():
	emit_signal("dice_rolled", dice_amount)
