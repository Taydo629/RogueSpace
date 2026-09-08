class_name EnergyComponent extends Node

@export var energy_prod_per_sec: float = 100.0
@export var max_energy: float = 10000
var current_energy: float
var shield_energy: float
var movement_energy: float
var weapon_energy: float

enum ENERGY_ROUTES{SHIELDS, MOVEMENT, WEAPONS}
var energy_pips: Dictionary[ENERGY_ROUTES, int] = {
	ENERGY_ROUTES.SHIELDS: 2,
	ENERGY_ROUTES.MOVEMENT: 2,
	ENERGY_ROUTES.WEAPONS: 2
}
const MAX_PIPS_PER_ROUTE: int = 4
const MIN_PIPS_PER_ROUTE: int = 1
const TOTAL_PIPS: int = 6

func _ready() -> void:
	current_energy = max_energy
	update_energy_split()

func _process(delta: float) -> void:
	generate_energy(delta)
	# For testing purposes
	if Input.is_action_just_pressed("1"):
		reroute_energy(ENERGY_ROUTES.SHIELDS)
	if Input.is_action_just_pressed("2"):
		reroute_energy(ENERGY_ROUTES.MOVEMENT)
	if Input.is_action_just_pressed("3"):
		reroute_energy(ENERGY_ROUTES.WEAPONS)
	update_energy_split()

func reroute_energy(route_to_add: ENERGY_ROUTES) -> void:
	var current_route_pips: int = energy_pips.get(route_to_add)
	if current_route_pips == MAX_PIPS_PER_ROUTE:
		# Cannot add more pips to this route
		return
	# Get current pip values
	var pips_array: Array[int] = energy_pips.values()
	# remove the pip which we plan on adding to
	pips_array.erase(current_route_pips)
	var highest_pips_route: int = pips_array.max()
	# Return if next highest pips is 1 as there is nothing to remove
	if highest_pips_route == MIN_PIPS_PER_ROUTE:
		return
	else:
		var key_to_remove_pip_from: ENERGY_ROUTES
		for key in energy_pips.keys():
			if energy_pips.get(key) == highest_pips_route and key != route_to_add:
				key_to_remove_pip_from = key
				break
		# Remove pip
		energy_pips.set(key_to_remove_pip_from, energy_pips.get(key_to_remove_pip_from)-1)
		# Add pip
		energy_pips.set(route_to_add, energy_pips.get(route_to_add)+1)
	update_energy_split()
	print("Shield energy %d, Movement energy %d, Weapon energy %d" % [shield_energy,movement_energy,weapon_energy])

func update_energy_split() -> void:
	var energy_per_pip: float = current_energy / TOTAL_PIPS
	shield_energy = energy_pips.get(ENERGY_ROUTES.SHIELDS) * energy_per_pip
	movement_energy = energy_pips.get(ENERGY_ROUTES.MOVEMENT) * energy_per_pip
	weapon_energy = energy_pips.get(ENERGY_ROUTES.WEAPONS) * energy_per_pip

func generate_energy(delta: float) -> void:
	var new_energy: float = delta * energy_prod_per_sec + current_energy
	if new_energy > max_energy:
		current_energy = max_energy
	else:
		current_energy = new_energy

func use_energy(energy_cost: float) -> bool:
	var new_energy: float = current_energy - energy_cost
	if new_energy < 0.0:
		return false
	else:
		current_energy = new_energy
		return true
	
