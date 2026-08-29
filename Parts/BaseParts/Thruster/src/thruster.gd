class_name Thruster extends BasePart

# Not used but could be used in future for configurable control
var activation_key: String
@onready var thruster_particles: CPUParticles2D = $ThrusterParticles
@onready var thruster_light: PointLight2D = $ThrusterParticles/ThrusterLight
@onready var thruster_sound: AudioStreamPlayer2D = $ThrusterSound

var thrust_force: int

func _ready() -> void:
	# Connect the parts destroyed signal to the player ship if possible.
	if part != null and part.part_type == part.PART_TYPE.THRUSTER:
		max_health = part.max_health
		health = max_health
		thrust_force = part.thrust_force
		part_detached.connect(stop_particles)
	

func stop_particles() -> void:
	thruster_particles.emitting = false
	thruster_light.enabled = false

# Test function
func test_damage():
	take_damage(190)
