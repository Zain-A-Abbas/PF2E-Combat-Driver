extends GridContainer
class_name Table

signal cell_clicked(text: int)

const TABLE_HEADER_CELL = preload("res://Table/TableHeaderCell.tres")
const TABLE_ODD_ROW_CELL = preload("res://Table/TableOddRowCell.tres")
const TABLE_EVEN_ROW_CELL = preload("res://Table/TableEvenRowCell.tres")
const TABLE_BUTTON = preload("res://Table/TableButton.tscn")

const MONTSERRAT_BOLD = preload("res://Fonts/Montserrat-Bold.ttf")
const MONTSERRAT_REGULAR = preload("res://Fonts/Montserrat-Regular.ttf")
const HEADER_CELL_COLOR: Color = Color("#e4ecea")

const ABILITY_MODIFIERS: String = "res://Table/TableData/Ability Modifiers.csv"
const AREA_DAMAGE: String = "res://Table/TableData/Area Damage.csv"
const ARMOR_CLASS: String = "res://Table/TableData/Armor Class.csv"
const HIT_POINTS: String = "res://Table/TableData/Hit Points.csv"
const PERCEPTION: String = "res://Table/TableData/Perception.csv"
const RESISTANCES_AND_WEAKNESSES: String = "res://Table/TableData/Resistances and Weaknesses.csv"
const SAFE_ITEMS: String = "res://Table/TableData/Safe Items.csv"
const SAVING_THROWS: String = "res://Table/TableData/Saving Throws.csv"
const SKILLS: String = "res://Table/TableData/Skills.csv"
const SPELL_BONUSES: String = "res://Table/TableData/Spell Bonuses.csv"
const SPELL_DCS: String = "res://Table/TableData/Spell DCs.csv"
const SPELL_ATTACK: String = "res://Table/TableData/Spell Attack.csv"
const STRIKE_ATTACK_BONUS: String = "res://Table/TableData/Strike Attack Bonus.csv"
const STRIKE_DAMAGE: String = "res://Table/TableData/Strike Damage.csv"

enum TableType {
	NONE,
	HP,
	AC,
	SPELL_DC,
	SPELL_ATTACK,
	SKILLS,
	ABILITY_SCORES,
	STRIKE_BONUS,
	STRIKE_DAMAGE,
	AREA_DAMAGE,
	PERCEPTION,
	RESISTANCES,
	SAVES
}

@export var table_type: TableType = TableType.NONE

var column_count: int = 0
var odd_even_row: int = 0

func _ready() -> void:
	visible = false
	add_theme_constant_override("h_separation", 0)
	add_theme_constant_override("v_separation", 0)
	
	visible = true
	match table_type:
		TableType.NONE:
			visible = false
		TableType.HP:
			read_csv(HIT_POINTS)
		TableType.AC:
			read_csv(ARMOR_CLASS)
		TableType.SKILLS:
			read_csv(SKILLS)
		TableType.SKILLS:
			read_csv(SKILLS)
		TableType.SPELL_DC:
			read_csv(SPELL_DCS)
		TableType.SPELL_ATTACK:
			read_csv(SPELL_ATTACK)
		TableType.ABILITY_SCORES:
			read_csv(ABILITY_MODIFIERS)
			read_csv(SKILLS)
		TableType.STRIKE_BONUS:
			read_csv(STRIKE_ATTACK_BONUS)
		TableType.STRIKE_DAMAGE:
			read_csv(STRIKE_DAMAGE)
		TableType.AREA_DAMAGE:
			read_csv(AREA_DAMAGE)
		TableType.PERCEPTION:
			read_csv(PERCEPTION)
		TableType.RESISTANCES:
			read_csv(RESISTANCES_AND_WEAKNESSES)
		TableType.SAVES:
			read_csv(SAVING_THROWS)

static func add_tables(parent: Control):
	var skills_table: Table = Table.new()
	skills_table.name = "Skills"
	parent.add_child(skills_table)
	skills_table.read_csv(SKILLS)

func read_csv(file_address: String):
	var csvAccess: FileAccess = FileAccess.open(file_address, FileAccess.READ)
	var header: PackedStringArray = csvAccess.get_csv_line()
	create_header(header)
	column_count = header.size()
	var row: PackedStringArray = csvAccess.get_csv_line()
	while (!row.is_empty() && row[0] != ""):
		add_row(row)
		row = csvAccess.get_csv_line()

func create_header(header_text: Array[String]):
	columns = header_text.size()
	for cell_text in header_text:
		var newPanel: PanelContainer = PanelContainer.new()
		var newLabel: Label = Label.new()
		
		newPanel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		newPanel.add_theme_stylebox_override("panel", TABLE_HEADER_CELL)
		
		newLabel.add_theme_color_override("font_color", HEADER_CELL_COLOR)
		newLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		newLabel.add_theme_font_override("font", MONTSERRAT_BOLD)
		newLabel.text = cell_text
		
		newPanel.add_child(newLabel)
		add_child(newPanel)

func add_row(row_data: Array[String]):
	assert(row_data.size() == column_count)
	odd_even_row += 1
	var i: int = 0
	for cell_text in row_data:
		var newPanel: PanelContainer = PanelContainer.new()
		var newLabel: Label = Label.new()
		
		if (odd_even_row % 2 == 0):
			newPanel.add_theme_stylebox_override("panel", TABLE_EVEN_ROW_CELL)
		else:
			newPanel.add_theme_stylebox_override("panel", TABLE_ODD_ROW_CELL)
		
		newLabel.add_theme_color_override("font_color", Color.BLACK)
		newLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if i > 0:
			newLabel.add_theme_font_override("font", MONTSERRAT_REGULAR)
		else:
			newLabel.add_theme_font_override("font", MONTSERRAT_BOLD)
		newLabel.text = cell_text
		
		# Adds the button to the number cells
		if i > 0:
			var new_button: Button = TABLE_BUTTON.instantiate()
			new_button.pressed.connect(button_pressed.bind(newLabel))
			newPanel.add_child(new_button)
		
		newPanel.add_child(newLabel)
		add_child(newPanel)
		i += 1

func button_pressed(cell_label: Label):
	var cell_text: PackedStringArray = cell_label.text.split("-")
	if cell_text.size() == 1:
		cell_clicked.emit(int(cell_text[0]))
	else:
		var numbers: Array[int] = []
		for number in cell_text:
			numbers.append(int(number))
		var avg: int = 0
		for number in numbers:
			avg += number
		avg /= numbers.size()
		cell_clicked.emit(avg)
