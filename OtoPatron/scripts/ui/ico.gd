class_name Ico
extends Control
## Prosedürel (çizilen) tutarlı ikon seti. 24x24 ızgarada tanımlıdır.

var kind: String = "home"
var color: Color = Color("8d96a8")


func _init(k: String = "home", c: Color = Color("8d96a8"), sz: float = 28.0) -> void:
	kind = k
	color = UI.resolve(c)
	custom_minimum_size = Vector2(sz, sz)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_color(c: Color) -> void:
	color = UI.resolve(c)
	queue_redraw()


func _draw() -> void:
	var u := minf(size.x, size.y) / 24.0
	if u <= 0.0:
		return
	draw_set_transform(Vector2((size.x - 24.0 * u) / 2.0, (size.y - 24.0 * u) / 2.0), 0.0, Vector2(u, u))
	var c := color
	var w := 2.0
	match kind:
		"diamond":
			draw_polyline(PackedVector2Array([Vector2(3,8),Vector2(7,3),Vector2(17,3),Vector2(21,8),Vector2(12,21),Vector2(3,8)]), c, w, true)
			draw_line(Vector2(3,8),Vector2(21,8),c,1.4,true)
			draw_polyline(PackedVector2Array([Vector2(7,3),Vector2(9,8),Vector2(12,21),Vector2(15,8),Vector2(17,3)]),c,1.4,true)
		"home":
			draw_polyline(PackedVector2Array([Vector2(3, 12), Vector2(12, 3.5), Vector2(21, 12)]), c, w)
			draw_polyline(PackedVector2Array([Vector2(5.5, 10.5), Vector2(5.5, 20.5), Vector2(18.5, 20.5), Vector2(18.5, 10.5)]), c, w)
			draw_rect(Rect2(10, 14, 4, 6.5), c)
		"garage":
			draw_polyline(PackedVector2Array([Vector2(2.5, 9), Vector2(12, 3), Vector2(21.5, 9)]), c, w)
			draw_rect(Rect2(4, 9, 16, 12), c, false, w)
			for i in 3:
				draw_line(Vector2(7, 13 + i * 2.6), Vector2(17, 13 + i * 2.6), c, 1.5)
		"market", "car":
			draw_polyline(PackedVector2Array([Vector2(2.5, 16), Vector2(3.5, 11.5), Vector2(8, 10.5), Vector2(10.5, 6.5), Vector2(16, 6.5), Vector2(19, 10.5), Vector2(21.5, 11.5), Vector2(21.5, 16), Vector2(2.5, 16)]), c, w)
			draw_circle(Vector2(7.5, 17), 2.6, c)
			draw_circle(Vector2(16.5, 17), 2.6, c)
		"school":
			draw_colored_polygon(PackedVector2Array([Vector2(12, 4), Vector2(22, 9), Vector2(12, 14), Vector2(2, 9)]), c)
			draw_polyline(PackedVector2Array([Vector2(6, 12), Vector2(6, 16.5), Vector2(12, 19.5), Vector2(18, 16.5), Vector2(18, 12)]), c, w)
			draw_line(Vector2(21, 10), Vector2(21, 16), c, w)
		"bank":
			draw_colored_polygon(PackedVector2Array([Vector2(12, 3), Vector2(21.5, 8.5), Vector2(2.5, 8.5)]), c)
			for x in [5.5, 10, 14, 18.5]:
				draw_line(Vector2(x, 10.5), Vector2(x, 17.5), c, 2.0)
			draw_line(Vector2(3, 20), Vector2(21, 20), c, w)
		"gear":
			draw_arc(Vector2(12, 12), 6.0, 0, TAU, 28, c, w)
			for i in 8:
				var a := i * TAU / 8.0
				draw_line(Vector2(12, 12) + Vector2.from_angle(a) * 8.0, Vector2(12, 12) + Vector2.from_angle(a) * 10.5, c, 3.0)
			draw_circle(Vector2(12, 12), 2.2, c)
		"user":
			draw_circle(Vector2(12, 8), 4.2, c)
			draw_arc(Vector2(12, 22), 8.0, PI, TAU, 20, c, 2.6)
		"star":
			var pts := PackedVector2Array()
			for i in 10:
				var r := 10.0 if i % 2 == 0 else 4.2
				pts.append(Vector2(12, 12.5) + Vector2.from_angle(-PI / 2 + i * PI / 5) * r)
			draw_colored_polygon(pts, c)
		"wrench":
			draw_line(Vector2(5, 19), Vector2(14, 10), c, 3.0)
			draw_arc(Vector2(16.5, 7.5), 4.2, 0.6, TAU - 0.6, 14, c, 2.6)
		"phone":
			draw_rect(Rect2(6.5, 2.5, 11, 19), c, false, w)
			draw_line(Vector2(10.5, 18.5), Vector2(13.5, 18.5), c, 1.8)
		"coin":
			draw_arc(Vector2(12, 12), 9.5, 0, TAU, 32, c, 2.0)
			draw_line(Vector2(10.5, 6.5), Vector2(10.5, 17.5), c, 2.2)
			draw_line(Vector2(7.5, 11.0), Vector2(16.5, 8.5), c, 2.0)
			draw_line(Vector2(7.5, 14.0), Vector2(16.5, 11.5), c, 2.0)
		"coin_solid":
			draw_circle(Vector2(12, 12), 10.0, c)
			var dark := Color(0.1, 0.07, 0.02)
			draw_line(Vector2(10.5, 6.5), Vector2(10.5, 17.5), dark, 2.2)
			draw_line(Vector2(7.5, 11.0), Vector2(16.5, 8.5), dark, 2.0)
			draw_line(Vector2(7.5, 14.0), Vector2(16.5, 11.5), dark, 2.0)
			draw_arc(Vector2(10.5, 11.5), 6.0, -0.3, 1.9, 10, dark, 2.0)
		"back":
			draw_polyline(PackedVector2Array([Vector2(15, 4.5), Vector2(7.5, 12), Vector2(15, 19.5)]), c, 2.6)
		"check":
			draw_polyline(PackedVector2Array([Vector2(4.5, 12.5), Vector2(10, 18), Vector2(19.5, 6.5)]), c, 3.0)
		"crate":
			draw_rect(Rect2(3.5, 8.5, 17, 12), c, false, w)
			draw_rect(Rect2(2.5, 4.5, 19, 4), c)
			draw_line(Vector2(12, 8.5), Vector2(12, 20.5), c, w)
		"clock":
			draw_arc(Vector2(12, 12), 9.0, 0, TAU, 28, c, w)
			draw_polyline(PackedVector2Array([Vector2(12, 6.5), Vector2(12, 12), Vector2(16, 14)]), c, w)
		"pin":
			draw_circle(Vector2(12, 9.5), 6.0, c)
			draw_colored_polygon(PackedVector2Array([Vector2(7.5, 13.5), Vector2(12, 22), Vector2(16.5, 13.5)]), c)
		"sun":
			draw_circle(Vector2(12, 12), 4.5, c)
			for i in 8:
				var a2 := i * TAU / 8.0
				draw_line(Vector2(12, 12) + Vector2.from_angle(a2) * 7.5, Vector2(12, 12) + Vector2.from_angle(a2) * 10.5, c, 2.0)
		"cloud":
			draw_circle(Vector2(9, 14), 4.5, c)
			draw_circle(Vector2(15, 12.5), 5.5, c)
			draw_rect(Rect2(9, 14, 8, 4.5), c)
		"rain":
			draw_circle(Vector2(9, 9), 4.0, c)
			draw_circle(Vector2(15, 8), 4.8, c)
			draw_rect(Rect2(9, 9, 7, 3.5), c)
			for x in [8.0, 13.0, 18.0]:
				draw_line(Vector2(x, 15), Vector2(x - 2, 20), c, 1.8)
		"snow":
			for i in 3:
				var a3 := i * PI / 3.0
				draw_line(Vector2(12, 12) - Vector2.from_angle(a3) * 9.5, Vector2(12, 12) + Vector2.from_angle(a3) * 9.5, c, 2.0)
		"news":
			draw_rect(Rect2(3.5, 4.5, 17, 15), c, false, w)
			draw_line(Vector2(7, 9), Vector2(17, 9), c, 2.0)
			draw_line(Vector2(7, 13), Vector2(17, 13), c, 1.6)
			draw_line(Vector2(7, 16.5), Vector2(13, 16.5), c, 1.6)
		"save":
			draw_rect(Rect2(4, 4, 16, 16), c, false, w)
			draw_rect(Rect2(8, 4, 8, 5), c)
			draw_rect(Rect2(8, 13, 8, 7), c, false, 1.8)
		"play":
			draw_colored_polygon(PackedVector2Array([Vector2(7, 4), Vector2(20, 12), Vector2(7, 20)]), c)
		"plus":
			draw_line(Vector2(12, 4), Vector2(12, 20), c, 3.0)
			draw_line(Vector2(4, 12), Vector2(20, 12), c, 3.0)
		"minus":
			draw_line(Vector2(4, 12), Vector2(20, 12), c, 3.0)
		"lock":
			draw_rect(Rect2(5, 11, 14, 10), c)
			draw_arc(Vector2(12, 11), 4.5, PI, TAU, 14, c, 2.2)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
