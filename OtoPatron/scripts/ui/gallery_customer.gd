class_name GalleryCustomer
extends Button
var phase: float = 0
func _init() -> void:
	custom_minimum_size = Vector2(32,42)
	flat = true
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
func animate(time: float, walking: bool) -> void:
	var next: float = sin(time*6)*3 if walking else 0.0
	if absf(next-phase)>.3:
		phase=next
		queue_redraw()
func _draw() -> void:
	var c := Vector2(size.x*.5,26)
	draw_circle(c+Vector2(0,-15),5,Color("e4b995"),true,-1,true)
	draw_line(c+Vector2(0,-9),c+Vector2(0,2),Color("426c81"),9,true)
	draw_line(c+Vector2(0,2),c+Vector2(-5+phase,13),Color("253b58"),3,true)
	draw_line(c+Vector2(0,2),c+Vector2(5-phase,13),Color("253b58"),3,true)
	draw_line(c+Vector2(-4,-7),c+Vector2(-8-phase,3),Color("e4b995"),2,true)
	draw_line(c+Vector2(4,-7),c+Vector2(8+phase,3),Color("e4b995"),2,true)
	draw_circle(c+Vector2(0,-25),2,Color("e9cc7c"))
