## Intro.gd
## Controls the multi-part cinematic opening monologue before gameplay starts.
## Builds a full-screen dark UI layout, plays a character-by-character typewriter
## animation across two narrative sections separated by a fade transition,
## supports click/key skipping, and transitions into the main gameplay scene.
extends Control

# --- Timing & Animation Configuration ---
var text_speed: float = 0.04        # Seconds per character typed
var fade_duration: float = 1.2     # Duration of screen fade-in/out transitions
var transition_pause: float = 1.5  # Pause duration after text finishes typing

# --- Narrative Monologue Content ---
var intro_beginning_text: String = """I was born through ectogenesis.

My parents were a calculated genetic match. I know their registry IDs, but we have never met. Raising a child is a crime against efficiency in my country.

The building AI analyzed my DNA while I was still in the pod. It predicted my intelligence, my stress thresholds, and my ideal utility. It decided my entire life before I ever opened my eyes.

Schooled by algorithms. Assigned to Floor 42. Engineered to work, eat, and sleep in silence.

I have only ever seen the outside through media and observation glass.

I have never been outside."""

var intro_finishing_text: String = """I don't talk to many people. The elderly are sometimes talkative, but people my age pass by each other wordlessly. We rarely interact with our own kind.

Lately, I discovered an obsolete concept—a concept through which my great grandparents once conceived my parents.

Through 'love'."""

# --- UI Nodes & Playback State ---
var background: ColorRect
var text_label: Label
var fade_overlay: ColorRect
var is_typing: bool = false


## Initializes the full-screen layout, constructs visual nodes, and starts playback.
func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	
	_setup_visuals()
	_start_intro_sequence()


# ==============================================================================
# UI SETUP
# ==============================================================================

## Creates the midnight-blue background, padded text container, styled label,
## and top-level black fade overlay.
func _setup_visuals() -> void:
	# Full-screen dark midnight-blue backdrop
	background = ColorRect.new()
	background.set_anchors_preset(PRESET_FULL_RECT)
	background.color = Color("#050811")
	add_child(background)

	# Margin container to keep monologue text centered and readable
	var margin_container := MarginContainer.new()
	margin_container.set_anchors_preset(PRESET_FULL_RECT)
	margin_container.add_theme_constant_override("margin_left", 120)
	margin_container.add_theme_constant_override("margin_right", 120)
	margin_container.add_theme_constant_override("margin_top", 100)
	margin_container.add_theme_constant_override("margin_bottom", 100)
	add_child(margin_container)

	# Monologue display label
	text_label = Label.new()
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.add_theme_color_override("font_color", Color("#219a9fff"))
	text_label.add_theme_font_size_override("font_size", 32)
	
	var font_path := "res://assets/fonts/80s-retro-future.ttf"
	if ResourceLoader.exists(font_path):
		text_label.add_theme_font_override("font", load(font_path))
		
	margin_container.add_child(text_label)

	# Full-screen black overlay placed last so it renders on top for fades
	fade_overlay = ColorRect.new()
	fade_overlay.set_anchors_preset(PRESET_FULL_RECT)
	fade_overlay.color = Color(0, 0, 0, 1) # Start completely opaque
	add_child(fade_overlay)


# ==============================================================================
# SEQUENCE & TYPEWRITER ANIMATION
# ==============================================================================

## Orchestrates the two-part intro flow: initial fade-in, part one typing,
## mid-sequence fade reset, part two typing, and transition to gameplay.
func _start_intro_sequence() -> void:
	# 1. Fade in from black
	var tween := create_tween()
	tween.tween_property(fade_overlay, "color:a", 0.0, fade_duration)
	await tween.finished
	
	# 2. Type out the first section and hold briefly
	await _type_text_section(intro_beginning_text)
	await get_tree().create_timer(transition_pause).timeout
	
	# 3. Fade out to black, clear text, and fade back in for section two
	var fade_out := create_tween()
	fade_out.tween_property(fade_overlay, "color:a", 1.0, fade_duration)
	await fade_out.finished
	
	text_label.text = ""
	
	var fade_in := create_tween()
	fade_in.tween_property(fade_overlay, "color:a", 0.0, fade_duration)
	await fade_in.finished
	
	# 4. Type out the second section, hold, and proceed to gameplay
	await _type_text_section(intro_finishing_text)
	await get_tree().create_timer(2.0).timeout
	
	_transition_to_gameplay()


## Types out the provided string character-by-character with extra pauses
## on sentence-ending punctuation. Can be interrupted by setting is_typing = false.
func _type_text_section(target_text: String) -> void:
	text_label.text = ""
	is_typing = true
	
	for i in range(target_text.length()):
		if not is_typing:
			break
		text_label.text += target_text[i]
		
		# Add a dramatic beat after sentence-ending punctuation
		if target_text[i] in [".", "!", "?"]:
			await get_tree().create_timer(0.35).timeout
		else:
			await get_tree().create_timer(text_speed).timeout
	
	# Ensure full text is displayed if the loop was skipped early
	text_label.text = target_text
	is_typing = false


# ==============================================================================
# INPUT HANDLING & SCENE TRANSITION
# ==============================================================================

## Allows the player to press Accept (Space/Enter) or click the mouse to either
## auto-complete the current typing block or skip directly to the main game.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		if is_typing:
			is_typing = false # Finish typing the current block immediately
		else:
			_transition_to_gameplay()


## Disables further input, fades the screen to black, and loads Main.tscn.
func _transition_to_gameplay() -> void:
	set_process_input(false)
	var tween := create_tween()
	tween.tween_property(fade_overlay, "color:a", 1.0, fade_duration)
	await tween.finished
	
	var main_scene_path := "res://scenes/gameplay/Main.tscn"
	if ResourceLoader.exists(main_scene_path):
		get_tree().change_scene_to_file(main_scene_path)
	else:
		push_warning("Main gameplay scene not found at: " + main_scene_path)
