extends CharacterBody2D

@export var speed: float = 80.0
@export var direction: float = -1.0
@export var gravity: float = 900.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var floor_detector: RayCast2D = $FloorDetector


func _physics_process(delta: float) -> void:
	if direction < 0:
		animated_sprite.flip_h = true;
	if not is_on_floor():
		velocity.y += gravity * delta

	velocity.x = direction * speed

	move_and_slide()

	if is_on_wall() or (is_on_floor() and not floor_detector.is_colliding()):
		flip_direction()
	_update_animations()


func flip_direction() -> void:
	direction *= -1
	animated_sprite.flip_h = direction < 0
	floor_detector.target_position.x *= -1


func _update_animations():
	if velocity.x != 0:
		animated_sprite.play('move');
