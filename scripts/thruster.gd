class_name Thruster extends BasePart

var activation_key: String
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D

@export var thrust_force: int = 1
@export var part_health: int = 100

func _ready() -> void:
	max_health = part_health
	health = max_health
	part_detached.connect(stop_particles)

func stop_particles() -> void:
	cpu_particles_2d.emitting = false

# Test function
func test_damage():
	take_damage(190)
