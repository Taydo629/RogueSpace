class_name TractorBeam extends BasePart

@export var beam_strength: int = 500

var beam_active: bool = false
var parts_in_beam: Array = []

@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var beam_area: Area2D = $Beam_area

var part:Part:
	set(value):
		sprite = value.image
		max_health = value.max_health
		health = value.current_health
		part = value

func _ready() -> void:
	if sprite != null:
		polygon_2d.set_texture(sprite)
		polygon_2d.texture_offset = Vector2(32,32)
	part_detached.connect(stop_particles)

func stop_particles() -> void:
	cpu_particles_2d.emitting = false

func _physics_process(_delta: float) -> void:
	if beam_active:
		cpu_particles_2d.emitting = true
		# Check if beam overlaps any bodies
		if beam_area.has_overlapping_bodies():
			var nodes_in_beam = beam_area.get_overlapping_bodies()
			for node in nodes_in_beam:
				# Check if node is actually a rigid body
				if node is RigidBody2D:
					# Check if the body is of type a part or a ship
					if node.has_method("take_damage") or node.is_in_group("player") or node.is_in_group("npc"):
						var vector = global_position - node.global_position
						node.apply_central_force(vector.normalized()*beam_strength)
	else:
		cpu_particles_2d.emitting = false

func _collect_part(body: Node2D) -> void:
	if body.has_method("take_damage") and beam_active:
		if parent.is_in_group("player"):
			var part_to_add: Part = body.part
			part_to_add.current_health = body.health
			Inventory.add_item(body.part)
			body.take_damage(100000)
	pass # Replace with function body.
