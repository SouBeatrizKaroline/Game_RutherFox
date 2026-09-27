extends Node2D

var id := ""
var title := ""
var kind := "part"
var destination := ""
var available := true
var nearby := false
var clock := 0.0

func _ready() -> void:
	z_index = 15

func _process(delta: float) -> void:
	clock += delta
	queue_redraw()

func _draw() -> void:
	if not available:
		return
	var color := Color("68e8e1") if kind == "part" else Color("edcc8c")
	if kind == "door":
		draw_style_box(_box(color), Rect2(-23,-29,46,58))
		draw_line(Vector2(-9,0),Vector2(9,0),color,2)
		draw_line(Vector2(9,0),Vector2(3,-6),color,2)
		draw_line(Vector2(9,0),Vector2(3,6),color,2)
	elif kind == "terminal":
		draw_style_box(_box(color), Rect2(-22,-22,44,44))
		draw_string(ThemeDB.fallback_font,Vector2(-12,7),">_",HORIZONTAL_ALIGNMENT_LEFT,-1,22,color)
	else:
		draw_circle(Vector2.ZERO, 19 + sin(clock * 3) * 2, Color(color,0.12))
		var diamond := PackedVector2Array([Vector2(0,-12),Vector2(11,0),Vector2(0,12),Vector2(-11,0),Vector2(0,-12)])
		draw_colored_polygon(diamond, Color("0d3644"))
		draw_polyline(diamond,color,2)
		draw_circle(Vector2.ZERO,3,color)
	if nearby:
		draw_circle(Vector2(0,-42),12,Color("13232f"))
		draw_string(ThemeDB.fallback_font,Vector2(-5,-37),"E",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color.WHITE)

func _box(color: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color("102330")
	box.border_color = color
	box.set_border_width_all(2)
	box.set_corner_radius_all(6)
	return box

