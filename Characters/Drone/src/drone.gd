class_name Drone extends RigidBody2D

@onready var detection_area: Area2D = $DetectionArea
@onready var drone_movement_component: DroneMovementComponent = $DroneMovementComponent
@onready var drone_input_component: DroneInputComponent = $DroneInputComponent
@onready var collision_shape_2d: CollisionShape2D = $DetectionArea/CollisionShape2D

@export var detection_range: int = 1500

func _ready() -> void:
	collision_shape_2d.shape.radius = detection_range
	drone_input_component.detection_area = detection_area
