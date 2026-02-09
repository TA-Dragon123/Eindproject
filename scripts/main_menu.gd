extends Node2D

@onready var auto_scroller: Node2D = $AutoScroller
@onready var button_container: VBoxContainer = $ScreenManager/ButtonContainer
@onready var game_options_screen: Panel = $ScreenManager/GameOptionsScreen

func _ready():
	button_container.visible = true
	game_options_screen.visible = false

func _on_start_pressed() -> void:
	auto_scroller.visible = false
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_game_options_pressed() -> void:
	button_container.visible = false
	game_options_screen.visible = true

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_back_pressed() -> void:
	button_container.visible = true
	game_options_screen.visible = false

func _on_map_1b_pressed() -> void:
	Global.selected_map = 1  # Sla keuze op
	print("Map 1 selected")

func _on_map_2b_pressed() -> void:
	Global.selected_map = 2  # Sla keuze op
	print("Map 2 selected")
