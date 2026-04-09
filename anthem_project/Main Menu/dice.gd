extends StaticBody2D

signal roll_done(index:int)

@onready var faces: Node2D = $faces

var isRolling = false
var currentIndex = 0 

func _ready() -> void:
	_set_start_face()
	
func _set_start_face():
	for faces in faces.get_children():
		faces.hide()
		
	faces.get_child(0).show()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("leftClick") and not isRolling:
		_roll_dice()
		
func _roll_dice():
		var duration: = 1.0
		isRolling = true
		
		while duration > 0:
			var newIndex = faces.get_children().pick_random().get_index()
			faces.get_child(currentIndex).hide()
			faces.get_child(newIndex).show()
			currentIndex = newIndex
			
			await get_tree().create_timer(0.1).timeout
			duration -= 0.1
			
		isRolling = false
		var final_value = 0
		for i in range(faces.get_child_count()):
			if faces.get_child(i).visible:
				final_value = i + 1
				break
		print("Dice Logic Result: ", final_value)
		roll_done.emit(final_value)
