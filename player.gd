extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_velocity: float = -350.0
@export var gravity: float = 900.0

@export var dash_speed: float = 600.0
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 0.5

var is_dashing: bool = false
var can_dash: bool = true
var last_direction: float = 1.0


func _physics_process(delta: float) -> void:
	var direction = Input.get_axis("move_left", "move_right")

	if direction > 0:
		$AnimatedSprite2D.flip_h = false;
		last_direction =  1.0;
	elif direction < 0:
		$AnimatedSprite2D.flip_h = true;
		last_direction = -1.0;

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
		$AnimatedSprite2D.play("idle")
