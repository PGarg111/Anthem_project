extends Node2D

@onready var mechanical = $Mechanical
@onready var melodic = $Melodic

func transition_indiv(duration: float = 8.0):
	print("Music: Fading out Mechanical (Current: ", mechanical.volume_db, ")")
	print("Music: Fading in Melodic (Current: ", melodic.volume_db, ")")
	var tween = create_tween().set_parallel(true)
	print("STARTING FADE TO INDIVIDUALISM")
	tween.tween_property(mechanical, "volume_db", -70, duration)
	tween.tween_property(melodic, "volume_db", 0, duration)
	tween.finished.connect(func(): print("Music: Transition Complete!"))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mechanical.play()
	melodic.play()
	mechanical.volume_db = 0
	melodic.volume_db = -60
