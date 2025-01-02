extends PanelContainer
class_name EnemyCreatorStrikeContainer

signal edit_button_clicked(strike_container: EnemyCreatorStrikeContainer)

@onready var strike_text: RichTextLabel = %StrikeText
@onready var edit_button: Button = %EditButton

const ACTION_ICON: String = "[img=17]res://Icons/Action.png[/img] "

var strike_data: EnemyCreatorStrike

func _ready() -> void:
	pass

func fill_data(data: EnemyCreatorStrike):
	strike_data = data
	
	strike_text.text = ""
	if strike_data.strike_type == EnemyCreatorStrike.StrikeType.MELEE:
		strike_text.text = "[b]Melee[/b] "
	elif strike_data.strike_type == EnemyCreatorStrike.StrikeType.RANGED:
		strike_text.text = "[b]Ranged[/b] "
	
	strike_text.text += ACTION_ICON
	
	strike_text.text += strike_data.strike_name + " "
	strike_text.text += "+" + str(strike_data.strike_bonus) + " "
	
	if !strike_data.traits.is_empty():
		strike_text.text += "("
		for i in strike_data.traits.size():
			strike_text.text += strike_data.traits[i]
			if i < strike_data.traits.size() - 1:
				strike_text.text += ", "
		strike_text.text += ") "
	
	strike_text.text += "\n[b]Damage[/b] " + strike_data.strike_damage

func close() -> void:
	strike_data.free()
	queue_free()


func _on_edit_button_pressed() -> void:
	emit_signal("edit_button_clicked", self)
