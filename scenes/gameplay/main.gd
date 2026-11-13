## Main.gd
## Master controller for the 14-day Arcology gameplay loop.
## Manages day progression, instantiates reusable day transition overlays,
## and initializes each day's active gameplay environment.
extends Control

# --- Game State ---
var current_day: int = 1

# --- Preloaded Scenes ---
var day_transition_scene: PackedScene = preload("res://scenes/transitions/DayTransition.tscn")


## Begins the initial day cycle as soon as the gameplay scene enters the scene tree.
func _ready() -> void:
	_start_next_day()


# ==============================================================================
# DAY CYCLE & SCENE FLOW
# ==============================================================================

## Plays the full-screen day counter overlay for the current day, cleans it up
## once completed, and triggers the loading of the day's gameplay UI.
func _start_next_day() -> void:
	# Instantiate and mount the day transition screen overlay
	var transition_instance := day_transition_scene.instantiate()
	add_child(transition_instance)
	
	# Display the current day counter and starting location
	transition_instance.play_day_transition(current_day, "FLOOR 82 — RESIDENTIAL POD")
	
	# Pause execution until the fade-in, hold, and fade-out sequence completes
	await transition_instance.transition_finished
	
	# Free the transition node from memory before initializing gameplay
	transition_instance.queue_free()
	_load_day_gameplay_ui()


## Initializes the apartment environment, daily metrics, and narrative events
## corresponding to the current day.
func _load_day_gameplay_ui() -> void:
	print("Loading daily routine for Day ", current_day)
	# TODO: Instantiate Floor 82 room scene, HUD metrics, and day-specific dialogue
