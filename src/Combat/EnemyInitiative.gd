extends HBoxContainer

signal initiative_changed

@onready var enemy_name = $EnemyName
@onready var init_field: LineEdit = %InitField

var enemy_data: Dictionary
# The enemy node that this initiative is tied to, for the sake of deleting initiative
var enemy_node: Node
var initiative: int = 0

# Adds the enemy name and rolls its initiative
func setup_initiative(enemy: EnemyInfoTemplate):
	initiative = randi_range(1, 20)
	
	if enemy:
		enemy_data = enemy.enemy_data
		enemy_name.text = enemy.enemy_name
	
	if enemy_data == {}:
		init_field.text = str(initiative)
		return
	
	if enemy_data["system"]["attributes"].has("perception"):
		initiative += enemy_data["system"]["attributes"]["perception"]["value"]
	else:
		initiative += enemy_data["system"]["perception"]["mod"]
	init_field.text = str(initiative)


func rename_enemy(new_name: String):
	enemy_name.text = new_name

func _on_init_field_text_changed(new_text: String) -> void:
	var new_initiative: int = int(new_text)
	initiative = new_initiative
	init_field.text = str(initiative)
	initiative_changed.emit()
