extends Node
## Tek çeviri sistemi. Tüm arayüz metinleri Loc.t("anahtar") üzerinden gelir.

signal language_changed

const LANGS: Dictionary = {"tr": "Türkçe", "en": "English", "ar": "العربية", "fr": "Français"}

var lang: String = "tr"


func is_rtl() -> bool:
	return lang == "ar"


func set_lang(code: String) -> void:
	if not LANGS.has(code):
		return
	lang = code
	TranslationServer.set_locale(code)
	language_changed.emit()


func t(key: String, args: Array = []) -> String:
	var entry: Variant = GameplayText.TEXT.get(key, ExpansionText.TEXT.get(key, Strings.TEXT.get(key)))
	if entry == null:
		push_warning("Eksik çeviri anahtarı: " + key)
		return key
	var s: String = entry.get(lang, entry.get("en", key))
	for i in args.size():
		s = s.replace("{%d}" % i, str(args[i]))
	return display_text(s)

# Repairs legacy double-decoded UTF-8 without changing already correct text.
const LEGACY_TEXT: Dictionary = {"\u00e2\u201a\u00ac": "\u20ac", "\u00e2\u0082\u00ac": "\u20ac", "\u00e2\u20ac\u201c": "\u2013", "\u00e2\u0080\u0093": "\u2013", "\u00e2\u20ac\u201d": "\u2014", "\u00e2\u0080\u0094": "\u2014", "\u00e2\u20ac\u2122": "\u2019", "\u00e2\u0080\u0099": "\u2019", "\u00e2\u20ac\u0153": "\u201c", "\u00e2\u0080\u009c": "\u201c", "\u00e2\u0080\u009d": "\u201d", "\u00e2\u2122\u00a5": "\u2665", "\u00e2\u0099\u00a5": "\u2665", "\u00e2\u02dc\u2026": "\u2605", "\u00e2\u0098\u0085": "\u2605", "\u00e2\u2122\u00a6": "\u2666", "\u00e2\u0099\u00a6": "\u2666", "\u00e2\u2020\u2019": "\u2192", "\u00e2\u0086\u0092": "\u2192", "\u00c3\u00a7": "\u00e7", "\u00c4\u0178": "\u011f", "\u00c4\u009f": "\u011f", "\u00c4\u00b1": "\u0131", "\u00c3\u00b6": "\u00f6", "\u00c5\u0178": "\u015f", "\u00c5\u009f": "\u015f", "\u00c3\u00bc": "\u00fc", "\u00c3\u2021": "\u00c7", "\u00c3\u0087": "\u00c7", "\u00c4\u017e": "\u011e", "\u00c4\u009e": "\u011e", "\u00c4\u00b0": "\u0130", "\u00c3\u2013": "\u00d6", "\u00c3\u0096": "\u00d6", "\u00c5\u017e": "\u015e", "\u00c5\u009e": "\u015e", "\u00c3\u0153": "\u00dc", "\u00c3\u009c": "\u00dc", "\u00c3\u00a9": "\u00e9", "\u00c3\u00a8": "\u00e8", "\u00c3\u00aa": "\u00ea", "\u00c3\u00ab": "\u00eb", "\u00c3\u00a0": "\u00e0", "\u00c3\u00a2": "\u00e2", "\u00c3\u00ae": "\u00ee", "\u00c3\u00af": "\u00ef", "\u00c3\u00b4": "\u00f4", "\u00c3\u00bb": "\u00fb", "\u00c3\u00b9": "\u00f9", "\u00c3\u2030": "\u00c9", "\u00c3\u0089": "\u00c9", "\u00c3\u02c6": "\u00c8", "\u00c3\u0088": "\u00c8", "\u00c3\u0160": "\u00ca", "\u00c3\u008a": "\u00ca", "\u00c3\u2039": "\u00cb", "\u00c3\u008b": "\u00cb", "\u00c3\u20ac": "\u00c0", "\u00c3\u0080": "\u00c0", "\u00c3\u201a": "\u00c2", "\u00c3\u0082": "\u00c2", "\u00c3\u017d": "\u00ce", "\u00c3\u008e": "\u00ce", "\u00c3\u008f": "\u00cf", "\u00c3\u201d": "\u00d4", "\u00c3\u0094": "\u00d4", "\u00c3\u203a": "\u00db", "\u00c3\u009b": "\u00db", "\u00c3\u2122": "\u00d9", "\u00c3\u0099": "\u00d9", "\u00c3\u00b1": "\u00f1", "\u00c3\u2018": "\u00d1", "\u00c3\u0091": "\u00d1", "\u00c3\u00a1": "\u00e1", "\u00c3\u00ad": "\u00ed", "\u00c3\u00b3": "\u00f3", "\u00c3\u00ba": "\u00fa", "\u00c3\u0081": "\u00c1", "\u00c3\u008d": "\u00cd", "\u00c3\u201c": "\u00d3", "\u00c3\u0093": "\u00d3", "\u00c3\u0161": "\u00da", "\u00c3\u009a": "\u00da", "\u00c3\u00a4": "\u00e4", "\u00c3\u201e": "\u00c4", "\u00c3\u0084": "\u00c4", "\u00c3\u0178": "\u00df", "\u00c3\u009f": "\u00df", "\u00c2\u00b7": "\u00b7"}
func repair_text(text: String) -> String:
	if not (text.contains("Ã") or text.contains("Å") or text.contains("Ä") or text.contains("Â") or text.contains("â") or text.contains("ð")): return text
	var result := text
	for pass_number in 3:
		var previous := result
		for broken in LEGACY_TEXT: result = result.replace(broken,LEGACY_TEXT[broken])
		if result == previous: break
	return result

func display_text(text: String) -> String:
	text = repair_text(text)
	var gem_word: String = {"tr": "elmas", "en": "gems", "fr": "gemmes", "ar": "ألماس"}.get(lang, "gems")
	return text.replace("♦", gem_word).replace("＋", "+").replace("−", "-")


## prefix_1, prefix_2, ... anahtarlarından rastgele birini seçer (konuşma çeşitliliği).
func t_rand(prefix: String, args: Array = []) -> String:
	var n := 0
	while Strings.TEXT.has("%s_%d" % [prefix, n + 1]):
		n += 1
	if n == 0:
		return t(prefix, args)
	return t("%s_%d" % [prefix, Game.rng.randi_range(1, n)], args)


func money(n: int) -> String:
	var neg := n < 0
	var s := str(absi(n))
	var sep := "."
	if lang == "en" or lang == "ar":
		sep = ","
	elif lang == "fr":
		sep = " "
	var out := ""
	var cnt := 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		cnt += 1
		if cnt % 3 == 0 and i > 0:
			out = sep + out
	return ("-" if neg else "") + "₺" + out


func num(n: int) -> String:
	return money(n).replace("₺", "")
