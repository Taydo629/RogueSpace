extends Node2D

@export var thrust_force: int = 1
var thrust_direction: Vector2 = Vector2.UP
var activation_key: String
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
