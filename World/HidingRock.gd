extends Area2D



func _on_HidingRock_area_entered(area):
	$AnimatedSprite.play("hiding")




func _on_HidingRock_area_exited(area):
	$AnimatedSprite.play("regular")
