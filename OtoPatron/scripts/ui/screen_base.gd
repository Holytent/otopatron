class_name ScreenBase
extends VBoxContainer
## Tüm ekranların ortak tabanı. _build() içinde arayüz kurulur; rebuild() durumu yeniler.

var params: Dictionary = {}


func _ready() -> void:
	add_theme_constant_override("separation", 12)
	_build()


func _build() -> void:
	pass


func rebuild() -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()
	_build()


static func effect_text(n: Dictionary) -> String:
	var parts: Array = []
	var cm: Dictionary = n.get("cm", {})
	for k in cm.keys():
		parts.append("%s %s" % [Loc.t("cls_%s" % k), pct(float(cm[k]))])
	var dm := float(n.get("dm", 1.0))
	if absf(dm - 1.0) > 0.001:
		parts.append("%s %s" % [Loc.t("fx_demand"), pct(dm)])
	return ", ".join(parts) if not parts.is_empty() else Loc.t("fx_none")


static func pct(m: float) -> String:
	return "%+d%%" % int(round((m - 1.0) * 100.0))


static func city_name(c: String) -> String:
	return CityDB.city_name(c)
