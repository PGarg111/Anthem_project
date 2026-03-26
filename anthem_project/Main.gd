extends Node2D

@onready var game_piece : Sprite2D = $game_piece
@onready var spot_two : Marker2D = $Spot2



func _unhandled_input(event: InputEvent):
	if Input.is_action_just_pressed("start_game"):
		var tween = create_tween()
		tween.tween_property(game_piece, "position", spot_two.position, 1)
	
