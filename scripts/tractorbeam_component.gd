class_name TractorbeamComponent extends Node

var tractorbeams : Array[TractorBeam]
var parent: RigidBody2D

func _ready() -> void:
	parent = get_parent()

func initalise_tractor_beams(ship_graph: Dictionary) -> void:
	tractorbeams = []
	for node in ship_graph.values():
		if node.instance.is_in_group("tractor_beam"):
			tractorbeams.append(node.instance)

func activate() -> void:
	for tractorbeam in tractorbeams:
		tractorbeam.beam_active = true

func deactivate() -> void:
	for tractorbeam in tractorbeams:
		tractorbeam.beam_active = false
