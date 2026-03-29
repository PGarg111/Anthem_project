extends Node2D

@onready var game_piece : Sprite2D = $CanvasLayer/game_piece
@onready var game_piece2 : Sprite2D = $CanvasLayer/game_piece2
var last_landed_index : int = 0
@export var game_spaces : Array[Node]
@onready var popup = $SpacePopup
var place : int = 0
var place2 : int = 0
var current_player_moving : int = 0
var number_of_spaces : int

var space_data = {
	"SpotOne": {"title": "Something", "desc": "Something", "action": "", "move": 0},
	"SpotTwo": {"title": "Something", "desc": "Something", "action": "Move Backwards", "move": -1},
	"SpotThree": {"title": "Something", "desc": "Something", "action": "", "move": 0},
	"SpotFour": {"title": "Something", "desc": "Something", "action": "", "move": 0},
	"SpotFive": {"title": "Something", "desc": "Something", "action": "", "move": 0},
	"SpotSix": {"title": "Something", "desc": "Something", "action": "", "move": 0},
	"SpotSeven": {"title": "Something", "desc": "Something", "action": "", "move": 0},
	"SpotEight": {"title": "Something", "desc": "Something", "action": "", "move": 0}
}

func _ready():
	number_of_spaces = game_spaces.size()
	popup.visible = false
	popup.action_pressed.connect(_on_popup_action)


func _unhandled_input(_event: InputEvent):
	#if Input.is_action_just_pressed("player1") and place <= (number_of_spaces - 1):
		#var tween = create_tween()
		#tween.tween_property(game_piece, "position", game_spaces[place].position, 1)
		#place += 1
	#elif place >= number_of_spaces:
		#print("Place is out of bounds")	
	if Input.is_action_just_pressed("player1") and place <= (number_of_spaces - 1):
		move_player(1)

	elif Input.is_action_just_pressed("player2") and place2 <= (number_of_spaces - 1):
		move_player(2)
		
func move_player(player: int):
	current_player_moving = player
	var current_place = place if player == 1 else place2
	var piece = game_piece if player == 1 else game_piece2
	
	var tween = create_tween()
	tween.tween_property(piece, "position", game_spaces[current_place].position, 1)
	tween.finished.connect(func(): show_space_popup(current_place))
	
	last_landed_index = current_place
	
	if player == 1:
		place += 1
	else:
		place2 += 1
		
func show_space_popup(space_index: int):
	var spot_name = game_spaces[space_index].name
	if space_data.has(spot_name):
		var data = space_data[spot_name]
		popup.show_popup(data["title"], data["desc"], data["action"])

func _on_popup_action():
	var index = get_current_index()
	print("index: ", index)
	print("place before move: ", place)
	
	if index < 0 or index >= number_of_spaces:
		print("index out of bounds")
		return
	
	var spot_name = game_spaces[index].name
	print("spot name: ", spot_name)
	
	if not space_data.has(spot_name):
		print("spot not in space_data")
		return 
		
	var data = space_data[spot_name]
	var move_amount = data["move"]
	print("move amount: ", move_amount)
	
	
	if current_player_moving == 1:
		place = clamp(last_landed_index + move_amount, 0, number_of_spaces - 1)
		print("place after move: ", place)
		var tween = create_tween()
		tween.tween_property(game_piece, "position", game_spaces[place].position, 1)
	else:
		place2 = clamp(last_landed_index + move_amount, 0, number_of_spaces -1)
		print("place2 after move: ", place2)
		var tween = create_tween()
		tween.tween_property(game_piece2, "position", game_spaces[place2].position, 1)
		
func get_current_index() -> int:
	if current_player_moving == 1:
		return place-1
	else:
		return place2 -1
