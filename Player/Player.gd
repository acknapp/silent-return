extends KinematicBody2D

signal death
signal disguise_decision_made

enum {
	MOVE,
	TRANSFORM,
	SUBDUE,
	STEAL,
	PLACE
}

export var ACCELERATION = 1
export var MAX_SPEED = 180
export var FRICTION = 1500

onready var whiteTiger = $Sprites/WhiteTiger
onready var greyDragon = $Sprites/GreyDragon
onready var ninja = $Sprites/Ninja
onready var stats = $Health
onready var hurtInvincibilityTimer = $HurtInvincibilityTimer
onready var animationTree = $AnimationTree
onready var animationPlayer = $AnimationPlayer
onready var animationState = animationTree.get("parameters/playback")

# TODO:
var velocity = Vector2.ZERO
var state = MOVE
var transforming = false
var disguise = null
var invincible := false
var artifact_obtained:int = -1 # ArtifactName

signal die()

func _ready():
	disguise = ninja
	hurtInvincibilityTimer.connect("timeout", self, "_on_Hurtbox_invincibility_timeout")
	# TODO: signal connection not yet working. Find a way to indicate that the player has stolen an artifact
	connect("stolen", self, "_on_stolen_artifact")


func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)


func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		if disguise == whiteTiger:
			animationTree.set("parameters/WhiteTigerIdle/blend_position", input_vector)
			animationTree.set("parameters/WhiteTigerWalk/blend_position", input_vector)
			animationState.travel("WhiteTigerWalk")
		elif disguise == greyDragon:
			animationTree.set("parameters/GreyDragonIdle/blend_position", input_vector)
			animationTree.set("parameters/GreyDragonWalk/blend_position", input_vector)
			animationState.travel("GreyDragonWalk")
		else:
			animationTree.set("parameters/NinjaIdle/blend_position", input_vector)
			animationTree.set("parameters/NinjaWalk/blend_position", input_vector)
			animationState.travel("NinjaWalk")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("NinjaIdle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	velocity = move_and_slide(velocity)


func choose_disguise():
	# TODO: figure out how to make the game wait for a player to press the button
	if Input.is_action_pressed("disguise_dragon"):
		disguise = greyDragon
		hide_player()
		emit_signal("disguise_decision_made")
	elif Input.is_action_pressed("disguise_tiger"):
		hide_player()
		disguise = whiteTiger
		emit_signal("disguise_decision_made")
	elif Input.is_action_pressed("ui_accept"):
		reveal_player()
		disguise = ninja
		emit_signal("disguise_decision_made")


func hide_disguises():
	var all_disguises = [whiteTiger, greyDragon, ninja]
	for disguise in all_disguises:
		disguise.visible = false

func hide_player():
	# TODO: make it so that the enemy clan still is alerted to player
	set_collision_layer_bit(1, false)
	# set_collision_mask_bit(1, false)

func reveal_player():
	set_collision_layer_bit(1, true)


func die():
	# death animation?
	emit_signal("die")


func _on_ChangingHitBox_area_entered(area):
	hide_disguises()
	choose_disguise()
	# yield(choose_disguise(), "disguise_decision_made") # Doesn't work
	$ChangingHitBox/ChangingTimer.start()


func _on_ChangingTimer_timeout():
	disguise.visible = true


func _on_Hurtbox_invincibility_timeout():
	invincible = false


func hurt():
	printerr("HURT")  # DEBUG
	# play hurt animation
	# bounce away?
	stats.health = stats.health - 1
	if stats.health <= 0:
		die()
		return

	invincible = true

func _on_stolen_artifact(artifact_name:int): # ArtifactName
	print("artifact stolen") # DEBUG
	artifact_obtained = artifact_name
