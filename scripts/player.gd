extends CharacterBody2D

const Art = preload("res://scripts/character_art.gd")
const WALK_SPEED := 210.0
const SNEAK_SPEED := 105.0
var enabled := false
var facing := 1.0
var sneaking := false
var art: Node2D
var distraction_cooldown := 0.0

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	var collider := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 13
	collider.shape = shape
	add_child(collider)
	art = Art.new()
	add_child(art)
	z_index = 10

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down") if enabled else Vector2.ZERO
	sneaking = enabled and Input.is_action_pressed("sneak")
	velocity = direction * (SNEAK_SPEED if sneaking else WALK_SPEED)
	move_and_slide()
	if direction != Vector2.ZERO:
		art.direction = direction
		if direction.x != 0: facing = signf(direction.x)
	art.moving = velocity.length() > 1
	art.sneaking = sneaking
	art.active = enabled
	if enabled: distraction_cooldown = maxf(0, distraction_cooldown - delta)
