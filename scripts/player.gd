extends CharacterBody2D
## Placeholder vetorial independente: substitua _draw por AnimatedSprite2D.

const WALK_SPEED := 210.0
const SNEAK_SPEED := 105.0
var enabled := false
var facing := 1.0
var step := 0.0
var sneaking := false

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	var collider := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 13
	collider.shape = shape
	add_child(collider)
	z_index = 10

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down") if enabled else Vector2.ZERO
	sneaking = Input.is_action_pressed("sneak")
	velocity = direction * (SNEAK_SPEED if sneaking else WALK_SPEED)
	move_and_slide()
	if direction.x != 0:
		facing = signf(direction.x)
	step += delta * (14.0 if velocity.length() > 1 else 2.0)
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2(0, 9), 21, Color(0, 0, 0, 0.22))
	draw_set_transform(Vector2(0, sin(step) * 1.4), 0, Vector2(facing, 1))
	var blue := Color("4ee0ed")
	draw_colored_polygon(PackedVector2Array([Vector2(-7, 5),Vector2(-32, 3),Vector2(-42,-9),Vector2(-35,-23),Vector2(-22,-14)]), blue)
	draw_colored_polygon(PackedVector2Array([Vector2(-42,-9),Vector2(-35,-23),Vector2(-31,-10),Vector2(-34,-2)]), Color("d6ffff"))
	draw_circle(Vector2(-3, 0), 17, blue)
	draw_circle(Vector2(13, -7), 16, blue)
	draw_colored_polygon(PackedVector2Array([Vector2(1,-17),Vector2(0,-36),Vector2(13,-21),Vector2(23,-33),Vector2(27,-14)]), blue)
	draw_colored_polygon(PackedVector2Array([Vector2(4,-21),Vector2(4,-29),Vector2(10,-21)]), Color("256c86"))
	draw_colored_polygon(PackedVector2Array([Vector2(13,0),Vector2(33,-3),Vector2(23,9),Vector2(7,9)]), Color("d6ffff"))
	draw_circle(Vector2(31,-4), 3, Color("10283b"))
	draw_circle(Vector2(20,-11), 3, Color("10283b"))
	draw_line(Vector2(-9,9), Vector2(-10,17), blue, 6)
	draw_line(Vector2(8,9), Vector2(9,17), blue, 6)
	draw_set_transform(Vector2.ZERO)
	if sneaking:
		draw_arc(Vector2.ZERO, 29, 0, TAU, 32, Color(0.3,0.9,1,0.35), 1)

