class_name ReleaseInfo
extends RefCounted
## Update VERSION each release. NOTES contains at most three major player-facing
## changes. Omit minor fixes and technical details; never invent additions.
const VERSION: String = "1.9.42"
const NOTES: Dictionary = {"tr": ["Performans iyileştirildi.", "Optimizasyon yapıldı."], "en": ["Performance improved.", "Optimizations applied."], "fr": ["Performances améliorées.", "Optimisations effectuées."], "ar": ["تحسين الأداء.", "تم تحسين اللعبة."]}
static var _panel: Control

static func show_if_new() -> void:
	if NOTES.get(Loc.lang, NOTES["en"]).is_empty():
		Game.settings["seen_release"] = VERSION
		Game.save_settings()
		return
	if str(Game.settings.get("seen_release", "")) != VERSION:
		show_notes()

static func show_notes() -> void:
	if not is_instance_valid(UI.overlay) or is_instance_valid(_panel): return
	var card := UI.dialog_card(Loc.t("release_title", [VERSION]))
	card.add_child(UI.lbl(Loc.t("release_intro"), 14, UI.C_MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 260)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	card.add_child(scroll)
	var body := UI.vbox(null, 12)
	for note in NOTES.get(Loc.lang, NOTES["en"]).slice(0, 3):
		body.add_child(UI.lbl("• " + str(note), 15, UI.C_TEXT))
	scroll.add_child(body)
	_panel = UI.show_dialog(card)
	card.add_child(UI.btn(Loc.t("release_ack"), "primary", func():
		Game.settings["seen_release"] = VERSION
		Game.save_settings()
		_panel.queue_free(), 52))
