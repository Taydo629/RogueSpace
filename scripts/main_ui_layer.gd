extends CanvasLayer

@onready var ui_state_machine: StateMachine = $UIStateMachine

func _ready() -> void:
	var states: Array[State] = []
	ui_state_machine.start_machine(states)
