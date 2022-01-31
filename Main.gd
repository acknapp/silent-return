extends Node

onready var player := $YSort/Player

const starting_positions := {}

signal artifact_returned(pedestal_name)

func _ready():

	_save_initial_positions()

	player.connect("die", self, "_on_player_die")

func _on_player_die():
	reset_game()

func _save_initial_positions():
	starting_positions[player] = player.position

	for artifact in get_tree().get_nodes_in_group("artifact"):
		starting_positions[artifact] = artifact.position

func reset_game():
	player.position	= starting_positions[player]

	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.reset()

	for artifact in get_tree().get_nodes_in_group("artifact"):
		artifact.position = starting_positions[artifact]
