extends Node

var inventory: Array
var wallet: int = 1000
var ammo: int = 1000
var explosives: int = 0
var number_of_hull: int = 6
var number_of_thruster: int = 3
var number_of_gun: int = 2
var number_of_laser: int = 2
var number_of_tractor_beam: int = 1

const CORE = preload("uid://dxn6vqjt4j07d")
const GUN = preload("uid://bs8ufgr7qnr1y")
const HULL = preload("uid://bu4cdhp5bisf5")
const THRUSTER = preload("uid://b4k0ewhy4bwpf")
const TRACTOR_BEAM = preload("uid://nxtyhwldok2c")
const LASER = preload("uid://f60asy2hl75j")


signal item_pickup
signal credit_changed(current_credit: int)
signal ammo_changed(current_ammo: int)
signal explosives_changed(current_explosives: int)

func init_inventory() -> void:
	print("initialise starting items")
	inventory.clear()
	wallet = 1000
	ammo = 1000
	explosives = 0
	var i: int = 0
	add_item(CORE)
	while i < number_of_hull:
		if i < number_of_gun:
			add_item(GUN)
		if i < number_of_laser:
			add_item(LASER)
		if i < number_of_thruster:
			add_item(THRUSTER)
		if i < number_of_hull:
			add_item(HULL)
		if i < number_of_tractor_beam:
			add_item(TRACTOR_BEAM)
		i += 1

func add_item(part: Part) -> void:
	print("%s collected!" % part.name)
	inventory.append(part)
	item_pickup.emit(part)

func remove_item(part: Part) -> void:
	print("%s removed!" % part.name)
	inventory.erase(part)

func deposit_to_wallet(credits: int) -> void:
	wallet += credits
	credit_changed.emit(wallet)

func withdraw_from_wallet(credits: int) -> bool:
	var new_balance = wallet - credits
	if new_balance >= 0:
		wallet = new_balance
		credit_changed.emit(wallet)
		print_debug("Withdrawal Success")
		return true
	else:
		return false

func add_ammo(added_ammo: int) -> void:
	ammo += added_ammo
	ammo_changed.emit(ammo)

func subtract_ammo(ammo_to_subtract: int) -> bool:
	var new_ammo = ammo - ammo_to_subtract
	if new_ammo >= 0:
		ammo = new_ammo
		ammo_changed.emit(ammo)
		return true
	else:
		return false

func add_explosive(added_explosive: int) -> void:
	explosives += added_explosive
	explosives_changed.emit(explosives)

func subtract_explosive(explosive_to_subtract: int) -> bool:
	var new_explosive = ammo - explosive_to_subtract
	if new_explosive >= 0:
		explosives = new_explosive
		explosives_changed.emit(explosives)
		return true
	else:
		return false
		
