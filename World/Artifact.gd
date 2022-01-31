extends Area2D

enum ArtifactName {
	WhiteTiger,
	GreyDragon,
}

export(ArtifactName) var artifact_name:int

signal stolen(artifact_name)

func _on_Artifact_body_entered(body):
	$StealArtifact.play()
	$Sprite.visible = false
	emit_signal("stolen", artifact_name)
