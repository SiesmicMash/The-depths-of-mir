extends Area2D


var player_on_ladder: bool = false
signal ladder_used

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("climb_down_ladder"):
		if player_on_ladder:
			ladder_used.emit()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_on_ladder = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_on_ladder = false
