extends CharacterBody2D

@export var move_speed: float = 220.0
@export var crouch_speed: float = 90.0
@export var jump_velocity: float = -360.0
@export var wall_jump_push: float = 220.0
@export var wall_jump_lock_time: float = 0.15
@export var gravity: float = 900.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var wall_jump_lock_timer: float = 0.0
var wall_jump_direction: float = 0.0


func _physics_process(delta: float) -> void:
	wall_jump_lock_timer = maxf(wall_jump_lock_timer - delta, 0.0)
	if is_on_floor():
		wall_jump_direction = 0.0

	if not is_on_floor():
		velocity.y += gravity * delta

	var direction: float = Input.get_axis("move_left", "move_right")
	var is_crouching := Input.is_action_pressed("crouch") and is_on_floor()
	var wall_normal: Vector2 = get_wall_normal() if is_on_wall() else Vector2.ZERO
	var is_pressing_into_wall: bool = wall_normal.x != 0.0 and sign(direction) == sign(-wall_normal.x)
	var is_wall_clinging: bool = is_on_wall() and not is_on_floor() and is_pressing_into_wall and wall_jump_lock_timer == 0.0
	var can_wall_jump: bool = is_wall_clinging
	var did_wall_jump := false

	if wall_jump_direction != 0.0 and not is_on_floor() and sign(direction) != wall_jump_direction:
		direction = 0.0

	if Input.is_action_just_pressed("jump"):
		if is_on_floor() and not is_crouching:
			velocity.y = jump_velocity
		elif can_wall_jump:
			velocity.y = jump_velocity
			velocity.x = wall_normal.x * wall_jump_push
			wall_jump_lock_timer = wall_jump_lock_time
			wall_jump_direction = sign(velocity.x)
			did_wall_jump = true

	var target_speed := crouch_speed if is_crouching else move_speed
	if is_wall_clinging and not did_wall_jump:
		velocity = Vector2.ZERO
	elif is_crouching:
		velocity.x = 0.0
	elif wall_jump_lock_timer == 0.0 and (not can_wall_jump or direction != 0.0):
		velocity.x = direction * target_speed

	if direction != 0.0:
		animated_sprite.flip_h = direction < 0.0

	move_and_slide()
	_update_animation(direction, is_crouching)


func _update_animation(direction: float, is_crouching: bool) -> void:
	if not is_on_floor():
		animated_sprite.play("jump")
		return

	if is_crouching:
		animated_sprite.play("crouch")
		return

	if direction != 0.0:
		animated_sprite.play("run")
		return

	animated_sprite.play("idle")
