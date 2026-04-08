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
var is_trapped = {1: false, 2: false, 3: false}
var barrier_space_index : int = -1

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
	"SpotTwo": {"title": "Assigned, Not Chosen", "description": "The council has decided your fate before you could even dream of choosing it yourself, pushing you further from who you truly are.", "action": "Move Backward 1 Space", "move": -1},
	"SpotFour": {"title": "The Hours are Set", "description": "The very minute of your day is owned by the collective, so you don't have time to think, wonder, or act.", "action": "Lose a Turn", "move": 0},
	"SpotSeven": {"title": "Speak only when Spoken To", "description": "You have a thought burning inside you, but the rules of the collective force you swallow it whole and step back.", "action": "Move Backward 1 Space", "move": -1},
	"SpotTen": {"title": "Stolen Hours", "description": "You slipped away from your duties to explore, but you are caught and forced to stand still while others move ahead.", "action": "Lose a Turn", "move": 0},
	"Spot11": {"title": "The Crack in the Tunnel", "description": "A crack in the wall reveals a forbidden world beneath your feet, and for the first time, you feel the pull of the unknown rushing towards you.", "action": "Move Forward 2 Spaces", "move": 2},
	"Spot13": {"title": "The Golden One", "description": "For the first time, another person looks at you and sees not a number, but a person, and in that moment, you find out what the meaning of life is.", "action": "Move Forward 2 Spaces", "move": 2},
	"Spot15": {"title": "Forbidden Words", "description": "You dare to speak words that were never meant to be spoken, and the risk of it pulls the ground out from under you.", "action": "Move Backward 1 Space", "move": -1},
	"Spot17": {"title": "Let There Be Light", "description": "You have done the impossible, creating light from nothing, proving that one mind working alone can change the entire world.", "action": "Move Forward 2 Spaces", "move": 2},
	"Spot18": {"title": "They Will Not Listen", "description": "You bring your greatest gift to the door of the scholars, and they slam it shut, threatening to destroy everything you have worked for.", "action": "Move Backwards 2 Spaces", "move": -2},
	"Spot19": {"title": "A Thought Forbidden", "description": "You own mind turns against you as you wrestle with thoughts the collective has told you are dangerous, freezing you in place with fear and doubt.", "action": "Lose a Turn", "move": 0},
	"Spot22": {"title": "We Do Not Want Your Light", "description": "Some of the most powerful people in the land stand before you and reject everything you are, crushing your discovery beneath their robes and forcing you to stop in your tracks.", "action": "Lose a Turn", "move": 0},
	"Spot23": {"title": "Run", "description": "You run with everything you have, leaving behind the only world you have ever known, your feet carrying you farther than your fear of what's to come.", "action": "Move Forward 1 Space", "move": 1},
	"Spot27": {"title": "I Choose", "description": "You stand alone with your arms wide open and make a choice purely for yourself, the single most radical and powerful act a person can perform in this world.", "action": "Move Forward 1 Space", "move": 1},
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
	for i in range(game_spaces.size()):
		if game_spaces[i].name == "Spot22":
			barrier_space_index = i
			print("Barrier found at index: ", i)
			break

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
	
	var current_pos = 0
	if current_player_moving == 1:
		current_pos = place
	elif current_player_moving == 2:
		current_pos = place2
	else:
		current_pos = place3
		
	if is_trapped[current_player_moving] and current_pos == barrier_space_index:
		if steps == 4 or steps == 6:
			sidebar.set_status("Rolled a " + str(steps) + "! You broke free!")
			is_trapped[current_player_moving] = false
			dice_enabled = false
			move_player(current_player_moving, steps)
	else:
		sidebar.set_status("Rolled a " + str(steps) + ". Still trapped...")
		await get_tree().create_timer(1.5).timeout
		advance_turn()
		
	dice_enabled = false
	print("rolled: ", steps)
	sidebar.set_status("Rolled a " + str(steps) + "! Moving...")
	if current_player_moving == 1:
		move_player(1, steps)

	elif current_player_moving == 2:
		move_player(2, steps)
		
	elif current_player_moving == 3:
		move_player(3, steps)
		
func move_player(player: int, steps: int):
	last_player_moved = player
	current_player_moving = player
	
	#var current_place = place if player == 1 else (place2 if player == 2 else place3)
	#var piece = game_piece if player == 1 else (game_piece2 if player == 2 else game_piece3)
	var current_place = 0
	var piece : Sprite2D
	
	if player == 1:
		current_place = place
		piece = game_piece
	elif player == 2:
		current_place = place2
		piece = game_piece2
	else:
		current_place = place3
		piece = game_piece3
	
	var target_place = clamp(current_place + steps, 0, number_of_spaces - 1)
	last_landed_index = target_place
	
	var tween = create_tween()
	for i in range(1, (target_place - current_place) + 1):
		var next_step_index = current_place + i
		#var next = clamp(current_place + i, 0, number_of_spaces - 1)
		tween.tween_property(piece, "position", game_spaces[next_step_index].position, 1)
		
	tween.finished.connect(func(): show_space_popup(target_place), CONNECT_ONE_SHOT)
	
	
	if player == 1:
		place = target_place
	elif player == 2:
		place2 = target_place
	else:
		place3 = target_place
		
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
	if space_index == barrier_space_index:
		sidebar.set_status("You hit a barrier: The Coucil of Scholars")
		is_trapped[current_player_moving] = true
		popup.show_popup("The Council of Scholars", "You must roll a 4 or 6 to pass them.", "Understood")
		return
	var spot_name = game_spaces[space_index].name
	if space_data.has(spot_name):
		var data = space_data[spot_name]
		sidebar.set_status("You landed on an event space!")
		popup.show_popup(data["title"], data["description"], data["action"])
	else:
		sidebar.set_status("No event. Next player's turn.")
		advance_turn()

func _on_popup_action():
	if is_trapped[current_player_moving] and get_current_index() == barrier_space_index:
		advance_turn()
		return
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
	
	if action == "Lose a Turn":
		lose_turn[last_player_moved] = true
		advance_turn()
		return
	
	var final_target = clamp(last_landed_index + move_amount, 0, number_of_spaces - 1)
	
	if last_player_moved == 1:
		place = final_target
		print("place after move: ", place)
		var tween = create_tween()
		tween.tween_property(game_piece, "position", game_spaces[place].position, 0.5)
	elif last_player_moved == 2:
		place2 = final_target
		print("place2 after move: ", place2)
		var tween = create_tween()
		tween.tween_property(game_piece2, "position", game_spaces[place2].position, 0.5)
	elif last_player_moved == 3:
		place3 = final_target
		print("place3 after move: ", place3)
		var tween = create_tween()
		tween.tween_property(game_piece3, "position", game_spaces[place3].position, 0.5)
	
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
		
