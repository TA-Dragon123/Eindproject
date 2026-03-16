extends Node2D

@onready var countdown_label = $CanvasLayer/CountdownLabel
@onready var player1 = $Player  
@onready var player2 = $Player2  
@onready var _321: AudioStreamPlayer2D = $"321"


@onready var card_select_layer = $CardSelectLayer
@onready var card_select_ui = $CardSelectLayer/CardSelectUI
@onready var card1_button = $CardSelectLayer/CardSelectUI/CardsContainer/Card1
@onready var card2_button = $CardSelectLayer/CardSelectUI/CardsContainer/Card2
@onready var card3_button = $CardSelectLayer/CardSelectUI/CardsContainer/Card3

var current_cards = []
var winner_player = null
var game_started = false

var player1_wins = 0
var player2_wins = 0
const WINS_TO_WIN = 5

func _ready():
	print("=== CHECKING CARD NODES ===")
	print("CardSelectLayer exists: ", has_node("CardSelectLayer"))
	print("Card1 exists: ", has_node("CardSelectLayer/CardSelectUI/CardsContainer/Card1"))
	
	var map_scene
	if Global.selected_map == 1:
		map_scene = load("res://scenes/game_map_1.tscn")
	else:
		map_scene = load("res://scenes/game_map_2.tscn")
	
	var map_instance = map_scene.instantiate()
	add_child(map_instance)
	move_child(map_instance, 0)
	

	# Check of nodes bestaan voordat je ze gebruikt
	if has_node("CardSelectLayer"):
		card_select_layer.visible = false
		card_select_layer.process_mode = Node.PROCESS_MODE_ALWAYS
		card1_button.pressed.connect(_on_card_selected.bind(0))
		card2_button.pressed.connect(_on_card_selected.bind(1))
		card3_button.pressed.connect(_on_card_selected.bind(2))
		print("Card system initialized!")
	else:
		print("ERROR: CardSelectLayer not found!")
	
	start_countdown()

func start_countdown():
	freeze_players(true)
	 
	# Countdown
	_321.play()
	await get_tree().create_timer(0.5).timeout
	countdown_label.text = "3"
	countdown_label.visible = true
	await get_tree().create_timer(1.0).timeout
	
	countdown_label.text = "2"
	countdown_label.add_theme_color_override("font_color", Color(1, 1, 0))
	await get_tree().create_timer(1.0).timeout
	
	countdown_label.text = "1"
	countdown_label.add_theme_color_override("font_color", Color(0, 0.8, 1))
	await get_tree().create_timer(1.0).timeout
	
	countdown_label.text = "GO!"
	countdown_label.add_theme_color_override("font_color", Color(1, 0, 0))
	await get_tree().create_timer(0.5).timeout
	
	# Label weg doen en de game starten en de players unfrezen
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

func round_ended(loser_player):
	print("=== ROUND ENDED ===")
	print("Loser: ", loser_player.name)
	
	# Bepaal winnaar en update win counter
	var winner = null
	if loser_player == player1:
		winner = player2
		player2_wins += 1
		print("Player 2 wins this round! Total wins: ", player2_wins)
	else:
		winner = player1
		player1_wins += 1
		print("Player 1 wins this round! Total wins: ", player1_wins)
	
	# Check of iemand de game heeft gewonnen
	if player1_wins >= WINS_TO_WIN:
		game_over(player1)
		return
	elif player2_wins >= WINS_TO_WIN:
		game_over(player2)
		return
	
	# Anders: card selection
	await get_tree().create_timer(1.0).timeout
	show_card_selection(loser_player)
func game_over(winner):
	print("=== GAME OVER ===")
	print("Winner: ", winner.name)
	
	# Toon win screen
	countdown_label.text = winner.name + " WINS!"
	countdown_label.add_theme_color_override("font_color", Color(1, 0.8, 0))  # Goud
	countdown_label.visible = true
	
	# Wacht 3 seconden
	await get_tree().create_timer(3.0).timeout
	
	# Ga terug naar main menu
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func show_card_selection(loser_player):
	winner_player = loser_player
	
	# Freeze het spel
	get_tree().paused = true
	
	# Krijg 3 random kaarten
	current_cards = Cards.get_random_cards(3)
	
	# Update button tekst
	card1_button.text = current_cards[0]["name"]
	card2_button.text = current_cards[1]["name"]
	card3_button.text = current_cards[2]["name"]
	
	# Load en set icons
	if current_cards[0].has("icon") and current_cards[0]["icon"] != "":
		card1_button.icon = load(current_cards[0]["icon"])
	if current_cards[1].has("icon") and current_cards[1]["icon"] != "":
		card2_button.icon = load(current_cards[1]["icon"])
	if current_cards[2].has("icon") and current_cards[2]["icon"] != "":
		card3_button.icon = load(current_cards[2]["icon"])
	
	# Toon de UI
	card_select_layer.visible = true

func _on_card_selected(card_index: int):
	var selected_card = current_cards[card_index]
	print("Selected: ", selected_card["name"])
	
	# Pas buff toe op winnaar
	apply_buff(winner_player, selected_card)
	
	# Hide UI
	card_select_layer.visible = false
	
	# Unpause game
	get_tree().paused = false
	
	# Reset voor volgende ronde
	reset_round()

func apply_buff(player, card):
	match card["effect"]:
		"speed":
			player.SPEED += 50
			print("Speed increased!")
		"jump":
			player.JUMP_VELOCITY -= 100
			print("Jump boosted!")
		"damage":
			player.Player_DMG += 5
			player.Player_DMG_muliplyer += 1
			print("Damage up!")
		"shield":
			#player.has_shield = true
			print("Shield activated!")
		"lifesteal":
			player.has_lifesteal = true
			print("Lifesteal activated!")

func reset_round():
	# Reset HP
	player1.player_hp = 0
	player2.player_hp = 0
	
	# lives Reset
	player1.player_lives = 3
	player2.player_lives = 3
	
	# Update UI
	player1.update_percentage_ui()
	player2.update_percentage_ui()
	
	# Respawn
	player1.respawn()
	player2.respawn()
	
