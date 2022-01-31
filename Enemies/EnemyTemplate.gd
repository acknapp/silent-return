extends KinematicBody2D

const Artifact = preload("res://World/Artifact.gd")

# TODO: knockout effect
export var min_speed = 50
export var max_speed = 125
export var ACCELERATION = 10
export var FRICTION = 200
export var SOFTCOLLISION = 10
export var WANDER_TARGET_RANGE = 4
export var KNOCKBACK = 120 # maybe not needed?

enum {
	IDLE,
	WANDER,
	CHASE,
	RETURN_TO_BASE,
} # TODO: add path2d

const FACING = {
	Vector2(1, 0): 'Right',
	Vector2(-1, 0): 'Left',
	Vector2(0, 1): 'Down',
	Vector2(0, -1): 'Up',
}

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

var state = CHASE

onready var main = get_tree().root.get_node("Main")
onready var stats = $Health
onready var playerDetectionZone = $PlayerDetectionZone
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var hurtbox = $Hurtbox
onready var animation = $AnimatedSprite
onready var animationPlayer = $AnimationPlayer
onready var return_base_position_2d = $ReturnBasePosition2D
onready var return_base_position = return_base_position_2d.global_position

signal subdued

onready var original_position = position

func _ready():
	state = pick_random_state([IDLE, WANDER])
	main.connect("artifact_returned", self, "_on_artifact_returned")

func reset():
	position = original_position
	velocity = Vector2.ZERO
	knockback = Vector2.ZERO
	state = pick_random_state([IDLE, WANDER])

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()


func _physics_process(delta):
	# Are enemies going to die?  Maybe not needed?
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	match state:
		IDLE:
			animation.play("idle")
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()

			if wanderController.get_time_left() == 0:
				update_wander()
		WANDER:
			animation.play("idle")
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
			accelerate_towards_point(wanderController.target_position, delta)
			if global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_RANGE:
				update_wander()
		CHASE:
			animation.play("alert")
			var player = playerDetectionZone.player
			if player != null:
				accelerate_towards_point(player.global_position, delta)
			else:
				state = IDLE
		RETURN_TO_BASE:
			animation.play("idle")
			accelerate_towards_point(return_base_position, delta)

	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)

func _on_HitBox_body_entered(body):
	if body.has_method("hurt"):
		body.hurt()

func get_facing_direction(vec_to_location):
	var facing_vec = get_facing_vector(vec_to_location)
	return FACING[facing_vec]


func get_facing_vector(vec_to_location):
	var min_angle = 360
	var facing_vec = Vector2()
	for vec in FACING.keys:
		var angle = abs(vec_to_location.angle_to(vec))
		if angle < min_angle:
			min_angle = angle
			facing_vec = vec
	return FACING[facing_vec]


func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	var medium_speed = (max_speed + min_speed)/1.5
	velocity = velocity.move_toward(direction * medium_speed, ACCELERATION * delta)


func update_wander():
	if state != RETURN_TO_BASE:
		state = pick_random_state([IDLE, WANDER])
		wanderController.start_wander_timer(rand_range(1, 3))


func seek_player():
	if state != RETURN_TO_BASE:
		if playerDetectionZone.can_see_player():
			$Sounds/PlayerDetected.play()
			state = CHASE

func _on_artifact_returned(pedestal_name:int):
	if state != RETURN_TO_BASE:
		if self.is_in_group("enemy_white_tiger") and pedestal_name == Artifact.ArtifactName.WhiteTiger:
			state = RETURN_TO_BASE

		if self.is_in_group("enemy_grey_dragon") and pedestal_name == Artifact.ArtifactName.GreyDragon:
			state = RETURN_TO_BASE
