class_name Thruster extends BasePart

# Not used but could be used in future for configurable control
var activation_key: String
@onready var thruster_particles: CPUParticles2D = $ThrusterParticles
@onready var thruster_light: PointLight2D = $ThrusterParticles/ThrusterLight
@onready var thruster_sound: AudioStreamPlayer2D = $ThrusterSound

var thrust_force: int
var part:Part:
	set(value):
		max_health = value.max_health
		health = max_health
		thrust_force = value.thrust_force
		part = value

func _ready() -> void:
	part_detached.connect(stop_particles)

func stop_particles() -> void:
	thruster_particles.emitting = false
	thruster_light.enabled = false

# Test function
func test_damage():
	take_damage(190)
