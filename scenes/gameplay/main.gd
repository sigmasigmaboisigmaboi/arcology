extends Control

var current_day: int = 1
var day_transition_scene = preload("res://scenes/transitions/DayTransition.tscn")

func _ready() -> void:
	_start_next_day()

func _start_next_day() -> void:
	# Instance the transition screen overlay
	var transition_instance = day_transition_scene.instantiate()
	add_child(transition_instance)
	
	# Trigger the day text sequence
	transition_instance.play_day_transition(current_day, "FLOOR 82 — RESIDENTIAL POD")
	
	# Wait for the transition fade out to complete
	await transition_instance.transition_finished
	
	# Remove transition screen and load actual day's gameplay UI
	transition_instance.queue_free()
	_load_day_gameplay_ui()

func _load_day_gameplay_ui() -> void:
	print("Loading daily routine for Day ", current_day)
	# Setup your apartment UI, daily metrics, or dialogue choices here
