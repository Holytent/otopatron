class_name CityDB
extends RefCounted
## Türkiye'nin 81 ili. Plaka kodu ("01".."81") şehir kimliğidir. Bölge iklimi hava sıcaklığını,
## nüfus kademesi müşteri akışını etkiler.

const NAMES: Array = [
	"Adana", "Adıyaman", "Afyonkarahisar", "Ağrı", "Amasya", "Ankara", "Antalya", "Artvin", "Aydın", "Balıkesir",
	"Bilecik", "Bingöl", "Bitlis", "Bolu", "Burdur", "Bursa", "Çanakkale", "Çankırı", "Çorum", "Denizli",
	"Diyarbakır", "Edirne", "Elazığ", "Erzincan", "Erzurum", "Eskişehir", "Gaziantep", "Giresun", "Gümüşhane", "Hakkâri",
	"Hatay", "Isparta", "Mersin", "İstanbul", "İzmir", "Kars", "Kastamonu", "Kayseri", "Kırklareli", "Kırşehir",
	"Kocaeli", "Konya", "Kütahya", "Malatya", "Manisa", "Kahramanmaraş", "Mardin", "Muğla", "Muş", "Nevşehir",
	"Niğde", "Ordu", "Rize", "Sakarya", "Samsun", "Siirt", "Sinop", "Sivas", "Tekirdağ", "Tokat",
	"Trabzon", "Tunceli", "Şanlıurfa", "Uşak", "Van", "Yozgat", "Zonguldak", "Aksaray", "Bayburt", "Karaman",
	"Kırıkkale", "Batman", "Şırnak", "Bartın", "Ardahan", "Iğdır", "Yalova", "Karabük", "Kilis", "Osmaniye", "Düzce",
]

const ZONES: Dictionary = {
	"marmara": [10, 11, 16, 17, 22, 34, 39, 41, 54, 59, 77],
	"ege": [3, 9, 20, 35, 43, 45, 48, 64],
	"akdeniz": [1, 7, 15, 31, 32, 33, 46, 80],
	"ic": [6, 18, 26, 38, 40, 42, 50, 51, 58, 66, 68, 70, 71],
	"karadeniz": [5, 8, 14, 19, 28, 29, 37, 52, 53, 55, 57, 60, 61, 67, 69, 74, 78, 81],
	"dogu": [4, 12, 13, 23, 24, 25, 30, 36, 44, 49, 62, 65, 75, 76],
	"gdogu": [2, 21, 27, 47, 56, 63, 72, 73, 79],
}

const TEMPS: Dictionary = {
	"marmara": [6, 6, 8, 12, 17, 22, 25, 25, 21, 16, 12, 8],
	"ege": [9, 10, 12, 16, 21, 26, 29, 29, 25, 20, 14, 10],
	"akdeniz": [11, 12, 14, 18, 22, 27, 30, 30, 27, 22, 16, 12],
	"ic": [1, 3, 7, 12, 16, 20, 24, 24, 19, 13, 7, 3],
	"karadeniz": [7, 7, 9, 13, 17, 21, 24, 24, 21, 17, 12, 9],
	"dogu": [-6, -4, 1, 8, 13, 18, 23, 23, 18, 11, 3, -3],
	"gdogu": [7, 9, 13, 18, 25, 31, 35, 35, 30, 23, 14, 8],
}

const BIG: Array = [1, 7, 16, 21, 26, 27, 33, 38, 41, 42, 55, 61, 63, 20, 45, 54, 59]
const SMALL: Array = [69, 62, 75, 79, 30, 73, 29, 57, 74, 76, 56, 49, 12, 13, 24, 15, 40, 68, 50, 70, 71, 77, 39, 11, 81, 78, 18, 66]


static func code(n: int) -> String:
	return "%02d" % n


static func all_codes() -> Array:
	var out: Array = []
	for i in NAMES.size():
		out.append(code(i + 1))
	return out


static func normalize(c: String) -> String:
	if c == "ist":
		return "34"
	if c == "ank":
		return "06"
	if c.is_valid_int() and int(c) >= 1 and int(c) <= 81:
		return code(int(c))
	return "34"


static func city_name(c: String) -> String:
	var n := int(normalize(c))
	return NAMES[n - 1]


static func zone(c: String) -> String:
	var n := int(normalize(c))
	for z in ZONES.keys():
		if n in ZONES[z]:
			return z
	return "ic"


## Müşteri akışı çarpanı (nüfus/ticaret hacmi).
static func demand(c: String) -> float:
	var n := int(normalize(c))
	if n == 34:
		return 1.10
	if n == 6 or n == 35:
		return 1.07
	if n in BIG:
		return 1.03
	if n in SMALL:
		return 0.94
	return 1.0


static func is_metro(c: String) -> bool:
	var n := int(normalize(c))
	return n == 34 or n == 6 or n == 35


static func temp(c: String, month: int) -> int:
	return int(TEMPS[zone(c)][month - 1])


static func fold(s: String) -> String:
	var t := s.to_lower()
	var m := {"ı": "i", "İ": "i", "i̇": "i", "ş": "s", "ğ": "g", "ü": "u", "ö": "o", "ç": "c", "â": "a", "î": "i", "û": "u"}
	for k in m.keys():
		t = t.replace(k, m[k])
	return t
