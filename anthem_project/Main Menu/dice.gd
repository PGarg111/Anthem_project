extends StaticBody2D

signal roll_done(index:int)

@onready var faces: Node2D = $faces

var isRolling = false
var currentIndex = 0 

func _ready() -> void:
	_set_start_face()
	
func _set_start_face():
	for face in faces.get_children():
		face.hide()
		
	faces.get_child(0).show()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("leftClick") and not isRolling:
		_roll_dice()
		
func _roll_dice():
		var duration: = 1.0
		isRolling = true
		
		while duration > 0:
			var newIndex = randi() % faces.get_child_count()			
			faces.get_child(currentIndex).hide()
			currentIndex = newIndex
			faces.get_child(currentIndex).show()
			await get_tree().create_timer(0.1).timeout
			duration -= 0.1
			
		isRolling = false
		
		var roll_value = 0
		for face in faces.get_children():
			if face.visible:
				roll_value = int(face.name)
				break
				
		print("Dice Logic Result: ", roll_value)
		roll_done.emit(roll_value)
