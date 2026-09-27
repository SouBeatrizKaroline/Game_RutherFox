extends Node2D
## Patrulha determinística; detecção usa cone e raio bloqueado pelos móveis.

var route: Array[Vector2] = []
var waypoint := 1
var speed := 72.0
var facing := Vector2.RIGHT
var sees_player := false
var enabled := false
var player: CharacterBody2D
var vision_range := 255.0
var half_angle := 0.58

func _ready() -> void:
	z_index = 8

func _physics_process(delta: float) -> void:
	sees_player = false
	if not enabled or route.size() < 2:
		return
	var offset := route[waypoint] - position
	if offset.length() < 4:
		waypoint = (waypoint + 1) % route.size()
	else:
		facing = offset.normalized()
		position = position.move_toward(route[waypoint], speed * delta)
	if is_instance_valid(player):
		var to_player := player.global_position - global_position
		var radius := vision_range * (0.72 if player.sneaking else 1.0)
		if to_player.length() < radius and absf(facing.angle_to(to_player)) < half_angle:
			var ray := PhysicsRayQueryParameters2D.create(global_position, player.global_position, 1)
			sees_player = get_world_2d().direct_space_state.intersect_ray(ray).is_empty()
	queue_redraw()

func _draw() -> void:
	var points := PackedVector2Array([Vector2.ZERO])
	for i in range(25):
		var angle := facing.angle() - half_angle + (half_angle * 2 * i / 24.0)
		points.append(Vector2.from_angle(angle) * vision_range)
	draw_colored_polygon(points, Color(1,0.65,0.25,0.22) if sees_player else Color(1,0.83,0.48,0.10))
	draw_polyline(points, Color(1,0.83,0.48,0.28), 1)
	draw_circle(Vector2(0,6), 19, Color(0,0,0,0.22))
	draw_circle(Vector2.ZERO, 15, Color("d6dbe2"))
	draw_rect(Rect2(-10,0,20,13), Color("748ba5"))
	draw_circle(Vector2(0,-11), 9, Color("edc7a0"))
	draw_line(Vector2.ZERO, facing * 25, Color("ffe1a3"), 5)
	if sees_player:
		draw_string(ThemeDB.fallback_font, Vector2(-4,-31), "!", HORIZONTAL_ALIGNMENT_LEFT,-1,24,Color("ffe1a3"))

