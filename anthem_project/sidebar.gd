extends PanelContainer


@onready var turn_label = $VBoxContainer/Label2
@onready var instruction_label = $VBoxContainer/Label3

func _ready():
	instruction_label.text = """HOW TO PLAY
	
	1. Press '1' to move Player 1
	   Press '2' to move Player 2
	2. Players take turns moving forwrad one space at a time
	3. Land on a space to reveal its event. Read carefully!
	4. Some spaces have actions that move you backwards. Press the action button when it appears.
	5. First player to reach the end wins!
	
	Checkpoints are spaces that say 'Checkpoint' on them. 
	These spaces have more information and are important events.
	
	"""
	instruction_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	
func set_turn(player: int):
	if player == 1:
		turn_label.text = "Player 1's Turn"
		turn_label.add_theme_color_override("font_color", Color("#C8960A"))
	else:
		turn_label.text = "Player 2's Turn"
		turn_label.add_theme_color_override("font_color", Color("#6AB4F5"))
