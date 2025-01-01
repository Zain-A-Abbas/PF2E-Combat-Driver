extends LineEdit
class_name LabelDataLineEdit

static var LineEditRegEx: RegEx = null

@onready var field: LabelDataField = get_parent()

var numbers_only: bool = false
var old_text: String

func _ready() -> void:
	numbers_only = field.numbers_only
	if !LineEditRegEx:
		LineEditRegEx = RegEx.new()
		LineEditRegEx.compile("^[0-9]*$")
	text_changed.connect(on_text_changed)

func on_text_changed(new_text: String):
	if !numbers_only:
		return
	
	if LineEditRegEx.search(new_text):
		old_text = new_text
	else:
		text = old_text
		caret_column = text.length()
