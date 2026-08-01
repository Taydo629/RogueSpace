extends BasePart

@export var beam_strength: int = 500
@export var part_health: int = 100

var beam_active: bool = false
var parts_in_beam: Array = []

@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var beam_area: Area2D = $Beam_area

func _ready() -> void:
	max_health = part_health
	health = max_health
	part_detached.connect(stop_particles)

func stop_particles() -> void:
	cpu_particles_2d.emitting = false

func _physics_process(delta: float) -> void:
	if beam_active:
		cpu_particles_2d.emitting = true
		if beam_area.has_overlapping_bodies():
			var nodes_in_beam = beam_area.get_overlapping_bodies()
			for node in nodes_in_beam:
				if node.has_method("take_damage") and beam_active:
					var vector = global_position - node.global_position
					node.constant_force = vector.normalized()*beam_strength
	else:
		cpu_particles_2d.emitting = false

func _collect_part(body: Node2D) -> void:
	if body.has_method("take_damage") and beam_active:
		if get_parent().is_in_group("player_ship"):
			Inventory.add_item(body.part)
			body.take_damage(100000)
	pass # Replace with function body.
