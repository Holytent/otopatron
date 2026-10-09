extends Node
## Ekonomi simülasyonu: godot --headless --path . -- --econ
func run(_main: Node) -> void:
	await get_tree().process_frame
	Game.new_game("Sim", "34")
	var flips := 0
	var days_used := 0
	var profits: Array = []
	var level_hit := {}
	while Game.level < 7 and flips < 400:
		# en ucuz / değerine göre en avantajlı ilanı seç
		var best: Dictionary = {}
		var best_ratio := 9.0
		for l in Game.market:
			var r := float(l["ask"]) / float(Game.car_value(l["car"]))
			if r < best_ratio:
				best_ratio = r
				best = l
		if best.is_empty() or Game.cars.size() >= Game.garage_cap:
			Game.end_day()
			continue
		var car: Dictionary = best["car"]
		var price := int(best["ask"])
		for f in [0.86, 0.9, 0.94, 0.97]:
			var r := Game.negotiate(best, Game.r500(int(best["ask"]) * f))
			if r["kind"] == "accept":
				price = int(r["price"])
				break
			if float(best["mood"]) <= 0.0:
				break
		if Game.buy_listing(best, price) != "ok":
			Game.end_day()
			continue
		# basit hazırlık: ucuz parçaları onar
		for p in ["tires", "interior"]:
			if Game.repair_cost(car, p) < 4000:
				Game.repair_part(car, p)
		Game.clean_car(car)
		var lp := Game.r500(Game.car_value(car) * 1.06)
		Game.set_listed(car, true, lp)
		var sold := false
		var tries := 0
		while not sold and tries < 30:
			Game.end_day()
			tries += 1
			for v in Game.visits.duplicate():
				var c := Game.car_by_uid(int(v["car_uid"]))
				if c.is_empty():
					continue
				var rep := Game.customer_reply(v, int(c["list_price"]))
				var sp := int(c["list_price"]) if rep["kind"] == "accept" else int(v["offer"])
				var res := Game.finalize_sale(c, sp)
				if not res.is_empty():
					profits.append(int(res["profit"]))
					sold = true
					break
			if tries == 8 and not sold:
				car["list_price"] = Game.r500(Game.car_value(car) * 1.0)
		if not sold:
			Game.sell_to_dealer(car)
		flips += 1
		if not level_hit.has(Game.level):
			level_hit[Game.level] = {"flips": flips, "day": Game.day, "money": Game.money}
	var tot := 0
	for p in profits:
		tot += int(p)
	print("flip: %d  satış: %d  ort kâr: %d  gün: %d  bakiye: %d" % [flips, profits.size(), tot / maxi(profits.size(), 1), Game.day, Game.money])
	print("seviye eşikleri: ", level_hit)
	get_tree().quit()
