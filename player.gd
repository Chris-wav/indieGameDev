extends CharacterBody2D

@export var spawn_position: Vector2
@export var move_speed: float = 220.0
@export var crouch_speed: float = 90.0
@export var jump_velocity: float = -360.0
@export var wall_jump_push: float = 220.0
@export var wall_jump_lock_time: float = 0.15
@export var wall_jump_input_lock_time: float = 1.5
@export var gravity: float = 900.0

@export var dash_speed: float = 600.0
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 0.5
@export var death_delay: float = 2.0
@export var death_y: float = 1000.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_dashing: bool = false
var can_dash: bool = true
var last_direction: float = 1.0
var wall_jump_lock_timer: float = 0.0
var wall_jump_input_lock_timer: float = 0.0
var wall_jump_direction: float = 0.0
var fall_death_timer: float = 0.0


func _ready() -> void:
	spawn_position = global_position


func _physics_process(delta: float) -> void:
	_death(delta)

	wall_jump_lock_timer = maxf(wall_jump_lock_timer - delta, 0.0)
	wall_jump_input_lock_timer = maxf(wall_jump_input_lock_timer - delta, 0.0)
	if wall_jump_direction != 0.0 and (wall_jump_input_lock_timer == 0.0 or velocity.y >= 0.0):
		wall_jump_direction = 0.0

	if is_on_floor():
		wall_jump_direction = 0.0

	var direction: float = Input.get_axis("move_left", "move_right")
	if wall_jump_direction != 0.0 and not is_on_floor() and sign(direction) != wall_jump_direction:
		direction = 0.0

	if direction != 0.0:
		animated_sprite.flip_h = direction < 0.0
		last_direction = direction

	if Input.is_action_just_pressed("dash") and can_dash:
		start_dash()

	if is_dashing:
		velocity.x = sign(last_direction) * dash_speed
		velocity.y = 0.0
		move_and_slide()
		update_animations(direction)
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	var is_crouching: bool = Input.is_action_pressed("crouch") and is_on_floor()
	var wall_normal: Vector2 = get_wall_normal() if is_on_wall() else Vector2.ZERO
	var is_wall_clinging: bool = wall_normal.x != 0.0 and not is_on_floor() and wall_jump_lock_timer == 0.0
	var did_wall_jump: bool = false

	if Input.is_action_just_pressed("jump"):
		if is_on_floor() and not is_crouching:
			velocity.y = jump_velocity
		elif is_wall_clinging:
			did_wall_jump = wall_jump(wall_normal)

	if is_wall_clinging and not did_wall_jump:
		velocity = Vector2.ZERO
	elif is_crouching:
		velocity.x = 0.0
	elif wall_jump_lock_timer == 0.0:
		velocity.x = direction * move_speed

	move_and_slide()
	update_animations(direction)


func start_dash() -> void:
	is_dashing = true
	can_dash = false

	await get_tree().create_timer(dash_duration).timeout
	is_dashing = false

	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true


func wall_jump(wall_normal: Vector2) -> bool:
	velocity.y = jump_velocity
	velocity.x = wall_normal.x * wall_jump_push
	wall_jump_lock_timer = wall_jump_lock_time
	wall_jump_input_lock_timer = wall_jump_input_lock_time
	wall_jump_direction = sign(velocity.x)
	last_direction = wall_jump_direction
	return true


func update_animations(direction: float) -> void:
	if is_dashing and _has_animation("dash"):
		animated_sprite.play("dash")
	elif not is_on_floor():
		if velocity.y > 0.0 and _has_animation("fall"):
			animated_sprite.play("fall")
		else:
			animated_sprite.play("jump")
	elif Input.is_action_pressed("crouch"):
		animated_sprite.play("crouch")
	elif direction != 0.0:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")


func _has_animation(animation_name: StringName) -> bool:
	return animated_sprite.sprite_frames != null and animated_sprite.sprite_frames.has_animation(animation_name)


func _death(delta: float) -> void:
	if global_position.y > death_y:
		fall_death_timer += delta
		if fall_death_timer >= death_delay:
			respawn()
	else:
		fall_death_timer = 0.0


func respawn() -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
	fall_death_timer = 0.0
	is_dashing = false
	can_dash = true
	wall_jump_lock_timer = 0.0
	wall_jump_input_lock_timer = 0.0
	wall_jump_direction = 0.0
