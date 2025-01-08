extends PanelContainer
class_name EnemyAbility

const _2_ACTIVITY = preload("res://Icons/2Activity.png")
const _3_ACTIVITY = preload("res://Icons/3Activity.png")
const ACTION = preload("res://Icons/Action.png")
const FREE_ACTION = preload("res://Icons/FreeAction.png")
const REACTION = preload("res://Icons/Reaction.png")

@onready var reaction_trigger: VBoxContainer = %ReactionTrigger
@onready var action_icon: TextureRect = $VBox/HBoxContainer3/ActionIcon

@onready var action_option: OptionButton = %ActionOption
@onready var name_field: LabelDataField = %NameField
@onready var traits_field: LabelDataField = %TraitsField
@onready var trigger_text_edit: TextEdit = %TriggerTextEdit
@onready var effect_text_edit: TextEdit = %EffectTextEdit

func _on_action_option_item_selected(index: int) -> void:
	reaction_trigger.visible = index == 4
	match index:
		0:
			action_icon.texture = ACTION
		1:
			action_icon.texture = _2_ACTIVITY
		2:
			action_icon.texture = _3_ACTIVITY
		3:
			action_icon.texture = FREE_ACTION
		4:
			action_icon.texture = REACTION


func _on_close_button_pressed() -> void:
	queue_free()
