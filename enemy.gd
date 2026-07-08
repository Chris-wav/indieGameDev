extends CharacterBody2D

@export var speed: float = 80.0
@export var direction: float = -1.0
@export var gravity: float = 900.0
@export var chase_speed: float = 140.0
@export var attack_damage: float = 10.0
@export var attack_cooldown: float = 0.6
@export var attack_hit_frame: int = 2

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var floor_detector: RayCast2D = $FloorDetector
@onready var detection_area: Area2D = $Area2D
@onready var damage_area: Area2D = $DamageArea

var is_attacking: bool = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_attacking:
		velocity.x = 0.0
	elif _can_attack_player():
		velocity.x = 0.0
		start_attack()
	else:
		velocity.x = direction * speed

	move_and_slide()

	if not is_attacking and (is_on_wall() or (is_on_floor() and not floor_detector.is_colliding())):
		flip_direction()
	_update_animations()


func flip_direction() -> void:
	set_direction(direction * -1.0)


func set_direction(new_direction: float) -> void:
	if new_direction == 0.0:
		return

	direction = sign(new_direction)
	animated_sprite.flip_h = direction < 0.0
	floor_detector.target_position.x = absf(floor_detector.target_position.x) * direction


func face_towards(target_x: float) -> void:
	set_direction(target_x - detection_area.global_position.x)


func _update_animations():
	if is_attacking:
		if animated_sprite.animation != "attack":
			animated_sprite.play("attack")
	elif velocity.x != 0:
		if animated_sprite.animation != "move":
			animated_sprite.play("move")


func _can_attack_player() -> bool:
	for body in damage_area.get_overlapping_bodies():
		if body is CharacterBody2D and "Player" in body.name:
			return true
	return false


func start_attack() -> void:
	if is_attacking:
		return

	is_attacking = true
	animated_sprite.play("attack")
	animated_sprite.set_frame_and_progress(0, 0.0)

	while animated_sprite.frame < attack_hit_frame:
		await animated_sprite.frame_changed

	for body in damage_area.get_overlapping_bodies():
		if body is CharacterBody2D and "Player" in body.name and body.has_method("_damage"):
			body._damage(attack_damage)
			break

	if animated_sprite.animation == "attack" and animated_sprite.is_playing():
		await animated_sprite.animation_finished

	await get_tree().create_timer(attack_cooldown).timeout
	is_attacking = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if "Player" in body.name:
		speed = chase_speed
		face_towards(body.global_position.x)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if "Player" in body.name:
		speed = 80.0
	
