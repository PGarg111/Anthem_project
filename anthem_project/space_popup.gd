extends CanvasLayer

signal action_pressed

@onready var title_label = $PanelContainer/VBoxContainer/Label
@onready var description_label = $PanelContainer/VBoxContainer/Label2
@onready var action_button = $PanelContainer/VBoxContainer/Button

func show_popup(title: String, description: String, action_text: String = ""):
	title_label.text = title
	description_label = description
	if action_text != "":
		action_button.text = action_text
		action_button.visible = true
	else:
		action_button.visible = false
	visible = true
	
func _ready():
	action_button.pressed.connect(_on_action_button_pressed)
	
func _on_action_button_pressed():
	emit_signal("action_pressed")
	visible = false
