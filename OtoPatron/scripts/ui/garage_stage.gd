class_name GarageStage
extends Control
signal customer_pressed(visit: Dictionary)
var _customers: Array = []
var textures: Array = []
var elapsed: float = 0
var preview_style: String = ""
var _name: Label
var _background: Texture2D
static var _backgrounds: Dictionary = {}
static var _background_order: Array[String] = []
func _init() -> void:
	clip_contents = true
	custom_minimum_size = Vector2(0, 280)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_IGNORE
func _ready() -> void:
	if preview_style.is_empty():
		add_to_group("light_animations")
		for visit in Game.visits.slice(0,3):
			var buyer: Dictionary = visit
			var button := GalleryCustomer.new()
			button.tooltip_text = str(visit["name"])
			button.pressed.connect(func(): customer_pressed.emit(buyer))
			add_child(button)
			_customers.append(button)
	_name = Label.new()
	_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_name.clip_text = true
	_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	# Sign lettering uses its own font metrics, not the multilingual UI line height.
	var sign_font: FontFile = load("res://fonts/NotoSans.ttf").duplicate()
	sign_font.fallbacks = []
	_name.add_theme_font_override("font", sign_font)
	_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_name.add_theme_color_override("font_color",Color.WHITE)
	add_child(_name)
	for car in Game.cars.slice(0,3):
		textures.append(CarDB.texture(str(car["model"])))
	if not preview_style.is_empty() and textures.is_empty():
		for model in ["karya_pico","veltra_orin","tivora_grano"]: textures.append(CarDB.texture(model))
	if preview_style.is_empty(): add_child(WeatherLayer.new())
var _redraw_timer: float = 0.0
var _last_night: bool = false
func _process(dt: float) -> void:
	if Game._web_hidden: return
	if not is_visible_in_tree() or not get_global_rect().intersects(get_viewport_rect()): return
	var ancestor := get_parent()
	while ancestor != null:
		if ancestor is Control and ancestor.clip_contents and not get_global_rect().intersects(ancestor.get_global_rect()): return
		ancestor = ancestor.get_parent()
	if is_instance_valid(UI.overlay) and UI.overlay.get_child_count() > 0: return
	if MobileScroll.is_interacting(): return
	elapsed += dt
	for i in _customers.size():
		var target: float = size.x*(.25+i*.22)
		_customers[i].animate(elapsed,elapsed<4.0)
		_customers[i].position = Vector2(lerpf(-32.0,target,minf(1.0,elapsed/4.0)),203+sin(elapsed*5+i)*1.5)
	if _last_night != Game.is_night():
		_last_night = Game.is_night()
		queue_redraw()
	if preview_style.is_empty() and (int(Game.flags.get("security", 0)) > 0 or bool(Game.flags.get("theft_pending", false)) or DealerExpansion.wages()>0): _redraw_timer += dt
	if _redraw_timer >= 0.1:
		_redraw_timer = fmod(_redraw_timer, 0.1)
		queue_redraw()
func _draw() -> void:
	var width: float = size.x
	if width < 80: return
	var decor: String = GalleryStyle.selected("decor") if preview_style.is_empty() else preview_style
	var variant: String = decor + ("_night" if Game.is_night() else "_day")
	if not _backgrounds.has(variant): _backgrounds[variant] = load("res://art/gallery/" + variant + ".svg")
	# Retain a reference while this control's draw commands use the texture.
	# Evicting a shared cache entry must not destroy another visible preview's RID.
	_background = _backgrounds[variant]
	_background_order.erase(variant)
	_background_order.append(variant)
	while _background_order.size() > 2: _backgrounds.erase(_background_order.pop_front())
	draw_texture_rect(_background, Rect2(0,0,width,280), false)
	var rank: int = ["classic","modern","luxury","prestige"].find(decor)
	var scale_x: float = width / 640.0
	var bw: float = 430 + maxi(rank,0)*34
	var x: float = (640-bw)*0.5
	var roof: float = 121-maxi(rank,0)*9
	var floor_style: String = GalleryStyle.selected("floor") if preview_style.is_empty() else preview_style
	if floor_style != decor:
		var tint: Color = Color(.75,.65,.48,.25) if floor_style=="luxury" else (Color(.23,.4,.5,.18) if floor_style=="modern" else Color(.83,.83,.8,.15))
		draw_rect(Rect2(0,214,width,66),tint)
	var sign: String = GalleryStyle.selected("sign") if preview_style.is_empty() else preview_style
	var sign_color: Color = Color("982639") if sign=="classic" else (Color("234457") if sign=="modern" else Color("806331"))
	var sign_rect := Rect2((x+7)*scale_x,(roof+9)*280/420.0,(bw-14)*scale_x,37*280/420.0)
	draw_rect(sign_rect,sign_color)
	if is_instance_valid(_name):
		_name.text = GalleryStyle.title()
		var font: Font = _name.get_theme_font("font")
		var text_size := sign_rect.size - Vector2(16, 4)
		var fs: int = 18
		while fs > 10 and (font.get_string_size(_name.text,HORIZONTAL_ALIGNMENT_LEFT,-1,fs).x > text_size.x or font.get_height(fs) > text_size.y): fs -= 1
		_name.add_theme_font_size_override("font_size",fs)
		_name.position = sign_rect.position + Vector2(8, 2)
		_name.size = text_size
	for i in textures.size():
		var tex: Texture2D = textures[i]
		if tex:
			var outdoor: bool=preview_style.is_empty() and i<Game.cars.size() and bool(Game.cars[i].get("outdoors",false))
			var car_rect := Rect2((x+18+i*(bw-35)/3)*scale_x,224 if outdoor else 173,(bw-35)/3*scale_x,34)
			draw_texture_rect(tex,car_rect,false)
			if preview_style.is_empty() and i < Game.cars.size(): CarPortrait.draw_condition(self,car_rect,Game.cars[i])
	var security_rank: int = int(Game.flags.get("security",0))
	if security_rank>0:
		_person(Vector2(25+(sin(elapsed*.35)+1)*.5*(width-50),250),Color("253b58"),true)
		for guard_index in range(1,security_rank):
			_person(Vector2(width*(guard_index+1)/(security_rank+1),246),Color("253b58"),true)
	if bool(Game.flags.get("theft_pending",false)): _person(Vector2(15+fposmod(elapsed*9,width*.25),250),Color("37313b"),false)

	if preview_style.is_empty():
		for worker_index in DealerExpansion.count("cleaner"):
			var pos := Vector2(width*(.15+worker_index*.10)+sin(elapsed*.3)*width*.05,247)
			_person(pos,Color("4c8b86"),false)
			draw_line(pos+Vector2(6,-12),pos+Vector2(14+sin(elapsed*3)*4,3),Color("94653c"),2,true)
			draw_line(pos+Vector2(8,4),pos+Vector2(21,4),Color("d2b565"),4,true)
		for worker_index in DealerExpansion.count("mechanic"):
			var pos := Vector2(width*(.4+worker_index*.09),214)
			_person(pos,Color("5e6a91"),false)
			draw_line(pos+Vector2(6,-8),pos+Vector2(13,-5),Color("d7dce3"),3,true)
		for worker_index in DealerExpansion.count("sales"):
			_person(Vector2(width*(.65+worker_index*.065),234),Color("834a60"),false)

func _person(pos: Vector2, uniform: Color, guard: bool) -> void:
	var step: float = sin(elapsed * 6.0) * 4.0
	draw_circle(pos + Vector2(0, -23), 4.5, Color("ddb69c"), true, -1, true)
	draw_line(pos + Vector2(0, -17), pos + Vector2(0, -7), uniform, 9, true)
	draw_line(pos + Vector2(0, -7), pos + Vector2(-4 + step, 2), uniform, 3, true)
	draw_line(pos + Vector2(0, -7), pos + Vector2(4 - step, 2), uniform, 3, true)
	draw_line(pos + Vector2(-4, -14), pos + Vector2(-7 - step, -5), uniform, 3, true)
	draw_line(pos + Vector2(4, -14), pos + Vector2(7 + step, -5), uniform, 3, true)
	if guard:
		draw_rect(Rect2(pos + Vector2(-5, -29), Vector2(10, 4)), uniform)
		draw_circle(pos + Vector2(2, -15), 1.5, Color("eac66b"), true, -1, true)

func animation_visible() -> bool:
	return not _customers.is_empty() and is_visible_in_tree() and get_global_rect().intersects(get_viewport_rect()) and (not is_instance_valid(UI.overlay) or UI.overlay.get_child_count()==0)
