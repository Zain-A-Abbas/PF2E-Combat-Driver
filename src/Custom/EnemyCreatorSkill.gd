@tool
extends PanelContainer
class_name EnemyCreatorSkill

@onready var label_data_field: LabelDataField = $LabelDataField

@export var skill_name: String = "Acrobatics":
	set(val):
		skill_name = val
		label_data_field.label_text = skill_name
