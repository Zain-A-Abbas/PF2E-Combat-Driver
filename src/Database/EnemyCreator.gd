extends PanelContainer
class_name EnemyCreator

signal sheet_created

const EnemySheetExample = preload("res://EnemySheet/EnemySheetExample.gd")

const ENEMY_CREATOR_SKILL = preload("res://Custom/EnemyCreatorSkill.tscn")
const SKILLS: Array[String] = ["Acrobatics", "Arcana", "Athletics", "Crafting", "Deception", "Diplomacy", "Intimidation", "Lore", "Medicine", "Nature", "Occultism", "Performance", "Religion", "Society", "Stealth", "Survival", "Thievery"]

@onready var tab_container: TabContainer = %TabContainer

@onready var enemy_data_formatter: Node = %EnemyDataFormatter
@onready var name_field: LabelDataField = %NameField
@onready var level_field: LabelDataField = %LevelField
@onready var perception_field: LabelDataField = %PerceptionField
@onready var senses_field: LabelDataField = %SensesField
@onready var languages_field: LabelDataField = %LanguagesField

@onready var skills_vbox: VBoxContainer = %SkillsVbox

@onready var enemy_customizer_setup: Node = %EnemyCustomizerSetup

@export var sheet: Sheet

var current_focused_line_edit: LineEdit

# If this is true, then simply overwrite the enemy file
var editing: bool = false

func _ready() -> void:
	enemy_customizer_setup.sheet = sheet
	tab_container.current_tab = 0
	# Set min heights for nodes
	for node in find_children("*"):
		if is_instance_of(node, LineEdit) || is_instance_of(node, TextEdit):
			node.custom_minimum_size.y = 25

	# Setup skills
	for child in skills_vbox.get_children():
		child.queue_free()

	for i in SKILLS.size():
		if (i > 0):
			skills_vbox.add_child(HSeparator.new())
		var newSkill: EnemyCreatorSkill = ENEMY_CREATOR_SKILL.instantiate()
		skills_vbox.add_child(newSkill)
		newSkill.skill_name = SKILLS[i]
		newSkill.name = SKILLS[i] + "Panel"
	
	for child in find_children("", "Table"):
		if child is Table:
			child.cell_clicked.connect(get_table_number)

	get_viewport().gui_focus_changed.connect(focus_changed)

func get_table_number(amount: int):
	if current_focused_line_edit:
		current_focused_line_edit.text = str(amount)
		current_focused_line_edit = null

func focus_changed(control: Control):
	if control is LineEdit:
		current_focused_line_edit = control

func create_enemy():
	enemy_data_formatter.create_enemy(editing)

func has_file_name(file_name: String, folder: DirAccess):
	return folder.get_files().has(file_name + ".json")

func _on_save_sheet_button_pressed():
	create_enemy()


func _on_enemy_data_formatter_sheet_created() -> void:
	sheet_created.emit()


func _on_customize_enemy_button_pressed() -> void:
	enemy_customizer_setup.customize_current_enemy()
