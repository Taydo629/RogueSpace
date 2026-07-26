extends Node

var inventory: Array
var wallet: int = 0
var number_of_hull: int = 6
var number_of_thruster: int = 3
var number_of_gun: int = 2
var number_of_tractor_beam: int = 1

const CORE = preload("uid://dxn6vqjt4j07d")
const GUN = preload("uid://bs8ufgr7qnr1y")
const HULL = preload("uid://rp4s55105tbn")
const THRUSTER = preload("uid://b4k0ewhy4bwpf")
const TRACTOR_BEAM = preload("uid://nxtyhwldok2c")

signal item_pickup
signal credit_changed

func _ready() -> void:
	print("initialise starting items")
	var i: int = 0
	add_item(CORE)
	while i < number_of_hull:
		if i < number_of_gun:
			add_item(GUN)
		if i < number_of_thruster:
			add_item(THRUSTER)
		if i < number_of_hull:
			add_item(HULL)
		if i < number_of_tractor_beam:
			add_item(TRACTOR_BEAM)
		i += 1

func add_item(part: Part) -> void:
	inventory.append(part)
	item_pickup.emit(part)
	#print("test")
	#print(len(inventory))
	#print(inventory)

func remove_item(part: Part) -> void:
	inventory.erase(part)

func deposit_to_wallet(credits: int) -> void:
	wallet += credits
	credit_changed.emit(wallet)

func withdraw_from_wallet(credits: int) -> bool:
	var new_balance = wallet - credits
	if new_balance >= 0:
		wallet = new_balance
		credit_changed.emit(wallet)
		return true
	else:
		return false
