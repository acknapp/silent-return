extends Area2D

export (float) var target_turn_speed

var player = null

func can_see_player():
	return player != null

func _on_PlayerDetectionZone_body_entered(body):
	player = body

func _on_PlayerDetectionZone_body_exited(body):
	player = null
