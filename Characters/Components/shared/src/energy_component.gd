class_name EnergyComponent extends Node

@export var energy_prod_percent_per_sec: float = 10.0
@export var max_energy: float = 10000

enum ENERGY_ROUTES{SHIELDS, MOVEMENT, WEAPONS}
var energy_pips: Dictionary[ENERGY_ROUTES, Dictionary] = {
	ENERGY_ROUTES.SHIELDS: {
		"pips": 2,
		"max_energy": 0,
		"current_energy": 0
	},
	ENERGY_ROUTES.MOVEMENT: {
		"pips": 2,
		"max_energy": 0,
		"current_energy": 0
	},
	ENERGY_ROUTES.WEAPONS: {
		"pips": 2,
		"max_energy": 0,
		"current_energy": 0
	},
}
const MAX_PIPS_PER_ROUTE: int = 4
const MIN_PIPS_PER_ROUTE: int = 1
const TOTAL_PIPS: int = 6

func _ready() -> void:
	init_energy_pips()

func init_energy_pips() -> void:
	for route in energy_pips.keys():
		var energy_route: Dictionary = energy_pips.get(route)
		var max_energy_of_route: float = (float(energy_route.get("pips"))/float(TOTAL_PIPS)) * max_energy
		energy_pips.get(route).max_energy = max_energy_of_route
		energy_pips.get(route).current_energy = 0#max_energy_of_route

func _process(delta: float) -> void:
	generate_energy(delta)
	## For testing purposes
	#if Input.is_action_just_pressed("1"):
		#reroute_energy(ENERGY_ROUTES.SHIELDS)
	#if Input.is_action_just_pressed("2"):
		#reroute_energy(ENERGY_ROUTES.MOVEMENT)
	#if Input.is_action_just_pressed("3"):
		#reroute_energy(ENERGY_ROUTES.WEAPONS)

func reroute_energy(route_to_add: ENERGY_ROUTES) -> void:
	print("rerouting energy")
	var current_route_pips: int = energy_pips.get(route_to_add).pips
	if current_route_pips == MAX_PIPS_PER_ROUTE:
		# Cannot add more pips to this route
		return
	# Get current pip values
	var pips_array: Array[int]
	for route in energy_pips.values():
		pips_array.append(route.pips)
	# remove the pip which we plan on adding to
	pips_array.erase(current_route_pips)
	var highest_pips_route: int = pips_array.max()
	# Return if next highest pips is 1 as there is nothing to remove
	if highest_pips_route == MIN_PIPS_PER_ROUTE:
		return
	else:
		var key_to_remove_pip_from: ENERGY_ROUTES
		for key in energy_pips.keys():
			if energy_pips.get(key).pips == highest_pips_route and key != route_to_add:
				key_to_remove_pip_from = key
				break
		# Calculate energy_per_pip to find how much leftover energy needs to be sent to new route
		var energy_per_pip: float = (1/float(TOTAL_PIPS)) * max_energy
		var current_energy_in_route: float = energy_pips.get(key_to_remove_pip_from).current_energy
		var energy_to_move: float = current_energy_in_route - (highest_pips_route-1) * energy_per_pip
		if energy_to_move < 0:
			energy_to_move = 0
		# Remove pip move any leftover energy and update the max_energy
		energy_pips.get(key_to_remove_pip_from).pips =  energy_pips.get(key_to_remove_pip_from).pips - 1
		energy_pips.get(key_to_remove_pip_from).current_energy = energy_pips.get(key_to_remove_pip_from).current_energy - energy_to_move
		energy_pips.get(key_to_remove_pip_from).max_energy = energy_pips.get(key_to_remove_pip_from).pips * energy_per_pip
		# Add pip move any leftover energy and update the max_energy
		energy_pips.get(route_to_add).pips =  energy_pips.get(route_to_add).pips + 1
		energy_pips.get(route_to_add).current_energy = energy_pips.get(route_to_add).current_energy + energy_to_move
		energy_pips.get(route_to_add).max_energy = energy_pips.get(route_to_add).pips * energy_per_pip

func generate_energy(delta: float) -> void:
	for route in energy_pips.keys():
		var energy_route: Dictionary = energy_pips.get(route)
		var frac_total_pips: float = float(energy_route.get("pips"))/float(TOTAL_PIPS)
		var max_energy_of_route: float = frac_total_pips * max_energy
		var energy_charged: float = energy_route.max_energy * frac_total_pips * (energy_prod_percent_per_sec/100) * delta
		var new_current_energy: float = energy_route.current_energy + energy_charged
		if new_current_energy > energy_route.max_energy:
			new_current_energy = energy_route.max_energy
		energy_pips.get(route).current_energy = new_current_energy

func use_energy(energy_cost: float, route: ENERGY_ROUTES) -> bool:
	var new_energy: float = energy_pips.get(route).current_energy - energy_cost
	if new_energy < 0.0:
		return false
	else:
		energy_pips.get(route).current_energy = new_energy
		return true
	
