extends ScreenBase
## Açılış: logo + hareketli araçlı yükleme + OYUNA BAŞLA / DEVAM ET / AYARLAR.

static var _loaded: bool = false
var _bar: ProgressBar
var _status: Label
var _menu: VBoxContainer
var _road: RoadAnim
var _scene: LobbyScene
var _scene_mode: String = "exterior"
var _snapshot: Dictionary = {}
var _scene_buttons: Dictionary = {}
var _avatar_choice: int = 0
var _city_choice: String = "34"


func _build() -> void:
	_snapshot = _read_preview()
	var sc := UI.scroll_area(self)
	sc.add_child(UI.lbl("OTOPATRON",30,Color.WHITE,HORIZONTAL_ALIGNMENT_CENTER,true))
	sc.add_child(UI.lbl(Loc.t("app_subtitle"),13,Color.WHITE,HORIZONTAL_ALIGNMENT_CENTER))
	var tabs:=UI.hbox(sc,6)
	for view in ["exterior","interior","map"]:
		var target: String=view
		var button:=UI.btn(Loc.t("lobby_"+view),"chipon" if view==_scene_mode else "chip",func(): _select_scene(target),40)
		button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		tabs.add_child(button)
		_scene_buttons[view]=button
		_style_button(button,view==_scene_mode)
	_scene=LobbyScene.new()
	_scene.snapshot=_snapshot
	_scene.mode=_scene_mode
	_scene.destination_selected.connect(_open_destination)
	sc.add_child(_scene)
	var minute: int=int(_snapshot.get("minute",480))
	var city: String=CityDB.city_name(str(_snapshot.get("city","34")))
	sc.add_child(UI.lbl("%s · %02d:%02d" % [city,minute/60,minute%60],13,Color("bacbdb"),HORIZONTAL_ALIGNMENT_CENTER))
	var load_box:=UI.vbox(sc,6)
	_status=UI.lbl(Loc.t("loading"),14,Color("bacbdb"),HORIZONTAL_ALIGNMENT_CENTER)
	load_box.add_child(_status)
	_bar=UI.bar(0,100,UI.C_ACCENT,6)
	load_box.add_child(_bar)
	_menu=UI.vbox(sc,8)
	if _loaded: _show_menu()
	else: _run_loading()
	sc.add_child(UI.lbl("Ramazan ÖZKESKİN · Sudenur GÜVEZ\nV%s" % ReleaseInfo.VERSION,11,Color("bacbdb"),HORIZONTAL_ALIGNMENT_CENTER))

func _read_preview() -> Dictionary:
	if Game.started: return Game.to_dict().duplicate(true)
	for path in [Game.save_path(),Game.save_path(true)]:
		if not FileAccess.file_exists(path): continue
		var file:=FileAccess.open(path,FileAccess.READ)
		if file==null: continue
		var data: Variant=file.get_var(false)
		file.close()
		if data is Dictionary and Game.valid_snapshot(data): return data
	return {}

func _select_scene(value: String) -> void:
	_scene_mode=value
	_scene.set_mode(value)
	for id in _scene_buttons:
		_style_button(_scene_buttons[id],id==value)

func _open_destination(target: String) -> void:
	if Game.started or (Game.has_save() and Game.load_game()):
		Game.go(target)
	else:
		_on_new(target)


func _set_progress(v: float, key: String) -> void:
	_bar.value = v
	_status.text = Loc.t(key)


func _run_loading() -> void:
	var total := mini(6, CarDB.MODELS.size())
	for i in total:
		CarDB.texture(str(CarDB.MODELS[i]["id"]))
		_set_progress(5.0 + 60.0 * (i + 1) / total, "loading_cars")
		if i % 3 == 0:
			await get_tree().process_frame
			if not is_inside_tree():
				return
	_set_progress(75.0, "loading_sound")
	Fx.start_music()
	await get_tree().create_timer(0.35).timeout
	if not is_inside_tree():
		return
	Game.load_settings()
	_set_progress(92.0, "loading_market")
	await get_tree().create_timer(0.4).timeout
	if not is_inside_tree():
		return
	_set_progress(100.0, "loading_done")
	await get_tree().create_timer(0.45).timeout
	_loaded = true
	if is_inside_tree():
		_show_menu()


func _show_menu() -> void:
	_bar.get_parent().visible = false
	for c in _menu.get_children():
		c.queue_free()
	_menu.add_child(UI.btn_icon("play",Loc.t("lobby_return") if not _snapshot.is_empty() else Loc.t("btn_new_game"),"primary",_on_continue if not _snapshot.is_empty() else _on_new,58))
	var actions:=UI.hbox(_menu,8)
	actions.add_child(UI.btn(Loc.t("lobby_new"),"ghost",_on_new,44))
	actions.add_child(UI.btn_icon("gear",Loc.t("btn_settings"),"ghost",func(): Game.go("settings",{"from":"splash"}),44))
	_menu.add_child(UI.btn(Loc.t("account_title"),"chip",func(): AccountBridge.open(),40))
	for child in actions.get_children():
		_style_button(child,false)
		for label in child.find_children("*","Label",true,false): label.add_theme_color_override("font_color",Color("e5eef8"))
	_style_button(_menu.get_children().back(),false)
	UI.fade_in(_menu, 0.4)
	AccountBridge.show_opening.call_deferred()


func _on_continue() -> void:
	if Game.started or (Game.has_save() and Game.load_game()):
		Fx.play("success")
		Game.go("home")
	else:
		Game.toast(Loc.t("no_save"), "bad")
		Fx.play("error")


func _on_new(destination: String = "home") -> void:
	var v := UI.dialog_card(Loc.t("new_game_title"))
	v.add_child(UI.lbl(Loc.t("new_game_name"), 15, UI.C_MUTED))
	var le := LineEdit.new()
	le.virtual_keyboard_enabled = true
	le.placeholder_text = Loc.t("new_game_name")
	le.text = Loc.t("default_name")
	le.max_length = 18
	le.select_all_on_focus = true
	le.custom_minimum_size = Vector2(0, 50)
	v.add_child(le)
	v.add_child(UI.lbl(Loc.t("new_game_city"), 15, UI.C_MUTED))
	var city_btn := UI.btn("", "chip", func(): pass, 54)
	v.add_child(city_btn)
	var refresh := func():
		city_btn.text = CityDB.city_name(_city_choice)
	city_btn.pressed.connect(func():
		UI.pick_city(_city_choice, func(code: String):
			_city_choice = code
			refresh.call(), true))
	refresh.call()
	v.add_child(UI.lbl(Loc.t("choose_avatar"), 15, UI.C_MUTED))
	var avatars := GridContainer.new()
	avatars.columns = 4 if UI.overlay.size.x<470 else 8
	v.add_child(avatars)
	for avatar in 8:
		var id: int = avatar
		var b := UI.btn("", "chipon" if id == _avatar_choice else "chip", func(): pass, 48)
		b.custom_minimum_size.x = 44
		b.add_child(AvatarBadge.new(id, 40))
		b.pressed.connect(func():
			_avatar_choice = id
			for child in avatars.get_children():
				child.theme_type_variation = "ChipButton"
			b.theme_type_variation = "ChipOnButton"
			UI.style_menu_dialog(v))
		avatars.add_child(b)
	if Game.has_save():
		v.add_child(UI.lbl(Loc.t("new_game_overwrite"), 14, UI.C_BAD))
	var root := UI.show_dialog(v)
	var r2 := UI.hbox(v, 10)
	r2.add_child(UI.btn(Loc.t("cancel"), "ghost", func(): root.queue_free()))
	r2.add_child(UI.btn(Loc.t("btn_start"), "primary", func():
		Game.new_game(le.text, _city_choice)
		Game.avatar_id = _avatar_choice
		Game.save_game()
		root.queue_free()
		Fx.play("success")
		Game.go(destination)
		UI.message(Loc.t("welcome_title"), Loc.t("welcome_body"), "", Callable(), true)))
	UI.style_menu_dialog(v)

func _style_button(button: Button, selected: bool) -> void:
	button.add_theme_stylebox_override("normal",UI.sb(Color("087d83") if selected else Color("21364a"),14,Color("51687d"),1))
	button.add_theme_stylebox_override("hover",UI.sb(Color("304a62"),14,Color("7892a8"),1))
	button.add_theme_stylebox_override("pressed",UI.sb(Color("065a62"),14))
	button.add_theme_color_override("font_color",Color.WHITE)
	button.add_theme_color_override("font_hover_color",Color.WHITE)
	button.add_theme_color_override("font_pressed_color",Color.WHITE)
