extends CanvasLayer

func _on_RestartButton_pressed():
	get_tree().reload_current_scene()
	
func format_time(total_seconds: float) -> String:
	var minutes = int(total_seconds) / 60
	var seconds = int(total_seconds) % 60
	return "%02d:%02d" % [minutes, seconds]

func show_results(times: Dictionary):
	self.visible = true
	for i in range(1, 4):
		var label = get_node("Player" + str(i) + "Label")
		var formatted = format_time(times[i])
		label.text = "Player " + str(i) + " awakened in " + formatted
