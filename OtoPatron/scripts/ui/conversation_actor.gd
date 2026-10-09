class_name ConversationActor
extends Control
var elapsed: float = 0.0
var mood: float = 100.0
var role: String = "customer"
var identity: String = ""
var _speaking_until: float = 0.0
var _redraw_timer: float = 0.0
var _head: Texture2D
var _body: Texture2D
var _variant: int = 0
var _draw_count: int = 0
var _skin: Color
var _coat: Color
var _back_style: StyleBoxFlat
var _chair_style: StyleBoxFlat
var _eye_style: StyleBoxFlat
var _mouth_style: StyleBoxFlat
var _hand_style: StyleBoxFlat
func _init() -> void:
	custom_minimum_size = Vector2(0,130)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
func _ready() -> void:
	_variant = 6 if role == "lender" else absi(identity.hash())%6
	_skin = Color(["d5a17e","bc8466","e1b495","aa7559","d3a483","c79172","bc9277"][_variant])
	_coat = Color(["304b60","704654","47504d","665953","333d55","8b6650","25272d"][_variant])
	_back_style = UI.sb(Color("252b33") if role == "lender" else Color("e6edf1"),14)
	_chair_style = UI.sb(Color("171e26"),15)
	_eye_style = UI.sb(Color("ece9dc"),3)
	_mouth_style = UI.sb(Color("663a34"),3)
	_hand_style = UI.sb(_skin,5)
	_head = load("res://art/characters/head_%d.svg" % _variant)
	_body = load("res://art/characters/body_%d.svg" % _variant)
	queue_redraw()
func speak(duration: float) -> void:
	_speaking_until = elapsed + clampf(duration,0,6)
	queue_redraw()
func _on_screen() -> bool:
	if not is_visible_in_tree(): return false
	if is_instance_valid(UI.overlay) and UI.overlay.get_child_count() > 0 and not UI.overlay.is_ancestor_of(self): return false
	var visible_rect: Rect2 = get_global_rect().intersection(get_viewport_rect())
	var ancestor: Node = get_parent()
	while ancestor != null:
		if ancestor is Control and ancestor.clip_contents:
			visible_rect = visible_rect.intersection(ancestor.get_global_rect())
		ancestor = ancestor.get_parent()
	return visible_rect.has_area()
func _process(dt: float) -> void:
	if not _on_screen(): return
	elapsed += dt
	_redraw_timer += dt
	var interval: float = 1.0/16.0 if elapsed < _speaking_until else 1.0/8.0
	if _redraw_timer >= interval:
		_redraw_timer = fmod(_redraw_timer,interval)
		queue_redraw()
func _draw() -> void:
	if _head == null or _body == null: return
	_draw_count += 1
	var lender: bool = role == "lender"
	var scene_height: float = 200.0 if lender else 160.0
	var scale_factor: float = minf(size.x/320.0,size.y/scene_height)
	draw_set_transform(Vector2((size.x-320*scale_factor)*.5,0),0,Vector2.ONE*scale_factor)
	if lender: _office()
	else: _gallery_backdrop()
	var breathing: float = sin(elapsed*1.8)*.65
	var head_rect := Rect2(119,7+breathing,82,98.4) if lender else Rect2(116.25,4+breathing,87.5,105)
	var body_rect := Rect2(85,81+breathing*.4,150,93.75) if lender else Rect2(90,83+breathing*.4,140,87.5)
	draw_texture_rect(_body,body_rect,false)
	draw_texture_rect(_head,head_rect,false)
	_face(head_rect)
	if lender: _desk_and_hands(breathing)
	else:
		var wave: float = sin(elapsed*4.0)*5 if elapsed < _speaking_until else sin(elapsed)*.5
		draw_line(Vector2(207,127),Vector2(231,128-wave),_coat,15,true)
		draw_circle(Vector2(232,128-wave),7,_skin,true,-1,true)
	draw_set_transform(Vector2.ZERO)
func _gallery_backdrop() -> void:
	draw_style_box(_back_style,Rect2(0,0,320,160))
	for x in [12,76,240,290]:
		draw_rect(Rect2(x,13,36,104),Color("a7bdc7"))
		draw_line(Vector2(x+4,15),Vector2(x+32,64),Color("d2e0e5"),3,true)
	draw_rect(Rect2(0,124,320,36),Color("c5d0d3"))
	draw_circle(Vector2(39,113),17,Color("668777"),true,-1,true)
	draw_rect(Rect2(31,126,17,27),Color("747a7b"))
func _office() -> void:
	draw_style_box(_back_style,Rect2(0,0,320,200))
	draw_rect(Rect2(16,17,65,82),Color("151e28"))
	for x in [23,45,66]:
		draw_line(Vector2(x,20),Vector2(x,95),Color("42525e"),2,true)
	for y in [30,48,66,84]: draw_line(Vector2(17,y),Vector2(80,y),Color("35444e"),2,true)
	draw_rect(Rect2(232,18,55,45),Color("776443"))
	draw_rect(Rect2(235,21,49,39),Color("38434b"))
	draw_line(Vector2(237,51),Vector2(257,31),Color("91806a"),2,true)
	draw_line(Vector2(257,31),Vector2(283,50),Color("91806a"),2,true)
	draw_style_box(_chair_style,Rect2(99,50,122,94))
	draw_colored_polygon(PackedVector2Array([Vector2(255,63),Vector2(301,134),Vector2(207,134)]),Color(1,.76,.4,.08))
	draw_line(Vector2(275,64),Vector2(275,137),Color("b5a27e"),3,true)
	draw_colored_polygon(PackedVector2Array([Vector2(258,43),Vector2(288,43),Vector2(300,66),Vector2(248,66)]),Color("a38a57"))
func _face(rect: Rect2) -> void:
	var scale_factor: float = rect.size.x/200.0
	var blink: bool = fposmod(elapsed+_variant*.31,4.7) < .17
	var glance: float = sin(elapsed*.55)*1.0
	for x in [75.0,125.0]:
		var eye := rect.position+Vector2(x,123)*scale_factor
		if blink:
			draw_line(eye-Vector2(4,0),eye+Vector2(4,0),Color("3d302b"),1.4,true)
		else:
			draw_style_box(_eye_style,Rect2(eye-Vector2(4,1.8),Vector2(8,3.6)))
			draw_circle(eye+Vector2(glance,0),1.65,Color("28323b"),true,-1,true)
		var tense: float = 2.0 if mood < 40 else 0.0
		var side: float = 1.0 if x < 100 else -1.0
		draw_line(eye+Vector2(-5,-7-tense*side),eye+Vector2(5,-6+tense*side),Color("3d302b"),2.0,true)
	var mouth := rect.position+Vector2(100,169)*scale_factor
	if elapsed < _speaking_until:
		var opening: float = 1.5+absf(sin(elapsed*12))*2.4
		draw_style_box(_mouth_style,Rect2(mouth-Vector2(5,1),Vector2(10,opening)))
	else: draw_line(mouth-Vector2(5,0),mouth+Vector2(5,0),Color("774b40"),1.5,true)
func _desk_and_hands(breathing: float) -> void:
	var shift: float = sin(elapsed*.9)*1.5
	var grip := Vector2(70+shift,114+breathing)
	var tip := Vector2(88+shift,57)
	draw_line(Vector2(61+shift,143),tip,Color("6e4a30"),9,true)
	draw_line(grip,tip,Color("b28a5a"),13,true)
	draw_circle(tip,6.5,Color("b28a5a"),true,-1,true)
	draw_line(grip+Vector2(1,-3),tip+Vector2(1,3),Color("d0a875"),2,true)
	draw_line(Vector2(120,110),Vector2(96,130),_coat,16,true)
	draw_line(Vector2(96,130),grip,_coat,14,true)
	draw_circle(grip,7,_skin,true,-1,true)
	draw_rect(Rect2(12,143,296,57),Color("49372d"))
	draw_rect(Rect2(12,141,296,11),Color("78563d"))
	for y in [160,182,192]: draw_line(Vector2(16,y),Vector2(304,y),Color("604535"),1,true)
	draw_line(Vector2(203,114),Vector2(231,137),_coat,16,true)
	var tap: float = maxf(0.0,sin(elapsed*2))*1.6
	draw_line(Vector2(231,137),Vector2(205,146-tap),_coat,12,true)
	draw_style_box(_hand_style,Rect2(195,140-tap,23,10))
	draw_rect(Rect2(120,155,58,26),Color("d9d1b6"))
	for y in [160,165,170]: draw_line(Vector2(126,y),Vector2(160,y),Color("8f8d7e"),1,true)
	draw_rect(Rect2(254,151,30,7),Color("7a966d"))
	draw_line(Vector2(258,154),Vector2(278,154),Color("b8c6a0"),1,true)
