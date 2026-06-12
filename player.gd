extends CharacterBody2D
<<<<<<< Updated upstream

@export var speed: float = 200.0
@export var jump_velocity: float = -350.0
=======
@export var spawn_position: Vector2
@export var move_speed: float = 220.0
@export var crouch_speed: float = 90.0
@export var jump_velocity: float = -360.0
@export var wall_jump_push: float = 220.0
@export var wall_jump_lock_time: float = 0.15
>>>>>>> Stashed changes
@export var gravity: float = 900.0

@export var dash_speed: float = 600.0
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 0.5

<<<<<<< Updated upstream
=======
@export var death_delay: float = 2.0
@export var death_y: float = 1000.0

var fall_death_timer: float = 0.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

>>>>>>> Stashed changes
var is_dashing: bool = false
var can_dash: bool = true
var last_direction: float = 1.0

func _ready() -> void:
	spawn_position = global_position;

func _physics_process(delta: float) -> void:
<<<<<<< Updated upstream
	var direction = Input.get_axis("move_left", "move_right")

	if direction > 0:
		$AnimatedSprite2D.flip_h = false;
		last_direction =  1.0;
	elif direction < 0:
		$AnimatedSprite2D.flip_h = true;
		last_direction = -1.0;
=======
	_death(delta)

	wall_jump_lock_timer = maxf(wall_jump_lock_timer - delta, 0.0)

	if is_on_floor():
		wall_jump_direction = 0.0

	var direction: float = Input.get_axis("move_left", "move_right")

	if wall_jump_direction != 0.0 and not is_on_floor() and sign(direction) != wall_jump_direction:
		direction = 0.0

	if direction != 0.0:
		animated_sprite.flip_h = direction < 0.0
		last_direction = direction
>>>>>>> Stashed changes

	if Input.is_action_just_pressed("dash") and can_dash:
		start_dash()

	if is_dashing:
		velocity.x = last_direction * dash_speed
		velocity.y = 0
		move_and_slide()
		return

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Movement
	if direction != 0:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	move_and_slide()


	update_animations(direction)


func start_dash() -> void:
	is_dashing = true
	can_dash = false

	await get_tree().create_timer(dash_duration).timeout
	is_dashing = false

	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true


func update_animations(direction: float) -> void:
	if not has_node("AnimatedSprite2D"):
		return

	if is_dashing:
		$AnimatedSprite2D.play("dash")
	elif not is_on_floor():
		if velocity.y < 0:
			$AnimatedSprite2D.play("jump")
		else:
			$AnimatedSprite2D.play("fall")
	elif direction != 0:
		$AnimatedSprite2D.play("run")
	else:
<<<<<<< Updated upstream
		$AnimatedSprite2D.play("idle")
=======
		animated_sprite.play("idle")


func _has_animation(name: StringName) -> bool:
	return animated_sprite.sprite_frames != null and animated_sprite.sprite_frames.has_animation(name)


func _death(delta: float) -> void:
	if global_position.y > death_y:
		fall_death_timer += delta

		if fall_death_timer >= death_delay:
			get_tree().reload_current_scene()
			respawn();
	else:
		fall_death_timer = 0.0

func respawn() -> void:
	global_position = spawn_position;
	velocity = Vector2.ZERO;
	fall_death_timer = 0;
	is_dashing = false;
	can_dash = true;
>>>>>>> Stashed changes
