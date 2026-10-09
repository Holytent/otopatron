extends ScreenBase
var _weather_label: Label
func _ready() -> void:
	super._ready()
	Game.live_tick.connect(_update_weather)
func _update_weather() -> void:
	if is_instance_valid(_weather_label): _weather_label.text=Loc.t("life_weather",[Loc.t("wx_"+str(Game.weather.get("id","sunny"))),int(Game.weather.get("temp",20))])
func _build() -> void:
	var sc := UI.scroll_area(self)
	var summary := UI.add_card(sc, UI.C_PANEL, 18, UI.C_LINE)
	summary.add_child(UI.lbl(Loc.t("home_summary"), 22, UI.C_TEXT, -1, true))
	UI.kv(summary, Loc.t("home_income"), Loc.money(Game.daily_income), UI.C_GOOD)
	UI.kv(summary, Loc.t("home_expenses"), Loc.money(Game.daily_expenses), UI.C_MUTED)
	var cash_change: int = Game.daily_income - Game.daily_expenses
	UI.kv(summary, Loc.t("home_cash_change"), Loc.money(cash_change), UI.C_GOOD if cash_change >= 0 else UI.C_BAD)
	var listed := 0
	for car in Game.cars:
		if bool(car.get("listed", false)): listed += 1
	UI.kv(summary, Loc.t("kpi_listed"), str(listed))
	UI.kv(summary, Loc.t("kpi_customers"), str(Game.visits.size()))
	UI.kv(summary, Loc.t("capacity"), "%d / %d" % [Game.cars.size(), Game.garage_cap])
	UI.kv(summary, Loc.t("reputation_line", [Game.rep]), "")
	var city := UI.add_card(sc, UI.C_PANEL2, 14, UI.C_LINE)
	var traffic := RoadAnim.new()
	traffic.custom_minimum_size.y = 140
	traffic.home_scene = true
	city.add_child(traffic)
	_weather_label=UI.lbl("",14,UI.C_TEXT)
	city.add_child(_weather_label)
	_update_weather()
	city.add_child(UI.lbl(Loc.t("life_weather_hint"),12,UI.C_MUTED))
