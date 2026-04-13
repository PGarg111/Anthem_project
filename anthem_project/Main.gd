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
var forced_stop_indicies : Array[int] = []
var barrier_space_index = -1
var start_time : Dictionary = {1: 0.0, 2: 0.0, 3: 0.0}
var finish_time : Dictionary = {1: 0.0, 2: 0.0, 3: 0.0}
var finished_players : Array = []

func _process(_delta):
	var target_piece : Sprite2D
	if current_player_moving == 1:
		target_piece = game_piece
	elif current_player_moving == 2:
		target_piece = game_piece2
	else:
		target_piece = game_piece3
	camera.position = camera.position.lerp(target_piece.position, 0.1)

var last_landed_index = 0
var place = 0
var place2 = 0
var place3 = 0
var current_player_moving = 1
var last_player_moved = 1
var number_of_spaces : int
var dice_enabled = true

var space_data = {
	"SpotTwo": {"title": "Assigned, Not Chosen", "description": "The council has decided your fate before you could even dream of choosing it yourself, pushing you further from who you truly are.", "action": "Move Backward 1 Space", "move": -1},
	"SpotFour": {"title": "The Hours are Set", "description": "The very minute of your day is owned by the collective, so you don't have time to think, wonder, or act.", "action": "Lose a Turn", "move": 0},
	"SpotSeven": {"title": "Speak only when Spoken To", "description": "You have a thought burning inside you, but the rules of the collective force you swallow it whole and step back.", "action": "Move Backward 1 Space", "move": -1},
	"SpotTen": {"title": "Stolen Hours", "description": "You slipped away from your duties to explore, but you are caught and forced to stand still while others move ahead.", "action": "Lose a Turn", "move": 0},
	"Spot11": {"title": "The Crack in the Tunnel: Checkpoint 1", "description": "A crack in the wall reveals a forbidden world beneath your feet, and for the first time, you feel the pull of the unknown rushing towards you.
	During this moment, Equality and Independence discover a tunnel that was created during the Unmentionable Times. Equality decided to explore it despite his reservations, but International stayed outside but said that he wouldn’t report the find because, “‘The will of the Council is above all things, for it is the will of our brothers,which is holy. But if you wish it so, we shall obey you. Rather we shall be evil with you than good with all of our brothers,’”(Rand 34). Through this dialogue, Rand criticizes conformity. She shows how important defiance to authority is by showing Equality and Independence’s act of defiance. She promotes keeping secrets from corrupt authorities by showing that it was the only way for them to maintain their safety. Equality symbolizes this idea because throughout the course of the book, he continues to keep part of his life hidden from authorities and his brothers because he would be in danger if they were revealed. 
", "action": "Move Forward 1 Space", "move": 1},
	"Spot13": {"title": "The Golden One: Checkpoint 2", "description": "For the first time, another person looks at you and sees not a number, but a person, and in that moment, you find out what the meaning of life is.
	During this moment, Equality was infatuated with Liberty, who he had seen working the soil. However, he knew that he wasn’t supposed to think about her because, “men were forbidden to take notice of women, and women of men. But we think of one among women, they whose name is Liberty 5-3000, and we think of no others,”(Rand 38). Rand criticizes selflessness through this dialogue. In this society, people were expected to love everyone equally instead of prioritizing love and human connection. Rand promotes love by showing that it is important for happiness, and she uses Equality as a symbol for it by showing the shift in his emotions after he meets Liberty. 
", "action": "Move Forward 2 Spaces", "move": 2},
	"Spot15": {"title": "Forbidden Words", "description": "You dare to speak words that were never meant to be spoken, and the risk of it pulls the ground out from under you.", "action": "Move Backward 1 Space", "move": -1},
	"Spot17": {"title": "Let There Be Light: Checkpoint 3", "description": "You have done the impossible, creating light from nothing, proving that one mind working alone can change the entire world.
	In this moment, Equality discovers the lightbulb while experimenting in the tunnel, and he was proud of his creation because, “We could not conceive of that which we had created. We had touched no flint, made no fire. Yet here was light,”(Rand 59). Rand criticizes collectivism and the idea that individual discoveries and achievements are evil. She shows how valuable and important Equality’s discovery is by showing the impact that it could potentially have on society. She shows that working alone helped Equality achieve his full potential because he was not held back by the will of the collective. She promotes individuality and working alone to avoid being forced to slow down discoveries to adjust to the pace of companions. Equality is a symbol of that because he is able to make the discovery of the lightbulb because he is working alone. If he worked with the Scholars, he would have had to wait for their approval and halt his experimentation.
", "action": "Move Forward 2 Spaces", "move": 2},
	"Spot18": {"title": "They Will Not Listen", "description": "You bring your greatest gift to the door of the scholars, and they slam it shut, threatening to destroy everything you have worked for.", "action": "Move Backwards 2 Spaces", "move": -2},
	"Spot19": {"title": "A Thought Forbidden", "description": "You own mind turns against you as you wrestle with thoughts the collective has told you are dangerous, freezing you in place with fear and doubt.", "action": "Lose a Turn", "move": 0},
	"Spot22": {"title": "We Do Not Want Your Light", "description": "Some of the most powerful people in the land stand before you and reject everything you are, crushing your discovery beneath their robes and forcing you to stop in your tracks.", "action": "Lose a Turn", "move": 0},
	"Spot20": {"title": "They CANNOT Break Us: Checkpoint 4", "description": "Response", "action": "Nothing", "move": 0},
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
		var node_name = game_spaces[i].name
		if node_name == "Spot22":
			barrier_space_index = i
			forced_stop_indicies.append(i)
		if node_name == "Spot11" or node_name == "Spot13" or node_name == "Spot17" or node_name == "Spot20":
			forced_stop_indicies.append(i)
	forced_stop_indicies.sort()
	var initial_time = Time.get_ticks_msec()
	start_time = {1: initial_time, 2: initial_time, 3: initial_time}
			

func _on_roll_done(steps: int):
	print("--- NEW ROLL ---")
	if not dice_enabled:
		print("dice disabled, ignoring roll")
		return
	
	if lose_turn[current_player_moving]:
		sidebar.set_status("Player " + str(current_player_moving) + " loses their turn!")
		lose_turn[current_player_moving] = false
		await get_tree().create_timer(2.0).timeout
		advance_turn()
		return
		
	print("Current Player: ", current_player_moving)
	var current_pos = 0
	
	if current_player_moving == 1:
		current_pos = place
	elif current_player_moving == 2:
		current_pos = place2
	else:
		current_pos = place3
	print("Current Position Index: ", current_pos)
	print("Barrier Index: ", barrier_space_index)
	print("Is Trapped? ", is_trapped[current_player_moving])
	
	if is_trapped[current_player_moving] and current_pos == barrier_space_index:
		print("Logic: Player is confirmed TRAPPED at the barrier")
		if steps == 4 or steps == 6:
			sidebar.set_status("Rolled a " + str(steps) + "! You broke free!")
			is_trapped[current_player_moving] = false
	
		else:
			sidebar.set_status("Rolled a " + str(steps) + ". Still trapped...")
			await get_tree().create_timer(1.5).timeout
			advance_turn()
			return
	
	print("Logic: Player is NOT trapped. Moving normally")
		
	dice_enabled = false
	print("rolled: ", steps)
	sidebar.set_status("Rolled a " + str(steps) + "! Moving...")
	move_player(current_player_moving, steps)

		
func move_player(player: int, steps: int):
	last_player_moved = player
	current_player_moving = player
	
	var current_place = place if player == 1 else (place2 if player == 2 else place3)
	var piece = game_piece if player == 1 else (game_piece2 if player == 2 else game_piece3)

	var desired_target = current_place + steps
	var actual_target = desired_target
	
	if desired_target == (number_of_spaces - 1):
		actual_target = number_of_spaces - 1
	elif desired_target < (number_of_spaces - 1):
		actual_target = desired_target
		for stop_index in forced_stop_indicies:
			if current_place < stop_index and desired_target >= stop_index:
				actual_target = stop_index
				break
	else:
		sidebar.set_status("Not a perfect roll! Stay at the threshold.")
		actual_target = current_place
	
	var path : Array[int] = []
	var move_range = actual_target - current_place
	
	if move_range > 0:
		for i in range(1, move_range + 1):
			path.append(current_place + i)
	if path.size() > 0:
		var tween = create_tween()
		for next_index in path:
			tween.tween_property(piece, "position", game_spaces[next_index].position, 0.8)
		tween.finished.connect(func():
			if player == 1:
				place = actual_target
			elif player == 2:
				place2 = actual_target
			else:
				place3 = actual_target
			last_landed_index = actual_target
			
			if not check_for_victory(player, actual_target):
				show_space_popup(actual_target)
			else:
				advance_turn()
		,CONNECT_ONE_SHOT)
	else:
		await get_tree().create_timer(1.0).timeout
		advance_turn()
		dice_enabled = true
		
	last_landed_index = actual_target
	print("Moving from ", current_place, " to ", actual_target, " (Steps: ", move_range, ")")
		
func _on_move_finished(player: int, target: int):
	if not check_for_victory(player, target):
		show_space_popup(target)
		
func advance_turn():
	current_player_moving += 1
	if current_player_moving > 3:
		current_player_moving = 1
	
	var safety = 0
	while finished_players.has(current_player_moving) and safety < 3:
		current_player_moving += 1
		if current_player_moving > 3:
			current_player_moving = 1
		safety += 1
	if finished_players.size() == 3:
		dice_enabled = false
		show_final_ending_scene()
	else:
		sidebar.set_turn(current_player_moving)
		dice_enabled = true
	if finished_players.has(current_player_moving) and finished_players.size() > 3:
		advance_turn()
		return
	
	sidebar.set_turn(current_player_moving)
	dice_enabled = true
		
func show_space_popup(space_index: int):
	var spot_name = game_spaces[space_index].name
	if space_index == barrier_space_index:
		sidebar.set_status("Stopped by The Council of Scholars")
		is_trapped[current_player_moving] = true
		popup.show_popup("The Council of Scholars", "You present your invention of the light to the World Council of Scholars. Instead of wonder they recoil in fear. Roll a 4 or 6 to save your light.", "Understood")
		return
	
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


func get_current_index() -> int:
	return last_landed_index
	
func check_for_victory(player: int, landing_index: int):
	if landing_index == number_of_spaces - 1:
		if not player in finished_players:
			finished_players.append(player)
			finish_time[player] = (Time.get_ticks_msec() - start_time[player])/1000.0
			
			if finished_players.size() == 1:
				get_node("/root/MusicManager").transition_indiv(8.0)
				print("Music transition triggered!")
		return true
	return false
		
		
func show_final_ending_scene():
	dice.visible = false
	sidebar.visible = false
	$Final.visible = true
	$Final.show_results(finish_time)
