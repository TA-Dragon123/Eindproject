extends Node2D

@onready var auto_scroller: Node2D = $AutoScroller
@onready var button_container: VBoxContainer = $ScreenManager/ButtonContainer
@onready var game_options_screen: Panel = $ScreenManager/GameOptionsScreen
@onready var map_1b: Button = $ScreenManager/GameOptionsScreen/Panel/HBoxContainer/map1b
@onready var map_2b: Button = $ScreenManager/GameOptionsScreen/Panel/HBoxContainer/map2b

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
	var stlyle_ne = StyleBoxFlat.new()
	var stlyle_gr = StyleBoxFlat.new()
	stlyle_gr.bg_color = Color(0.0,0.6,0.065)
	stlyle_ne.bg_color = Color(0.102, 0.102, 0.102, 0.6)
	map_1b.add_theme_stylebox_override("normal",stlyle_gr)
	map_1b.add_theme_stylebox_override("hover",stlyle_gr)
	map_2b.remove_theme_stylebox_override("normal")
	map_2b.remove_theme_stylebox_override("hover")
func _on_map_2b_pressed() -> void:
	Global.selected_map = 2  # Sla keuze op
	print("Map 2 selected")
	var stlyle_ne = StyleBoxFlat.new()
	var stlyle_gr = StyleBoxFlat.new()
	stlyle_gr.bg_color = Color(0.0,0.6,0.065)
	stlyle_ne.bg_color = Color(0.102, 0.102, 0.102, 0.6)
	map_2b.add_theme_stylebox_override("normal",stlyle_gr)
	map_2b.add_theme_stylebox_override("hover",stlyle_gr)
	map_1b.remove_theme_stylebox_override("normal")
	map_1b.remove_theme_stylebox_override("hover")
