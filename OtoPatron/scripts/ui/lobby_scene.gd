class_name LobbyScene
extends Control
signal destination_selected(destination: String)
signal customer_pressed(visit: Dictionary)
var live: bool=false
var _display_count:=0
var _demo: Label
var _live_signature: String=""
var mode: String = "exterior"
var snapshot: Dictionary = {}
var _clock := 0.0
var _cars: Array[TextureRect] = []
var _workers: Array[Control] = []
var _platforms: Array[CarTurntable]=[]
var _sign: Label
var _backdrop: Texture2D
var _night := false
var _timer := 0.0
var _camera_tween: Tween
class Worker extends Control:
	var role := "sales"
	var broom: Node2D
	var limbs: Array[Line2D]=[]
	var visit: Dictionary={}
	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		for i in 4:
			var limb:=Line2D.new()
			limb.points=PackedVector2Array([Vector2.ZERO,Vector2(0,12 if i<2 else 14)])
			limb.width=3.5
			limb.default_color=Color("293444") if i<2 else _color()
			limb.position=Vector2(-3 if i%2==0 else 3,-11 if i<2 else -25)
			add_child(limb)
			limbs.append(limb)
		if role == "cleaner":
			broom=Node2D.new()
			var stick:=Line2D.new()
			stick.points=PackedVector2Array([Vector2(0,0),Vector2(8,22)])
			stick.width=2
			stick.default_color=Color("b79b6c")
			broom.add_child(stick)
			var brush:=Line2D.new()
			brush.points=PackedVector2Array([Vector2(1,22),Vector2(16,22)])
			brush.width=5
			brush.default_color=Color("d7c08e")
			broom.add_child(brush)
			broom.position=Vector2(5,-15)
			add_child(broom)
		elif role=="mechanic":
			var tool:=Line2D.new()
			tool.points=PackedVector2Array([Vector2(8,-14),Vector2(15,-9),Vector2(17,-13)])
			tool.width=2.5
			tool.default_color=Color("c4d1dd")
			add_child(tool)
	func animate(time: float, walking: bool, inspecting: bool) -> void:
		var step: float=sin(time*8)*.42 if walking else 0.0
		for i in limbs.size(): limbs[i].rotation=(step if i%2==0 else -step) if i<2 else (-step*.6 if i%2==0 else step*.6)
		if inspecting and limbs.size()==4: limbs[3].rotation=-.95+sin(time*2)*.12
		if is_instance_valid(broom): broom.rotation=sin(time*4)*.35
	func _color() -> Color:
		return Color("bd9365") if role=="customer" else (Color("578e89") if role=="cleaner" else (Color("5b7499") if role=="mechanic" else Color("a14c62")))
	func _draw() -> void:
		draw_circle(Vector2(0,1),8,Color(0,0,0,.12),true,-1,true)
		draw_style_box(UI.sb(_color(),4),Rect2(-7,-28,14,18))
		draw_circle(Vector2(0,-34),6,Color("d5a78b"),true,-1,true)
		draw_arc(Vector2(0,-35),6,PI,TAU,12,Color("352e31"),3,true)
func _init() -> void:
	custom_minimum_size=Vector2(0,300)
	size_flags_horizontal=Control.SIZE_EXPAND_FILL
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	clip_contents=true
func _ready() -> void:
	add_to_group("light_animations")
	resized.connect(_layout)
	if live:
		Game.changed.connect(_refresh_live)
		_refresh_live()
	else:
		_build_scene()
func _read_live() -> void:
	snapshot={"minute":Game.minute,"flags":Game.flags,"cars":Game.cars,"visits":Game.visits}
func _refresh_live() -> void:
	_read_live()
	var signature: String=str([Game.is_night(),Game.flags.get("team",{}),Game.flags.get("gallery_name",""),Game.flags.get("gallery_style",{}),Game.cars.map(func(c): return [c["uid"],c.get("outdoors",false)]),Game.visits.map(func(v): return v["id"])])
	if signature==_live_signature: return
	_live_signature=signature
	_build_scene()
func set_mode(value: String) -> void:
	if value not in ["exterior","interior","map"]: return
	mode=value
	if is_inside_tree(): _build_scene()
func _build_scene() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	_cars.clear()
	_workers.clear()
	_platforms.clear()
	_night=int(snapshot.get("minute",480))>=1200 or int(snapshot.get("minute",480))<420
	var flags: Dictionary = snapshot.get("flags",{})
	var style: Dictionary = flags.get("gallery_style",{}) if flags.get("gallery_style",{}) is Dictionary else {}
	var decor: String = str(style.get("decor","classic"))
	if decor not in GalleryStyle.PACKAGES: decor="classic"
	_backdrop=load("res://art/gallery/"+decor+("_night" if _night else "_day")+".svg")
	_sign=UI.lbl(str(flags.get("gallery_name","OTOPATRON")),19,Color.WHITE,HORIZONTAL_ALIGNMENT_CENTER,true,false)
	_sign.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	_sign.clip_text=true
	_sign.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
	_sign.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(_sign)
	var data: Array = snapshot.get("cars",[])
	var models: Array = []
	for car in data.slice(0,3): models.append(str(car["model"]))
	if models.is_empty(): models=["karya_nova","ravena_koru","valtorre_solis"]
	_display_count=models.size()
	if mode=="exterior": models.append_array(["karya_pico","tivora_aven"])
	if mode=="map": models=["karya_pico","brenor_work"]
	for model in models:
		var sprite:=TextureRect.new()
		sprite.texture=CarDB.texture(model)
		sprite.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
		sprite.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		sprite.mouse_filter=Control.MOUSE_FILTER_IGNORE
		add_child(sprite)
		_cars.append(sprite)
		if mode=="interior":
			var platform:=CarTurntable.new()
			platform.model_id=str(model)
			add_child(platform)
			_platforms.append(platform)
			sprite.hide()
	if mode!="map":
		var team: Variant = flags.get("team",{})
		for role in ["cleaner","mechanic","sales"]:
			var count: int = 1 if snapshot.is_empty() else 0
			if team is Dictionary and not snapshot.is_empty():
				var number: Variant=team.get(role,0)
				if number is bool: count=1 if number else 0
				elif number is int or number is float: count=clampi(int(number),0,2)
			for worker_index in count:
				var worker:=Worker.new()
				worker.role=role
				add_child(worker)
				_workers.append(worker)
		var visitors: Array = snapshot.get("visits",[])
		for visitor_index in (2 if visitors.is_empty() and not live else mini(3,visitors.size())):
			var visitor:=Worker.new()
			visitor.role="customer"
			if visitor_index<visitors.size():
				visitor.visit=visitors[visitor_index]
				var hit:=Button.new()
				hit.flat=true
				hit.position=Vector2(-14,-40)
				hit.size=Vector2(28,44)
				hit.tooltip_text=str(visitor.visit.get("name",""))
				var buyer: Dictionary=visitor.visit
				hit.pressed.connect(func(): customer_pressed.emit(buyer))
				visitor.add_child(hit)
			add_child(visitor)
			_workers.append(visitor)
	else:
		for item in [["garage", "lobby_map_gallery", Vector2(48,65)], ["market","lobby_map_market",Vector2(372,65)], ["loans","lobby_map_bank",Vector2(372,229)]]:
			var destination: String=item[0]
			var button:=UI.btn(Loc.t(item[1]),"chip",func(): destination_selected.emit(destination),40)
			button.set_meta("map_position",item[2])
			button.set_meta("map_size",Vector2(220,58))
			add_child(button)
	_layout()
	_clock=0.0
	pivot_offset=size*.5
	scale=Vector2(.965,.965)
	if is_instance_valid(_camera_tween): _camera_tween.kill()
	_camera_tween=create_tween()
	_camera_tween.tween_property(self,"scale",Vector2.ONE,.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	queue_redraw()
func _layout() -> void:
	if size.x<1 or not is_instance_valid(_sign): return
	var factor:=Vector2(size.x/640.0,size.y/360.0)
	_sign.position=Vector2(90,72 if mode=="exterior" else 20)*factor
	_sign.size=Vector2(460,34)*factor
	_sign.visible=mode!="map"
	var font_size: int=clampi(int(size.x/30.0),12,20)
	while font_size>9 and _sign.get_theme_font("font").get_string_size(_sign.text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>_sign.size.x-12: font_size-=1
	_sign.add_theme_font_size_override("font_size",font_size)
	if is_instance_valid(_demo):
		_demo.position=Vector2(10,322)*factor
		_demo.size=Vector2(620,32)*factor
	for child in get_children():
		if child.has_meta("map_position"):
			child.position=child.get_meta("map_position")*factor
			child.size=child.get_meta("map_size")*factor
			child.custom_minimum_size=Vector2.ZERO
			child.add_theme_font_size_override("font_size",clampi(int(size.x/31),11,17))
	_animate()
func animation_visible() -> bool:
	return is_visible_in_tree() and get_global_rect().intersects(get_viewport_rect()) and not Game._web_hidden and not (is_instance_valid(UI.overlay) and UI.overlay.get_child_count()>0)
func _process(delta: float) -> void:
	if not animation_visible(): return
	_clock+=minf(delta,.1)
	_animate()
func _animate() -> void:
	var factor:=Vector2(size.x/640.0,size.y/360.0)
	for i in _cars.size():
		var moving: bool = mode=="map" or (mode=="exterior" and i>=_display_count)
		var point:=Vector2(105+i*150,153 if mode=="exterior" else 159+i%2*31)
		var dimensions:=Vector2(138,69) if mode=="exterior" else Vector2(185,100)
		if moving:
			point=Vector2(fposmod(_clock*48+i*360,900)-170,285 if mode=="exterior" else (158 if i==0 else 307))
			dimensions=Vector2(120,60) if mode=="exterior" else Vector2(62,32)
			if mode=="exterior": point.y=268 if i==_display_count else 304
		_cars[i].flip_h=false
		if not moving and mode=="exterior" and i<snapshot.get("cars",[]).size() and bool(snapshot["cars"][i].get("outdoors",false)): point.y=217
		_cars[i].position=point*factor
		_cars[i].size=dimensions*factor
		_cars[i].modulate=Color("cbd9ee") if _night else Color.WHITE
	for i in _platforms.size():
		_platforms[i].position=Vector2(70+i*170,175+i%2*20)*factor
		_platforms[i].size=Vector2(160,110)*factor
		_platforms[i].set_angle(_clock*.30+i*.8)
	for i in _workers.size():
		var worker: Control=_workers[i]
		var route: Dictionary=_route(i)
		worker.position=(route["position"]+Vector2(0,(i%3-1)*7))*factor
		worker.scale=factor*1.25
		worker.animate(_clock+i,bool(route["walking"]),not bool(route["walking"]) and worker.role in ["customer","mechanic","sales"])
func _route(index: int) -> Dictionary:
	var points: Array=[Vector2(105,270),Vector2(285,276),Vector2(477,267),Vector2(550,310)] if mode=="interior" else [Vector2(105,259),Vector2(275,248),Vector2(477,259),Vector2(550,269)]
	var speed: float=65.0
	var stop: float=2.0
	var period: float=0
	for i in points.size(): period+=points[i].distance_to(points[(i+1)%points.size()])/speed+stop
	var time: float=fposmod(_clock+index*3.7,period)
	for i in points.size():
		var next: Vector2=points[(i+1)%points.size()]
		var duration: float=points[i].distance_to(next)/speed
		if time<duration: return {"position":points[i].lerp(next,time/duration),"walking":true}
		time-=duration
		if time<stop: return {"position":next,"walking":false}
		time-=stop
	return {"position":points[0],"walking":false}
func _draw() -> void:
	if size.x<1: return
	draw_set_transform(Vector2.ZERO,0,Vector2(size.x/640.0,size.y/360.0))
	var sky: Color=Color("101d33") if _night else Color("c9e0ed")
	draw_rect(Rect2(0,0,640,360),sky)
	if mode=="exterior":
		if _backdrop: draw_texture_rect(_backdrop,Rect2(0,0,640,285),false)
		var flags: Dictionary=snapshot.get("flags",{})
		var styles: Variant=flags.get("gallery_style",{})
		var sign_style: String=str(styles.get("sign","classic")) if styles is Dictionary else "classic"
		var color: Color=Color("24495c") if sign_style=="modern" else (Color("90713b") if sign_style in ["luxury","prestige"] else Color("087d83"))
		draw_style_box(UI.sb(color,4),Rect2(85,69,470,40))
		draw_rect(Rect2(0,285,640,75),Color("29374b") if _night else Color("687b89"))
		for i in 8: draw_rect(Rect2(i*95,324,43,3),Color("dae0e5"))
		if _night:
			for x in [100,260,420,540]:
				draw_colored_polygon(PackedVector2Array([Vector2(x,128),Vector2(x-30,245),Vector2(x+40,245)]),Color(1,.89,.61,.10))
	elif mode=="interior":
		draw_rect(Rect2(0,0,640,185),Color("243448") if _night else Color("e5ebef"))
		draw_rect(Rect2(44,59,552,116),Color("172a41") if _night else Color("8db4c8"))
		for x in [44,182,320,458,596]: draw_line(Vector2(x,59),Vector2(x,175),Color("5d7385"),5,true)
		for x in [93,225,357,489]: draw_line(Vector2(x,75),Vector2(x+50,146),Color(1,1,1,.12),5,true)
		draw_colored_polygon(PackedVector2Array([Vector2(0,185),Vector2(640,185),Vector2(640,360),Vector2(0,360)]),Color("344857") if _night else Color("a6b6bd"))
		for x in range(-320,1000,100): draw_line(Vector2(320+(x-320)*.25,185),Vector2(x,360),Color(1,1,1,.16),1,true)
		for y in [212,254,305]: draw_line(Vector2(0,y),Vector2(640,y),Color(1,1,1,.18),1,true)
		for i in 3:
			draw_style_box(UI.sb(Color(1,1,1,.06),6,Color(1,1,1,.25),1),Rect2(65+i*170,200,155,50))
			draw_line(Vector2(80+i*190,15),Vector2(173+i*190,15),Color("ffe9b5"),5,true)
		draw_style_box(UI.sb(Color("087d83"),5),Rect2(86,20,468,34))
		for x in [35,603]:
			draw_style_box(UI.sb(Color("334c53"),3),Rect2(x-10,164,20,35))
			draw_circle(Vector2(x,149),19,Color("527c6c"),true,-1,true)
	else:
		draw_rect(Rect2(0,0,640,360),Color("233644") if _night else Color("b5cdbf"))
		draw_rect(Rect2(0,151,640,60),Color("425366"))
		draw_rect(Rect2(280,0,60,360),Color("425366"))
		draw_rect(Rect2(0,307,640,53),Color("425366"))
		for x in range(0,640,66): draw_line(Vector2(x,182),Vector2(x+28,182),Color("d7e0dc"),2,true)
		for y in range(0,360,54): draw_line(Vector2(310,y),Vector2(310,y+24),Color("d7e0dc"),2,true)
		for rect in [Rect2(40,33,236,95),Rect2(363,33,236,95),Rect2(363,223,236,73)]:
			draw_style_box(UI.sb(Color("3a5363") if _night else Color("e8ece5"),8,Color("96a8b1"),2),rect)
			draw_rect(Rect2(rect.position+Vector2(9,9),Vector2(rect.size.x-18,18)),Color("b02d47"))
		for point in [Vector2(80,260),Vector2(169,272),Vector2(231,54),Vector2(547,193)]:
			draw_circle(point,14,Color("547f67"),true,-1,true)
	draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
