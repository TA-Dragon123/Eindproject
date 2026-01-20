extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

@onready var auto_scroller: Node2D = $AutoScroller

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	auto_scroller.visible = false
	get_tree().change_scene_to_file("res://scenes/game.tscn")
