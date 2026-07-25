extends Control

@onready var nw: Panel = $NW
@onready var ne: Panel = $NE
@onready var se: Panel = $SE
@onready var sw: Panel = $SW
@onready var s: Panel = $S
@onready var w: Panel = $W
@onready var n: Panel = $N
@onready var e: Panel = $E

func update_indicator(angle_array: Array) -> void:
	for angle in angle_array:
		if angle >= -0.125 * PI and angle < 0.125 * PI:
			n.visible = true
		else:
			n.visible = false
		if angle >= 0.125 * PI and angle < 0.375 * PI:
			ne.visible = true
		else:
			ne.visible = false
		if angle >= 0.375 * PI and angle < 0.625 * PI:
			e.visible = true
		else:
			e.visible = false
		if angle >= 0.625 * PI and angle < 0.875 * PI:
			se.visible = true
		else:
			se.visible = false
		if angle >= 0.875 * PI and angle < -0.875 * PI:
			s.visible = true
		else:
			s.visible = false
		if angle >= -0.875 * PI and angle < -0.625 * PI:
			sw.visible = true
		else:
			sw.visible = false
		if angle >= -0.625 * PI and angle < -0.375 * PI:
			w.visible = true
		else:
			w.visible = false
		if angle >= -0.375 * PI and angle < -0.125 * PI:
			nw.visible = true
		else:
			nw.visible = false
	
