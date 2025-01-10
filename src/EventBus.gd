extends Node

@warning_ignore("unused_signal")
signal d20_rolled(mod)

@warning_ignore("unused_signal")
signal encounter_save_directory_chosen(path: String)
@warning_ignore("unused_signal")
signal encounter_load_directory_chosen(path: String)

@warning_ignore("unused_signal")
signal error_popup(text: String)

@warning_ignore("unused_signal")
signal confirm_popup(text: String, confirm_button_text: String, cancel_button_text: String)

@warning_ignore("unused_signal")
signal popup_confirmed(yes: bool)
