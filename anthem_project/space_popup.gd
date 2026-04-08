extends CanvasLayer

signal action_pressed

@onready var title_label = $PanelContainer/MarginContainer/VBoxContainer/Label
@onready var description_label = $PanelContainer/MarginContainer/VBoxContainer/Label2
@onready var action_button = $PanelContainer/MarginContainer/VBoxContainer/Button

func show_popup(title: String, description: String, action_text: String = ""):
	print("title: ", title, " description: ", description) 
	title_label.text = title
	description_label.text = description
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
