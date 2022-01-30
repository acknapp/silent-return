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

# TODO:
var velocity = Vector2.ZERO
var state = MOVE
var transforming = false
var disguise = null
var invincible := false



func _ready():
	disguise = ninja
	hurtInvincibilityTimer.connect("timeout", self, "_on_Hurtbox_invincibility_timeout")


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
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	velocity = move_and_slide(velocity)

	# TODO: Add steal and transform code here


func choose_disguise():
	# TODO: figure out how to make the game wait for a player to press the button
	if Input.is_action_pressed("disguise_dragon"):
		disguise = greyDragon
		emit_signal("disguise_decision_made")
	elif Input.is_action_pressed("disguise_tiger"):
		disguise = whiteTiger
		emit_signal("disguise_decision_made")
	elif Input.is_action_pressed("ui_accept"):
		disguise = ninja
		emit_signal("disguise_decision_made")


func hide_disguises():
	var all_disguises = [whiteTiger, greyDragon, ninja]
	for disguise in all_disguises:
		disguise.visible = false

func hurt():
	printerr("HURT")
	# play hurt animation
	# bounce away?
	stats.health = stats.health - 1
	invincible = true

func _on_ChangingHitBox_area_entered(area):
	hide_disguises()
	choose_disguise()
	# yield(choose_disguise(), "disguise_decision_made")
	$ChangingHitBox/ChangingTimer.start()


func _on_ChangingTimer_timeout():
	disguise.visible = true

func _on_Hurtbox_invincibility_timeout():
	invincible = false
