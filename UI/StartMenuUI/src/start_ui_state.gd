class_name StartUIState extends UIState

static var state_name = "StartUIState"
var main_menu_ui: StartMenu

func get_state_name() -> String:
	return state_name

func enter() -> void:
	state_machine.get_tree().paused = true
	main_menu_ui = canvas_layer.start_menu_ui
	main_menu_ui.visible = true
	main_menu_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	if not main_menu_ui.start.is_connected(start_game):
		main_menu_ui.start.connect(start_game)
	if not main_menu_ui.guide.is_connected(guide):
		main_menu_ui.guide.connect(guide)
	main_menu_ui.init_ui()

func exit() -> void:
	main_menu_ui.visible = false
	main_menu_ui.process_mode = Node.PROCESS_MODE_DISABLED

func start_game() -> void:
	state_machine.transition(ShipyardUIState.state_name)

func guide() -> void:
	state_machine.transition(GuideUIState.state_name)
