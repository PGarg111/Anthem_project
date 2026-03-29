extends Node2D

@onready var game_piece : Sprite2D = $game_piece
@onready var backwards1 : Marker2D = $SpotSix
@onready var backwardsLabel : Label = $backwards
@export var game_spaces : Array[Node]
var place : int = 0
var number_of_spaces : int

func _ready():
	number_of_spaces = game_spaces.size()


func _unhandled_input(_event: InputEvent):
	if Input.is_action_just_pressed("player1") and place <= (number_of_spaces - 1):
		var tween = create_tween()
		tween.tween_property(game_piece, "position", game_spaces[place].position, 1)
		place += 1
	elif place >= number_of_spaces:
		print("Place is out of bounds")	
