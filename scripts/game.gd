extends Node2D

@onready var countdown_label = $CanvasLayer/CountdownLabel
@onready var player1 = $Player  
@onready var player2 = $Player2  
@onready var _321: AudioStreamPlayer2D = $"321"


var game_started = false

func _ready():
	var map_scene
	if Global.selected_map == 1:
		map_scene = load("res://scenes/game_map_1.tscn")
		
	else:
		map_scene = load("res://scenes/game_map_2.tscn")
	

	var map_instance = map_scene.instantiate()
	add_child(map_instance)
	move_child(map_instance, 0) 
	
	start_countdown()

func start_countdown():

	freeze_players(true)
	 
	#    countdown
	_321.play()
	await get_tree().create_timer(0.5).timeout
	countdown_label.text = "3"
	countdown_label.visible = true
	await get_tree().create_timer(1.0).timeout
	
	countdown_label.text = "2"
	countdown_label.add_theme_color_override("font_color", Color(255,255, 0))
	await get_tree().create_timer(1.0).timeout
	
	countdown_label.text = "1"
	countdown_label.add_theme_color_override("font_color", Color(0,204,255))
	await get_tree().create_timer(1.0).timeout
	
	countdown_label.text = "GO!"
	countdown_label.add_theme_color_override("font_color", Color(244.585, 0.0, 0.0, 1.0))
	await get_tree().create_timer(0.5).timeout
	
	# label weg doen en de game starten en de players unfrezen
	countdown_label.visible = false
	game_started = true
	freeze_players(false)

func freeze_players(freeze: bool):
	if player1:
		player1.set_physics_process(not freeze)
		player1.set_process_input(not freeze)
		player1.can_move = not freeze
	if player2:
		player2.set_physics_process(not freeze)
		player2.set_process_input(not freeze)
		player2.can_move = not freeze
