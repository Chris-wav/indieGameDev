extends CharacterBody2D

@export var move_speed: float = 220.0
@export var crouch_speed: float = 90.0
@export var jump_velocity: float = -360.0
@export var gravity: float = 900.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	var direction := Input.get_axis("move_left", "move_right")
	var is_crouching := Input.is_action_pressed("crouch") and is_on_floor()

	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_crouching:
		velocity.y = jump_velocity

	var target_speed := crouch_speed if is_crouching else move_speed
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
