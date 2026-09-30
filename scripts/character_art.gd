extends Node2D
## Arte vetorial original desta reconstrução; animação independente de imagens externas.
var kind := "fox"
var direction := Vector2.RIGHT
var moving := false
var sneaking := false
var alert := false
var transformed := false
var active := true
var time := 0.0
var flash := 0.0

func _process(delta: float) -> void:
	if active:
		time += delta * (10.0 if moving else 2.0)
	flash = maxf(0.0, flash - delta)
	queue_redraw()

func _draw() -> void:
	draw_ellipse_shadow()
	var bob := sin(time * 2.0) * (1.5 if moving else 0.5)
	var flip := -1.0 if direction.x < -0.1 else 1.0
	draw_set_transform(Vector2(0, bob + (4.0 if sneaking else 0.0)), 0, Vector2(flip, 0.8 if sneaking else 1.0))
	if kind == "fox" or transformed:
		_draw_fox()
	else:
		_draw_human()
	draw_set_transform(Vector2.ZERO)
	if flash > 0:
		draw_arc(Vector2.ZERO, 24 + (1.0-flash) * 60, 0, TAU, 48, Color(0.3,1,0.95,flash), 3)

func draw_ellipse_shadow() -> void:
	draw_set_transform(Vector2(0,15),0,Vector2(1,0.35))
	draw_circle(Vector2.ZERO, 23, Color(0,0,0,0.25))
	draw_set_transform(Vector2.ZERO)

func _draw_fox() -> void:
	var fur := Color("4ee0ed") if not transformed else Color("f2ae68")
	var dark := Color("246b88") if not transformed else Color("995634")
	var tail := sin(time) * (6.0 if moving else 3.0)
	draw_colored_polygon(PackedVector2Array([Vector2(-8,4),Vector2(-29,4+tail),Vector2(-42,-7+tail),Vector2(-37,-24+tail),Vector2(-23,-14)]),dark)
	draw_colored_polygon(PackedVector2Array([Vector2(-8,0),Vector2(-28,0+tail),Vector2(-39,-9+tail),Vector2(-35,-21+tail),Vector2(-22,-12)]),fur)
	draw_colored_polygon(PackedVector2Array([Vector2(-39,-9+tail),Vector2(-35,-21+tail),Vector2(-30,-11+tail),Vector2(-33,-3+tail)]),Color("e4ffff"))
	for leg in range(4):
		var x := -11.0 + leg * 7.0
		var stride := sin(time + leg * PI) * 4.0 if moving else 0.0
		draw_line(Vector2(x,4),Vector2(x+stride,17),dark if leg % 2 == 0 else fur,5)
	draw_circle(Vector2(-3,0),16,dark)
	draw_circle(Vector2(-3,-3),15,fur)
	var front := direction.y > 0.5
	var back := direction.y < -0.5
	var head := Vector2(8 if front or back else 13,-9)
	draw_circle(head,15,fur)
	for x in [head.x-11,head.x+7]:
		draw_colored_polygon(PackedVector2Array([Vector2(x,-17),Vector2(x-3,-34),Vector2(x+9,-21)]),fur)
		draw_colored_polygon(PackedVector2Array([Vector2(x+2,-21),Vector2(x,-29),Vector2(x+6,-22)]),dark)
	if not back:
		draw_colored_polygon(PackedVector2Array([head+Vector2(0,6),head+Vector2(20 if not front else 5,8),head+Vector2(9,17),head+Vector2(-5,12)]),Color("e4ffff"))
		draw_circle(head+Vector2(18 if not front else 4,8),2.5,Color("10283b"))
		draw_circle(head+Vector2(7,0),2.5,Color("10283b"))
		if front: draw_circle(head+Vector2(-5,0),2.5,Color("10283b"))
	if not transformed:
		draw_circle(Vector2(-5,-2),3,Color("d4fff4"))
		draw_arc(Vector2(-5,-2),5,0,TAU,16,Color(0.5,1,0.95,0.5),1)

func _draw_human() -> void:
	var coat := Color("edf5ee") if kind == "scientist" else Color("657f9f")
	var stride := sin(time) * 4 if moving else 0.0
	draw_line(Vector2(-6,6),Vector2(-7+stride,19),Color("283c52"),6)
	draw_line(Vector2(6,6),Vector2(7-stride,19),Color("283c52"),6)
	draw_rect(Rect2(-12,-8,24,22),coat)
	draw_line(Vector2(-14,-4),Vector2(-16,7-stride),coat,5)
	draw_line(Vector2(14,-4),Vector2(16,7+stride),coat,5)
	draw_circle(Vector2(0,-18),10,Color("e7bd98"))
	if kind == "scientist":
		draw_line(Vector2(-8,-20),Vector2(8,-20),Color("203b52"),2)
		draw_rect(Rect2(-8,0,5,5),Color("68d8da"))
	else:
		draw_rect(Rect2(-11,-28,22,7),Color("304b6b"))
		draw_line(Vector2(4,-2),direction*24,Color("ffe1a3"),4)
	if alert:
		draw_string(ThemeDB.fallback_font,Vector2(-4,-38),"!",HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("ffbd69"))
