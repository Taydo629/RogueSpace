class_name MainUILayer extends CanvasLayer

@onready var ui_state_machine: StateMachine = $UIStateMachine
@onready var start_menu_ui: StartMenu = $StartMenuUI
@onready var player_ui: PlayerUI = $PlayerUI
@onready var pause_menu_ui: PauseMenu = $PauseMenuUI
@onready var ship_building_ui: BuildUI = $ShipBuildingUI
@onready var map_ui: MapUI = $MapUI
@onready var guide_ui: GuideUI = $GuideUI
@onready var merchant_ui: MerchantUI = $MerchantUI
@onready var sector_info: SectorInfoUI = $SectorInfo
@onready var death_ui: DeathMenu = $DeathScreen
@onready var dialog_ui: DialogUI = $DialogUI

var player: Player
var level_gen: LevelGenComponent
var main_game: Node2D

#signal travel_to_new_sector
signal travel_to_new_quadrant(Quadrant)
signal restart

func init_ui() -> void:
	var states: Array[State] = [StartUIState.new(self),
								PauseUIState.new(self),
								BuildUIState.new(self),
								PlayerUIState.new(self),
								MapUIState.new(self),
								MerchantUIState.new(self),
								GuideUIState.new(self),
								SectorInfoUIState.new(self),
								DeathUIState.new(self),
								DialogUIState.new(self)]
	ui_state_machine.start_machine(states)

func jump_to_next_sector() -> void:
	pass

func travel_to_next_quadrant(quadrant: Quadrant) -> void:
	#generate_level.emit()
	travel_to_new_quadrant.emit(quadrant)

func restart_game() -> void:
	restart.emit()
