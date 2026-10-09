class_name ShowroomView
extends Control
var _cars: Array = []
func _init() -> void:
	custom_minimum_size = Vector2(0, 158)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_IGNORE
func _ready() -> void:
	for car in Game.cars.slice(0, 3):
		_cars.append(CarDB.texture(str(car["model"])))
func _draw() -> void:
	var width := size.x
	draw_rect(Rect2(0,0,width,158),Color("d8e9ed"))
	for i in 8:
		var x := i * width / 7.0
		draw_rect(Rect2(x,28 + i % 3 * 7, width / 10.0,55),Color("c0d4db"))
	draw_circle(Vector2(width-35,26),14,Color("f1d099"),true,-1,true)
	draw_rect(Rect2(18,51,width-36,71),Color("f8faf9") if Game.garage_cap == 5 else Color("17343e"))
	draw_rect(Rect2(18,46,width-36,22),UI.C_ACCENT)
	var font := ThemeDB.fallback_font
	draw_string(font,Vector2(31,61),Game.player_name + " · " + str(Game.garage_cap),HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color.WHITE)
	for i in mini(Game.garage_cap, 8):
		var x := 28 + i * (width-64)/mini(Game.garage_cap, 8)
		draw_rect(Rect2(x,75,(width-80)/mini(Game.garage_cap, 8),38),Color("799da7"))
		draw_line(Vector2(x+4,78),Vector2(x+25,105),Color("acc8cf"),3,true)
	draw_rect(Rect2(0,122,width,36),Color("bdccd1"))
	draw_line(Vector2(0,137),Vector2(width,137),Color("f5f8f6"),2,true)
	if Game.garage_cap >= 12:
		draw_line(Vector2(18, 43), Vector2(width-18, 43), UI.C_GOLD, 5, true)
	for i in _cars.size():
		draw_texture_rect(_cars[i],Rect2(28+i*115,68,172,86),false)
