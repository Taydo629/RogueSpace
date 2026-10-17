class_name StateMachine extends Node

@onready var transition_rect: ColorRect = $"../TransitionRect"

@export var is_log_enabled: bool = false
@export var UI_transition_time: float = 0.5

var is_running: bool = false

var current_state: State
var previous_state: State
var states: Dictionary = {}
var _parent_node_name: String
var _transition_tween: Tween

# Start this state machine
func start_machine(init_states: Array[State]) -> void:
	_parent_node_name = get_parent().name
	_transition_tween = create_tween()
	for state in init_states:
		states[state.get_state_name()] = state

	current_state = init_states[0]
	
	if is_log_enabled:
		print("[%s]: Entering state \"%s\"" % [_parent_node_name, current_state.get_state_name()])
	
	current_state.enter()
	_transition_animation(true)
	is_running = true
	
	
func _input(_event: InputEvent) -> void:
	#current_state.input(event)
	pass
	
	
func _process(delta: float) -> void:
	current_state.process(delta)
	
	
func _physics_process(delta: float) -> void:
	current_state.physics_process(delta)
	

# Attempt a transition to the new state.
# @param new_state The name of the new state to transition to.
func transition(new_state_name: String) -> void:
	var new_state: State = states.get(new_state_name)
	var current_state_name = current_state.get_state_name()

	if new_state == null:
		push_error("An attempt has been made to transition to a non-existent state (%s)." % new_state_name)
	elif new_state != current_state:
		
		if is_log_enabled:
			print("[%s]: Exiting state \"%s\"" % [_parent_node_name, current_state_name])
		await _transition_animation(false).finished
		current_state.exit()
		previous_state = current_state
		current_state = states[new_state.get_state_name()]
		
		if is_log_enabled:
			print("[%s]: Entering state \"%s\"" % [_parent_node_name, current_state.get_state_name()])
		
		current_state.enter()
		await _transition_animation(true).finished
	else:
		push_warning("An attempt to transition to the current state has been made. Ignoring request.")

func _transition_animation(start: bool) -> Tween:
	var target: float = 1.0
	if start:
		transition_rect.set_instance_shader_parameter("dissolve_progress", 1.0)
		target = 0.0
	if _transition_tween and _transition_tween.is_valid():
		_transition_tween.kill()
	_transition_tween = create_tween()
	_transition_tween.tween_property(transition_rect, "instance_shader_parameters/dissolve_progress", target, UI_transition_time)
	return _transition_tween
