extends Area2D

signal stolen

func _on_Artifact_body_entered(body):
	$Sprite.visible = false
	emit_signal("stolen")
