class_name PlayableDrive
extends Control
signal finished(score: int)
var running: bool = false
var done: bool = false
var distance: float = 0
var speed: float = 0
var lane: float = 0
var steer: float = 0
var braking: bool = false
var faults: int = 0
var collision_cooldown: float = 0
var clock: float = 0
var status: Label
var _car: Texture2D
var _road: Control
const LENGTH: float = 900
func _init(model: String = "karya_pico") -> void:
	_car = CarDB.texture(model)
	custom_minimum_size = Vector2(0,320)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
func _ready() -> void:
	add_to_group("light_animations")
	status = UI.lbl("",13,UI.C_TEXT,HORIZONTAL_ALIGNMENT_CENTER,false,false)
	status.clip_text = true
	status.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	status.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	status.offset_bottom = 28
	add_child(status)
	var controls := HBoxContainer.new()
	controls.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	controls.offset_top = -56
	controls.add_theme_constant_override("separation",6)
	add_child(controls)
	for direction in [-1,1]:
		var value: int = direction
		var button := UI.btn("<" if direction<0 else ">","chip",func(): pass,50)
		button.button_down.connect(func(): steer=value)
		button.button_up.connect(func():
			if steer==value: steer=0)
		controls.add_child(button)
	var brake := UI.btn(Loc.t("play_brake"),"primary",func(): pass,50)
	brake.button_down.connect(func(): braking=true)
	brake.button_up.connect(func(): braking=false)
	controls.add_child(brake)
	_update_status()
func start() -> void:
	if running or done: return
	running = true
func animation_visible() -> bool:
	return running and is_visible_in_tree()
func road_center(at: float) -> float:
	return sin(at/135.0)*.35
func _process(delta: float) -> void:
	if not running or not is_visible_in_tree(): return
	if Game._web_hidden: return
	var dt: float = minf(delta,.05)
	clock += dt
	var input_steer: float = steer
	if Input.is_physical_key_pressed(KEY_LEFT): input_steer=-1
	if Input.is_physical_key_pressed(KEY_RIGHT): input_steer=1
	var brake: bool = braking or Input.is_physical_key_pressed(KEY_SPACE)
	speed = move_toward(speed,0.0 if brake else 52.0,dt*(95.0 if brake else 24.0))
	lane = clampf(lane+input_steer*dt*1.05,-1,1)
	distance += speed*dt
	collision_cooldown = maxf(0,collision_cooldown-dt)
	if absf(lane-road_center(distance))>.48 and collision_cooldown<=0:
		faults += 1
		speed *= .45
		collision_cooldown = 1.2
	if distance>=LENGTH-60 and brake and speed<2:
		_complete()
	elif distance>LENGTH+70 or clock>60:
		faults += 3
		_complete()
	_update_status()
	queue_redraw()
func _complete() -> void:
	if done: return
	done = true
	running = false
	finished.emit(clampi(100-faults*8-int(maxf(0,clock-35)),0,100))
func _update_status() -> void:
	if is_instance_valid(status): status.text=Loc.t("play_drive_status",[clampi(int(distance/LENGTH*100),0,100),int(speed),faults])
func _draw() -> void:
	var w: float = size.x
	var h: float = size.y-62
	draw_rect(Rect2(0,30,w,h-30),Color("243745") if Game.is_night() else Color("c5d4b0"))
	var previous_left := Vector2.ZERO
	var previous_right := Vector2.ZERO
	for i in range(0,13):
		var y: float = 36+i*(h-36)/12.0
		var at: float = distance+(h-y)*.8
		var cx: float = w*.5+road_center(at)*w*.38
		var left := Vector2(cx-w*.22,y)
		var right := Vector2(cx+w*.22,y)
		if i>0:
			draw_colored_polygon(PackedVector2Array([previous_left,previous_right,right,left]),Color("56606a"))
			draw_line(previous_left,left,Color.WHITE,2,true)
			draw_line(previous_right,right,Color.WHITE,2,true)
		previous_left=left
		previous_right=right
		if fposmod(at,65)<30: draw_line(Vector2(cx,y),Vector2(cx,y+8),Color("eee8cf"),2,true)
	var finish_y: float = h-(LENGTH-distance)/.8
	if finish_y>35 and finish_y<h:
		draw_rect(Rect2(w*.22,finish_y,w*.56,22),Color("559d70"))
	var center := Vector2(w*.5+lane*w*.38,h-32)
	draw_style_box(UI.sb(Color("b7975c"),8),Rect2(center-Vector2(15,28),Vector2(30,56)))
	draw_rect(Rect2(center+Vector2(-11,-17),Vector2(22,12)),Color("254654"))
	draw_rect(Rect2(center+Vector2(-11,12),Vector2(22,8)),Color("254654"))
	for x in [-18,14]:
		for y in [-18,12]: draw_rect(Rect2(center+Vector2(x,y),Vector2(4,11)),Color("20242a"))
	for x in [-11,7]:
		draw_rect(Rect2(center+Vector2(x,-27),Vector2(5,3)),Color("fff1b0"))
		draw_rect(Rect2(center+Vector2(x,24),Vector2(5,3)),Color("c22b40"))

func _notification(what: int) -> void:
	if what==NOTIFICATION_APPLICATION_FOCUS_OUT:
		steer=0
		braking=false
