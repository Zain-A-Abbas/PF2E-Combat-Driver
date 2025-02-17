extends PanelContainer
class_name EnemyInfoTemplate

@onready var hp_bar: ProgressBar = %HPBar
@onready var name_bar: LineEdit = %EnemyName
@onready var current_hp: LineEdit = %CurrentHP
@onready var max_hp_box: LineEdit = %MaxHP
@onready var damage: LineEdit = %Damage

@onready var up_move_button: Button = %UpMoveButton
@onready var down_move_button: Button = %DownMoveButton

# For displaying the sheet on the combat page
signal viewing_enemy(enemy_data, enemy_name: String)
signal deleted_enemy(enemy)
signal renamed_enemy(enemy, new_name)
signal reordered_enemy

var regex := RegEx.new()
var hp: int = 0 : set = set_hp
var max_hp: int = 0 : set = set_max_hp

func set_hp(val: int):
	hp = max(0, val)
	current_hp.text = str(hp)
	max_hp_box.text = str(max_hp)
	hp_bar.value = max(0, float(hp) / float(max_hp) * 100)

func set_max_hp(val: int):
	max_hp = max(0, val)
	max_hp_box.text = str(max_hp)

# The enemy JSON data
var enemy_data: Dictionary = {}
# The enemy's name
var enemy_name: String

# Any conditions or stat changes affecting the enemy
var conditions = {}

func _ready():
	regex.compile("^[0 -9]*$")
	await get_tree().process_frame
	reordered_enemy.emit()

func setup_enemy(encounter_enemy: EnemyEncounterData):
	max_hp = encounter_enemy.max_hp
	hp = encounter_enemy.hp
	enemy_name = encounter_enemy.enemy_name
	enemy_data = encounter_enemy.enemy_data
	name_bar.text = enemy_name

# Creates a combat file for the sake of creating save files
func create_combat_file():
	var combat_data = {
		"enemy_name": name_bar.text,
		"hp": hp,
		"max_hp": max_hp,
		"conditions": conditions,
		"enemy_data": enemy_data
	}
	
	return combat_data

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			enemy_focus()

# Tells the program to show the current sheet on the right-hand side
func enemy_focus():
	# Don't do anything if blank sheet
	if enemy_data == {}:
		return
	viewing_enemy.emit(enemy_data, enemy_name)

# 1 is down, -1 is up
func move_enemy(dir: int):
	if dir == -1 && get_index() == 0:
		return
	if dir == 1 && get_index() == get_parent().get_child_count() - 1:
		return
	
	get_parent().move_child(self, get_index() + dir)
	reordered_enemy.emit()

# A little strange way of handling it but has to be retrofitted into this architecture
func verify_buttons():
	button_toggle(get_index() != 0, get_index() != get_parent().get_child_count() - 1)

func button_toggle(up_button: bool, down_button: bool):
	up_move_button.disabled = !up_button
	down_move_button.disabled = !down_button


func _on_current_hp_text_submitted(new_text):
	hp = int(new_text)

func _on_current_hp_focus_exited():
	hp = int(current_hp.text)

func _on_max_hp_text_submitted(new_text):
	max_hp = int(new_text)
	set_hp(hp)

func _on_max_hp_focus_exited():
	max_hp = int(max_hp_box.text)
	set_hp(hp)


func _on_damage_button_pressed():
	enemy_focus()
	if !int(current_hp.text):
		current_hp.text = str(0)
		hp = 0
	if int(damage.text):
		hp -= int(damage.text)
		damage.text = ""


func _on_delete_button_pressed():
	deleted_enemy.emit(self)


func _on_enemy_name_focus_entered():
	enemy_focus()


func _on_damage_focus_entered():
	enemy_focus()


func _on_max_hp_focus_entered():
	enemy_focus()


func _on_current_hp_focus_entered():
	enemy_focus()


func _on_enemy_name_text_changed(new_text: String):
	enemy_name = new_text
	renamed_enemy.emit(self, new_text)
	enemy_focus()


func _on_damage_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_on_damage_button_pressed()
