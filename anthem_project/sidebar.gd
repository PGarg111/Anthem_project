extends PanelContainer


@onready var turn_label = $MarginContainer/VBoxContainer/Label2
@onready var instruction_label = $MarginContainer/VBoxContainer/Label3
@onready var status_label = $MarginContainer/VBoxContainer/Label4

func _ready():
	instruction_label.text = """HOW TO PLAY
	
	1. Press space bar first to move Player 1
	   Press space bar second to move Player 2
	   Press space bar third to move Player 3
	
	2. Players take turns moving forward one space at a time by rolling the dice
	
	3. Land on a space to reveal its event. Read carefully!
	
	4. Some spaces have actions that move you backwards, forwards, or lose a turn. Press the action button when it appears.
	
	5. Checkpoints are spaces that say 'Checkpoint' on them (in the popup). 
	These spaces have more information and are important events.
	
	6. Will you be the fastest to escape collectivism?
	
	Game Pieces
	Player 1: The light bulb represents Equality
	Player 2: The wheat represents Liberty
	Player 3: The anchor represents International
	
	"""
	instruction_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	
func set_turn(player: int):
	if player == 1:
		turn_label.text = "Player 1's Turn"
		turn_label.add_theme_color_override("font_color", Color("#C8960A"))
	elif player == 2:
		turn_label.text = "Player 2's Turn"
		turn_label.add_theme_color_override("font_color", Color("#6AB4F5"))
	elif player == 3:
		turn_label.text = "Player 3's Turn"
		turn_label.add_theme_color_override("font_color", Color("#6ABF6A"))
	set_status("Roll the Dice to Move")
		
func set_status(message: String):
	status_label.text = message
