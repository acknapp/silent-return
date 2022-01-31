extends Area2D

const Player = preload("res://Player/Player.gd")
const Artifact = preload("res://World/Artifact.gd")

onready var main = get_tree().root.get_node("Main")
onready var stolen_artifact = $StolenArtifact

export(Artifact.ArtifactName) var pedestal_name:int

func _ready():
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(player):
	if player is Player and player.artifact_obtained >= 0:
		if player.artifact_obtained == Artifact.ArtifactName.WhiteTiger and \
			pedestal_name == Artifact.ArtifactName.GreyDragon:
				main.emit_signal("artifact_returned", pedestal_name)
				stolen_artifact.show()
		if player.artifact_obtained == Artifact.ArtifactName.GreyDragon and \
			pedestal_name == Artifact.ArtifactName.WhiteTiger:
				main.emit_signal("artifact_returned", pedestal_name)
				stolen_artifact.show()
