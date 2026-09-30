extends Node2D
var remaining := 1.0
var radius := 180.0
var color := Color("68e8e1")
func _process(delta: float) -> void:
	remaining -= delta
	if remaining <= 0: queue_free()
	queue_redraw()
func _draw() -> void:
	var tint := color
	tint.a = maxf(0,remaining)
	draw_arc(Vector2.ZERO,(1.0-remaining)*radius,0,TAU,64,tint,3)
