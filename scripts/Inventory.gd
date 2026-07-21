extends Node

var inventory: Array
var number_of_hull: int = 6
var number_of_thruster: int = 3
var number_of_gun: int = 2
const CORE = preload("uid://dxn6vqjt4j07d")
const GUN = preload("uid://bs8ufgr7qnr1y")
const HULL = preload("uid://rp4s55105tbn")
const THRUSTER = preload("uid://b4k0ewhy4bwpf")


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
		i += 1
	print(inventory)

func add_item(part: Part) -> void:
	inventory.append(part)

func remove_item(part: Part) -> void:
	inventory.erase(part)
