extends Button


func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://Main Menu/instructions.tscn")


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://node_2d.tscn")


func _on_button_3_pressed() -> void:
	get_tree().quit()
