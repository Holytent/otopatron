extends SceneTree
var failures: int = 0
var checks: int = 0

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	await process_frame
	var game: Node = root.get_node("Game")
	game.set_process(false)
	game.new_game("Balance Check", "34")
	game.settings["sfx"] = 0.0
	game.settings["vibe"] = false
	game.rng.seed = 1802026
	game.news = {"id": "calm", "cm": {}, "dm": 1.0}
	game.weather = {"id": "sunny", "dm": 1.0}
	var seller: Dictionary = {"ask": 100000, "reserve": 93000, "mood": 100.0}
	var first: Dictionary = game.negotiate(seller, 88000)
	var second: Dictionary = game.negotiate(seller, 90000)
	check(int(first["price"]) < 100000, "100k seller gives discount")
	check(int(second["price"]) < int(first["price"]), "Seller counter moves down")
	var final_reply: Dictionary = game.negotiate(seller, game.seller_floor(seller) + 500)
	check(str(final_reply["kind"]) == "accept", "Reasonable third seller offer accepted")
	var buyer: Dictionary = {"max_pay": 120000, "offer": 100000, "mood": 100.0}
	var b1: Dictionary = game.customer_reply(buyer, 125000)
	var b2: Dictionary = game.customer_reply(buyer, 123000)
	check(int(b1["price"]) > 100000, "Buyer raises offer")
	check(int(b2["price"]) > int(b1["price"]), "Buyer counter continues moving")
	check(str(game.customer_reply(buyer, 120000)["kind"]) == "accept", "Buyer accepts budget on third round")
	check(int(buyer["offer"]) <= int(buyer["max_pay"]), "Buyer budget respected")
	var old: Dictionary = game.to_dict()
	old["version"] = 3
	old["money"] = 234567
	old["market"] = [{"ask": 100000, "reserve": 100000, "mood": 0.0}]
	game.from_dict(old)
	check(game.money == 234567, "Migration preserves balance")
	check(int(game.market[0]["reserve"]) == 93000, "Migration unlocks old 100k listings")
	check(float(game.market[0]["mood"]) == 100.0, "Migration restores blocked sellers")
	var now: float = game.now_seconds()
	game.visits = [{"name": "Test", "expires_at": now - 1.0, "accepted": false}]
	var reputation: int = game.rep
	game.begin_negotiation()
	game._customer_tick_at = now - 30.0
	game.process_live_customers()
	check(game.visits.size() == 1 and game.rep == reputation, "Negotiation suspends waiting penalty")
	check(float(game.visits[0]["expires_at"]) > now + 28.0, "Waiting deadline extended")
	game.end_negotiation()
	check(game._negotiation_depth == 0, "Negotiation lease closes")
	game.visits = []
	game.level = 1
	game.rep = 10
	game.market = []
	game.cars = []
	game.news = {"id": "calm", "cm": {}, "dm": 1.0}
	game.weather = {"id": "sunny", "dm": 1.0}
	var margins: Array[float] = []
	var profitable: int = 0
	for i in 300:
		var listing: Dictionary = game.gen_listing()
		var car: Dictionary = listing["car"]
		var purchase: int = game.seller_floor(listing) + 1000
		var maintenance: int = 0
		for part in game.PARTS:
			maintenance += game.repair_cost(car, str(part))
			car["parts"][part] = 95.0
		maintenance += game.clean_cost(car)
		car["clean"] = 100.0
		car["list_price"] = game.suggested_price(car)
		car["uid"] = game.next_uid()
		game._make_visit(car)
		var visit: Dictionary = game.visits.pop_back()
		check(float(visit["expires_at"]) >= game.now_seconds() + 89.0, "90 second deadline")
		var sale: int = mini(int(visit["max_pay"]), int(car["list_price"]))
		var cost: int = purchase + maintenance
		var margin: float = float(sale - cost) / cost * 100.0
		margins.append(margin)
		if margin > 0.0: profitable += 1
		var result: Dictionary = {}
		for turn in 3:
			result = game.customer_reply(visit, sale)
			if str(result["kind"]) == "accept": break
		check(str(result["kind"]) == "accept", "Feasible sale accepted within three rounds")
	margins.sort()
	var median: float = margins[150]
	print("BALANCE_METRICS median_profit_percent=", snappedf(median, 0.1), " profitable_trades=", profitable, "/300 p10=", snappedf(margins[30], 0.1), " p90=", snappedf(margins[270], 0.1))
	check(median >= 15.0 and median <= 25.0, "Typical maintained sale margin 15-25%")
	print("BALANCE_CHECKS count=", checks, " failures=", failures)
	for child in root.get_children():
		child.queue_free()
	await process_frame
	await process_frame
	quit(1 if failures > 0 else 0)
