extends Node2D




@onready var auto_scroller: Node2D = $AutoScroller
@onready var button_container: VBoxContainer = $ScreenManager/ButtonContainer
@onready var game_options_screen: Panel = $ScreenManager/GameOptionsScreen


func _process(delta: float) -> void:
	pass
	
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
	pass # Replace with function body.


func _on_map_2b_pressed() -> void:
	pass # Replace with function body.
