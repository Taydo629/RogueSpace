class_name MainUILayer extends CanvasLayer

@onready var ui_state_machine: StateMachine = $UIStateMachine
@onready var start_menu_ui: StartMenu = $StartMenuUI
@onready var player_ui: PlayerUI = $PlayerUI
@onready var pause_menu_ui: PauseMenu = $PauseMenuUI
@onready var ship_building_ui: BuildUI = $ShipBuildingUI
@onready var guide_ui: GuideUI = $GuideUI

var player: Player
var level_gen: LevelGenComponent

func init_ui() -> void:
	var states: Array[State] = [StartUIState.new(self),
								PauseUIState.new(self),
								BuildUIState.new(self),
								PlayerUIState.new(self),
								StationUIState.new(self),
								GuideUIState.new(self)]
	ui_state_machine.start_machine(states)
