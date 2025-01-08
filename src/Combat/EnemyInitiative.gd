extends HBoxContainer

@onready var enemy_name = $EnemyName
@onready var initiative_count = $InitCount

var enemy_data: Dictionary
# The enemy node that this initiative is tied to, for the sake of deleting initiative
var enemy_node: Node
var initiative: int = 0

# Adds the enemy name and rolls its initiative
func setup_initiative(enemy: EnemyInfoTemplate):
	initiative = randi_range(1, 20)
	
	enemy_data = enemy.enemy_data
	enemy_name.text = enemy.enemy_name
	
	if enemy_data == {}:
		initiative_count.text = str(initiative)
		return
	
	initiative += enemy_data["system"]["attributes"]["perception"]["value"]
	initiative_count.text = str(initiative)

func reroll_initiative():
	initiative = randi_range(1, 20)
	if enemy_data == {}:
		initiative_count.text = str(initiative)
		return
	initiative += enemy_data["system"]["attributes"]["perception"]["value"]
	initiative_count.text = str(initiative)

func rename_enemy(new_name: String):
	enemy_name.text = new_name
