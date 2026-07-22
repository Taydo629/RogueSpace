class_name GunComponent extends Node

@export var ship : RigidBody2D
@export var bullet : PackedScene
@export var fire_rate : float = 0.15

var guns : Array
var muzzle_offset: Vector2 = Vector2(0,-32)
var gun_ready: bool = true
var timer: Timer

func _ready() -> void:
	var temp_guns = get_tree().get_nodes_in_group("gun")
	for i in temp_guns:
		if i.get_parent() == get_parent():
			guns.append(i)
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.wait_time = fire_rate

func update_guns() -> void:
	var temp_guns = get_tree().get_nodes_in_group("gun")
	for i in temp_guns:
		if i.get_parent() == get_parent():
			guns.append(i)

func fire() -> void:
	if gun_ready:
		for node in guns:
			if node != null:
				if not node is Node2D:
					continue
				var gun_direction = Vector2.UP.rotated(node.rotation)
				var new_bullet:StaticBody2D = bullet.instantiate()
				if node.scale == Vector2(-1,1):
					new_bullet.global_position = (node.global_position + (-1 * muzzle_offset).rotated(node.global_rotation))
				else:
					new_bullet.global_position = (node.global_position + muzzle_offset.rotated(node.global_rotation))
				new_bullet.rotation = ship.rotation + node.rotation
				add_child(new_bullet)
				timer.start()
				gun_ready = false

func _on_timer_timeout() -> void:
	# Cooldown ended gun is ready again
	gun_ready = true
