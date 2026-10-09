class_name CustomerOrders
extends RefCounted
## Persisted game-day contracts. Uses the existing sale path and save schema.
static func board() -> Array:
	if not Game.flags.has("order_board") or Game.day >= int(Game.flags.get("order_refresh",0)):
		var pool: Array = CarDB.MODELS.filter(func(m): return int(m["min_level"]) <= Game.level)
		var offers: Array = []
		for i in 3:
			var model: Dictionary = pool[(Game.day*7+i*3)%pool.size()]
			var budget: int = Game.r500(float(model["base"])*.9)
			offers.append({"id":Game.next_uid(),"name":["Deniz","Ece","Mert"][(Game.day+i)%3],"cls":model["cls"],"budget":budget,"bonus":Game.r500(budget*.04),"due":Game.day+3,"status":"open"})
		Game.flags["order_board"] = offers
		Game.flags["order_refresh"] = Game.day+3
		Game.save_game()
	return Game.flags["order_board"]
static func find(id: int) -> Dictionary:
	for order in board():
		if int(order["id"]) == id: return order
	return {}
static func active() -> bool:
	for order in board():
		if order["status"] == "accepted": return true
	return false
static func accept(id: int) -> bool:
	var order := find(id)
	if order.is_empty() or order["status"] != "open" or active(): return false
	order["status"] = "accepted"
	Game.save_game()
	return true
static func eligible(order: Dictionary, car: Dictionary) -> bool:
	if order.is_empty() or order["status"] != "accepted" or Game.day >= int(order["due"]): return false
	if not Game.cars.has(car) or Game.sold_ids.has("sale_%d" % int(car["uid"])): return false
	if str(CarDB.model(str(car["model"]))["cls"]) != str(order["cls"]) or Game.car_value(car) > int(order["budget"]): return false
	if float(car["clean"]) < 80.0: return false
	for part in ["engine","body","tires","interior"]:
		if not bool(car["known"].get(part,false)) or float(car["parts"][part]) < 70.0: return false
	return true
static func price(order: Dictionary, car: Dictionary) -> int:
	return mini(int(order["budget"]),Game.r500(Game.car_value(car)*1.08))
static func deliver(id: int, uid: int) -> Dictionary:
	var order := find(id)
	var car: Dictionary = Game.car_by_uid(uid)
	if car.is_empty() or not eligible(order,car): return {}
	# Complete before finalize_sale saves, preventing duplicate rewards after reload.
	order["status"] = "done"
	Game.flags["orders_completed"] = int(Game.flags.get("orders_completed",0))+1
	var result: Dictionary = Game.finalize_sale(car,price(order,car),int(order["bonus"]))
	if result.is_empty():
		order["status"] = "accepted"
		Game.flags["orders_completed"] = int(Game.flags["orders_completed"])-1
		return {}
	Game.changed.emit()
	return result
