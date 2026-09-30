extends CharacterBody2D
## Patrulha, investigação, perseguição e busca com colisão física.
const Art = preload("res://scripts/character_art.gd")
enum Mode { PATROL, INVESTIGATE, CHASE, SEARCH, RETURN }
var route: Array[Vector2] = []
var waypoint := 1
var speed := 72.0
var facing := Vector2.RIGHT
var sees_player := false
var enabled := false
var player: CharacterBody2D
var vision_range := 255.0
var half_angle := 0.58
var mode := Mode.PATROL
var target := Vector2.ZERO
var search_time := 0.0
var stuck_time := 0.0
var role := "guard"
var transformed := false
var art: Node2D
var cone := PackedVector2Array()

func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	var collider := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 13
	collider.shape = shape
	add_child(collider)
	art = Art.new()
	art.kind = role
	add_child(art)
	z_index = 8

func investigate(point: Vector2) -> void:
	if transformed or mode == Mode.CHASE: return
	target = point
	mode = Mode.INVESTIGATE
	stuck_time = 0

func transform_to_fox() -> void:
	transformed = true
	sees_player = false
	velocity = Vector2.ZERO
	art.transformed = true
	art.flash = 1.0
	art.alert = false
	queue_redraw()

func _physics_process(delta: float) -> void:
	sees_player = false
	art.active = enabled
	if not enabled or transformed or route.size() < 2:
		art.moving = false
		return
	var radius := vision_range * (0.72 if player.sneaking else 1.0)
	var to_player := player.global_position - global_position
	if to_player.length() < radius and absf(facing.angle_to(to_player)) < half_angle:
		var ray := PhysicsRayQueryParameters2D.create(global_position, player.global_position, 1)
		sees_player = get_world_2d().direct_space_state.intersect_ray(ray).is_empty()
	if sees_player:
		mode = Mode.CHASE
		target = player.position
		search_time = 2.5
	elif mode == Mode.CHASE:
		mode = Mode.INVESTIGATE
		stuck_time = 0
	if mode == Mode.PATROL or mode == Mode.RETURN:
		target = route[waypoint]
	var offset := target - position
	if offset.length() < 5 and mode != Mode.SEARCH:
		if mode == Mode.PATROL or mode == Mode.RETURN:
			mode = Mode.PATROL
			waypoint = (waypoint + 1) % route.size()
		else:
			mode = Mode.SEARCH
			search_time = 2.5
	if mode == Mode.SEARCH:
		search_time -= delta
		facing = facing.rotated(delta * 1.8)
		velocity = Vector2.ZERO
		if search_time <= 0: _return_to_route()
	else:
		if offset.length() > 1: facing = offset.normalized()
		velocity = facing * speed * (1.65 if mode == Mode.CHASE else 1.0)
		var before := position
		move_and_slide()
		stuck_time = stuck_time + delta if position.distance_to(before) < 0.1 and speed > 0 else 0.0
		if stuck_time > 1.2:
			if mode == Mode.PATROL or mode == Mode.RETURN:
				waypoint = (waypoint + 1) % route.size()
			else:
				mode = Mode.SEARCH
				search_time = 2.5
			stuck_time = 0
	art.direction = facing
	art.moving = velocity.length() > 1
	art.alert = sees_player or mode != Mode.PATROL
	_update_cone()
	queue_redraw()

func _return_to_route() -> void:
	mode = Mode.RETURN
	var closest := INF
	for i in route.size():
		var distance := position.distance_to(route[i])
		if distance < closest:
			closest = distance
			waypoint = i

func _update_cone() -> void:
	cone = PackedVector2Array([Vector2.ZERO])
	for i in range(33):
		var angle := facing.angle() - half_angle + half_angle * 2 * i / 32.0
		var end := global_position + Vector2.from_angle(angle) * vision_range * (0.72 if player.sneaking else 1.0)
		var ray := PhysicsRayQueryParameters2D.create(global_position,end,1)
		var hit := get_world_2d().direct_space_state.intersect_ray(ray)
		cone.append(to_local(hit.position) if not hit.is_empty() else to_local(end))

func _draw() -> void:
	if transformed or cone.size() < 3: return
	draw_colored_polygon(cone,Color(1,0.5,0.2,0.20) if sees_player else Color(1,0.83,0.48,0.10))
