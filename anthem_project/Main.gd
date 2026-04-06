extends Node2D

@onready var sidebar = $CanvasLayer/SidebarLayer/PanelContainer
@onready var game_piece : Sprite2D = $game_piece
@onready var game_piece2 : Sprite2D = $game_piece2
@onready var game_piece3 : Sprite2D = $game_piece3
@onready var dice = $CanvasLayer/DiceLayer/Dice
@export var game_spaces : Array[Node]
@onready var popup = $SpacePopup
@onready var camera : Camera2D = $Camera2D
var lose_turn = {1: false, 2: false, 3: false}

func _process(_delta):
	var target_piece : Sprite2D
	if current_player_moving == 1:
		target_piece = game_piece
	elif current_player_moving == 2:
		target_piece = game_piece2
	else:
		target_piece = game_piece3
	camera.position = camera.position.lerp(target_piece.position, 0.1)

var last_landed_index : int = 0
var place : int = 0
var place2 : int = 0
var place3 : int = 0
var current_player_moving : int = 1
var last_player_moved : int = 1
var number_of_spaces : int
var dice_enabled : bool = true

var space_data = {
	"SpotTwo": {"title": "    Assigned, Not Chosen", "description": "   The council has decided your fate before you could even dream of choosing it yourself, pushing you further from who you truly are.", "action": "Move Backwards", "move": -1},
	"SpotFour": {"title": "    The Hours are Set", "description": "   The very minute of your day is owned by the collective, so you don't have time to think, wonder, or act.", "action": "Lose Turn", "move": 0}
}

func _ready():
	number_of_spaces = game_spaces.size()
	popup.visible = false
	popup.action_pressed.connect(_on_popup_action)
	dice.roll_done.connect(_on_roll_done)
	current_player_moving = 1
	sidebar.set_turn(1)
	await get_tree().process_frame
	camera.position = game_piece.position

func _on_roll_done(steps: int):
	if not dice_enabled:
		print("dice disabled, ignoring roll")
		return
	
	if lose_turn[current_player_moving]:
		sidebar.set_status("Player " + str(current_player_moving) + " loses their turn!")
		lose_turn[current_player_moving] = false
		await get_tree().create_timer(2.0).timeout
		advance_turn()
		return
	dice_enabled = false
	print("rolled: ", steps)
	sidebar.set_status("Rolled a " + str(steps) + "! Moving...")
	if current_player_moving == 1 and place <= (number_of_spaces - 1):
		move_player(1, steps)

	elif current_player_moving == 2 and place2 <= (number_of_spaces - 1):
		move_player(2, steps)
		
	elif current_player_moving == 3 and place3 <= (number_of_spaces - 1):
		move_player(3, steps)
		
func move_player(player: int, steps: int):
	last_player_moved = player
	current_player_moving = player
	var current_place = place if player == 1 else (place2 if player == 2 else place3)
	var piece = game_piece if player == 1 else (game_piece2 if player == 2 else game_piece3)
	
	var target_place = clamp(current_place + steps, 0, number_of_spaces - 1)
	last_landed_index = target_place
	
	var tween = create_tween()
	for i in range(1, steps + 1):
		var next = clamp(current_place + i, 0, number_of_spaces - 1)
		tween.tween_property(piece, "position", game_spaces[next].position, 1)
		
	tween.finished.connect(func(): show_space_popup(target_place), CONNECT_ONE_SHOT)
	
	
	if player == 1:
		place = target_place + 1
	elif player == 2:
		place2 = target_place + 1
	else:
		place3 = target_place + 1
		
func advance_turn():
	if current_player_moving == 1:
		current_player_moving = 2
		sidebar.set_turn(2)
	elif current_player_moving == 2:
		current_player_moving = 3
		sidebar.set_turn(3)
	elif current_player_moving == 3:
		current_player_moving = 1
		sidebar.set_turn(1)
	dice_enabled = true
		
func show_space_popup(space_index: int):
	var spot_name = game_spaces[space_index].name
	if space_data.has(spot_name):
		var data = space_data[spot_name]
		sidebar.set_status("You landed on an event space!")
		popup.show_popup(data["title"], data["description"], data["action"])
	else:
		sidebar.set_status("No event. Next player's turn.")
		advance_turn()

func _on_popup_action():
	var index = get_current_index()
	print("index: ", index)
	print("place before move: ", place)
	
	if index < 0 or index >= number_of_spaces:
		print("index out of bounds")
		advance_turn()
		return
	
	var spot_name = game_spaces[index].name
	print("spot name: ", spot_name)
	
	if not space_data.has(spot_name):
		print("spot not in space_data")
		advance_turn()
		return 
		
	var data = space_data[spot_name]
	var action = data["action"]
	var move_amount = data["move"]
	print("move amount: ", move_amount)
	
	if action == "Lose Turn":
		lose_turn[last_player_moved] = true
		advance_turn()
		return
	
	if last_player_moved == 1:
		place = clamp(last_landed_index + move_amount, 0, number_of_spaces - 1)
		print("place after move: ", place)
		var tween = create_tween()
		tween.tween_property(game_piece, "position", game_spaces[place].position, 1)
	elif last_player_moved == 2:
		place2 = clamp(last_landed_index + move_amount, 0, number_of_spaces - 1)
		print("place2 after move: ", place2)
		var tween = create_tween()
		tween.tween_property(game_piece2, "position", game_spaces[place2].position, 1)
	elif last_player_moved == 3:
		place3 = clamp(last_landed_index + move_amount, 0, number_of_spaces - 1)
		print("place3 after move: ", place3)
		var tween = create_tween()
		tween.tween_property(game_piece3, "position", game_spaces[place3].position, 1)
	
	advance_turn()
	
	#if current_player_moving == 1:
		#sidebar.set_turn(2)
		#current_player_moving = 2
	#elif current_player_moving == 2:
		#sidebar.set_turn(3)
		#current_player_moving = 3
	#elif current_player_moving == 3:
		#sidebar.set_turn(1)
		#current_player_moving = 1
	#dice_enabled = true


func get_current_index() -> int:
	return last_landed_index
	#if last_player_moved == 1:
		#return place - 1
	#elif last_player_moved == 2:
		#return place2 - 1
	#else:
		#return place3 - 1
		
