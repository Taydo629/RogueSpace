class_name TractorbeamComponent extends Node

@export var fire_rate : float = 0.15

var tractorbeams : Array
var tractorbeam_ready: bool = true
var timer: Timer

func _ready() -> void:
	var temp_guns = get_tree().get_nodes_in_group("tractor_beam")
	for i in temp_guns:
		if i.get_parent() == get_parent():
			tractorbeams.append(i)
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.wait_time = fire_rate

func update_tractorbeam() -> void:
	var temp_guns = get_tree().get_nodes_in_group("tractor_beam")
	for i in temp_guns:
		if i.get_parent() == get_parent():
			tractorbeams.append(i)

func activate_tractorbeam() -> void:
	if tractorbeam_ready:
		for node in tractorbeams:
			if node != null:
				if not node is Node2D:
					continue
				# Tractor beam function here
				node.beam_active = true
				timer.start()
				tractorbeam_ready = false

func deactivate_tractorbeam() -> void:
	for node in tractorbeams:
		if node != null:
			if not node is Node2D:
				continue
			# Tractor beam function here
			node.beam_active = false

func _on_timer_timeout() -> void:
	# Cooldown ended gun is ready again
	tractorbeam_ready = true
