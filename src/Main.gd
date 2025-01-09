extends Control

@onready var combat: Control = %Combat
@onready var enemy_database: Control = %"Enemy Database"


# Called when the node enters the scene tree for the first time.
func _ready():
	enemy_database.add_enemy.connect(add_enemy_to_combat)


func add_enemy_to_combat(enemy_data):
	combat.add_enemy_from_sheet(enemy_data)

func _unhandled_input(event):
	if event.is_action_pressed("save"):
		combat.save_encounter()
	if event.is_action_pressed("open"):
		combat.open_encounter()
	
	if event.is_action_pressed("zoom_in"):
		Sheet.sheet_theme.set_font_size("font_size", "Label", Sheet.sheet_theme.get_font_size("font_size", "Label") + 1)
		Sheet.sheet_theme.set_font_size("normal_font_size", "RichTextLabel", Sheet.sheet_theme.get_font_size("normal_font_size", "RichTextLabel") + 1)
		Sheet.sheet_theme.set_font_size("bold_font_size", "RichTextLabel", Sheet.sheet_theme.get_font_size("bold_font_size", "RichTextLabel") + 1)
		Sheet.sheet_theme.set_font_size("italics_font_size", "RichTextLabel", Sheet.sheet_theme.get_font_size("italics_font_size", "RichTextLabel") + 1)
		Sheet.sheet_theme.set_font_size("bold_italics_font_size", "RichTextLabel", Sheet.sheet_theme.get_font_size("bold_italics_font_size", "RichTextLabel") + 1)
		Sheet.sheet_theme.set_font_size("mono_font_size", "RichTextLabel", Sheet.sheet_theme.get_font_size("mono_font_size", "RichTextLabel") + 1)
	if event.is_action_pressed("zoom_out"):
		Sheet.sheet_theme.set_font_size("font_size", "Label", Sheet.sheet_theme.get_font_size("font_size", "Label") - 1)
		Sheet.sheet_theme.set_font_size("normal_font_size", "RichTextLabel", Sheet.sheet_theme.get_font_size("normal_font_size", "RichTextLabel") - 1)
		Sheet.sheet_theme.set_font_size("bold_font_size", "RichTextLabel", Sheet.sheet_theme.get_font_size("bold_font_size", "RichTextLabel") - 1)
		Sheet.sheet_theme.set_font_size("italics_font_size", "RichTextLabel", Sheet.sheet_theme.get_font_size("italics_font_size", "RichTextLabel") - 1)
		Sheet.sheet_theme.set_font_size("bold_italics_font_size", "RichTextLabel", Sheet.sheet_theme.get_font_size("bold_italics_font_size", "RichTextLabel") - 1)
		Sheet.sheet_theme.set_font_size("mono_font_size", "RichTextLabel", Sheet.sheet_theme.get_font_size("mono_font_size", "RichTextLabel") - 1)
