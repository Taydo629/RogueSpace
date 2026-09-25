class_name BaseEnergyWeapon extends BasePart

# Weapon related exports
#@onready var fire_sound: AudioStreamPlayer2D = $FireSound
@onready var laser_beam_2d: RayCast2D = $LaserBeam2D
# Not used but could be used in future for configurable control
var activation_key: String
var laser_on: bool = false
var dps: float
var energy_per_sec: float
var part:Part:
	set(value):
		sprite = value.image
		max_health = value.max_health
		health = value.current_health
		dps = value.dps
		energy_per_sec = value.energy_p_s
		part = value

func _process(delta: float) -> void:
	if laser_on:
		var energy_component: EnergyComponent = parent.energy_component
		if not energy_component.use_energy(energy_per_sec * delta, energy_component.ENERGY_ROUTES.WEAPONS):
			toggle_weapon(parent, false)

func toggle_weapon(_parent_node: RigidBody2D, toggle: bool) -> void:
	print("Firing Laser")
	if toggle:
		laser_on = true
		laser_beam_2d.set_is_casting(true)
	else:
		laser_on = false
		laser_beam_2d.set_is_casting(false)
