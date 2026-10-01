extends RefCounted
## Caminhos em coordenadas da sala, com folga para o colisor circular do guarda.
const CELL := 20.0
const CLEARANCE := 15.0
var grid := AStarGrid2D.new()
var obstacles: Array[Rect2] = []
var bounds := Rect2(30, 65, 1140, 515).grow(-CLEARANCE)

func build(props: Array) -> void:
	grid.region = Rect2i(0, 0, 60, 30)
	grid.cell_size = Vector2(CELL, CELL)
	grid.offset = Vector2(CELL / 2, CELL / 2)
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	grid.update()
	obstacles.clear()
	for prop in props:
		var values: Array = prop.solid
		obstacles.append(Rect2(values[0], values[1], values[2], values[3]).grow(CLEARANCE))
	for x in range(60):
		for y in range(30):
			var id := Vector2i(x, y)
			grid.set_point_solid(id, not _walkable(grid.get_point_position(id)))

func _walkable(point: Vector2) -> bool:
	if not bounds.has_point(point):
		return false
	for rect in obstacles:
		if rect.has_point(point):
			return false
	return true

func _clear_segment(from: Vector2, to: Vector2) -> bool:
	if not _walkable(from) or not _walkable(to):
		return false
	for rect in obstacles:
		var corners := [rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]
		for i in range(4):
			if Geometry2D.segment_intersects_segment(from, to, corners[i], corners[(i + 1) % 4]) != null:
				return false
	return true

func _nearest_cell(point: Vector2) -> Vector2i:
	var best := Vector2i(-1, -1)
	var shortest := INF
	for x in range(60):
		for y in range(30):
			var id := Vector2i(x, y)
			if grid.is_point_solid(id):
				continue
			var center := grid.get_point_position(id)
			var distance := point.distance_squared_to(center)
			if distance < shortest and _clear_segment(point, center):
				shortest = distance
				best = id
	return best

func find_path(from: Vector2, to: Vector2) -> PackedVector2Array:
	if _clear_segment(from, to):
		return PackedVector2Array([to])
	var start := _nearest_cell(from)
	var end := _nearest_cell(to)
	if start.x < 0 or end.x < 0:
		return PackedVector2Array()
	var path := grid.get_point_path(start, end)
	if not path.is_empty():
		path.append(to)
		# Remove centros anteriores ao personagem e encurta trechos livres.
		while path.size() > 1 and _clear_segment(from, path[1]):
			path.remove_at(0)
	return path
