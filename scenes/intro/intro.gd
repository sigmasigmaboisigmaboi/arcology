extends Control

# Configuration
var text_speed: float = 0.04 # Seconds per character typed
var fade_duration: float = 1.2 # Duration of screen fade-in/out
var transition_pause: float = 1.5 # Pause duration between text sections

# Text Content
var intro_beginning_text: String = """I was born through ectogenesis.

My parents were a calculated genetic match. I know their registry IDs, but we have never met. Raising a child is a crime against efficiency in my country.

The building AI analyzed my DNA while I was still in the pod. It predicted my intelligence, my stress thresholds, and my ideal utility. It decided my entire life before I ever opened my eyes.

Schooled by algorithms. Assigned to Floor 42. Engineered to work, eat, and sleep in silence.

I have only ever seen the outside through media and observation glass.

I have never been outside."""

var intro_finishing_text: String = """I don't talk to many people. The elderly are sometimes talkative, but people my age pass by each other wordlessly. We rarely interact with our own kind.

Lately, I discovered an obsolete concept—a concept through which my great grandparents once conceived my parents.

Through 'love'."""

# Nodes
var background: ColorRect
var text_label: Label
var fade_overlay: ColorRect
var is_typing: bool = false
var current_text_part: String = ""

func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	
	_setup_visuals()
	_start_intro_sequence()

# --- STEP 1: UI Setup ---
func _setup_visuals() -> void:
	# Dark blue almost black background
	background = ColorRect.new()
	background.set_anchors_preset(PRESET_FULL_RECT)
	background.color = Color("#050811") # Dark midnight blue
	add_child(background)

	# Container for text with proper margins
	var margin_container = MarginContainer.new()
	margin_container.set_anchors_preset(PRESET_FULL_RECT)
	margin_container.add_theme_constant_override("margin_left", 120)
	margin_container.add_theme_constant_override("margin_right", 120)
	margin_container.add_theme_constant_override("margin_top", 100)
	margin_container.add_theme_constant_override("margin_bottom", 100)
	add_child(margin_container)

	# Text Label
	text_label = Label.new()
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.add_theme_color_override("font_color", Color("#219a9fff"))
	text_label.add_theme_font_size_override("font_size", 32)
	
	# Apply font if loaded in your project
	var font_path = "res://assets/fonts/Micro5Charted-Regular.ttf"
	if ResourceLoader.exists(font_path):
		text_label.add_theme_font_override("font", load(font_path))
		
	margin_container.add_child(text_label)

	# Black overlay for smooth Fade-In / Fade-Out transitions
	fade_overlay = ColorRect.new()
	fade_overlay.set_anchors_preset(PRESET_FULL_RECT)
	fade_overlay.color = Color(0, 0, 0, 1) # Start fully black
	add_child(fade_overlay)

# --- STEP 2: Multi-Part Intro Sequence ---
func _start_intro_sequence() -> void:
	# Initial Fade-In from black
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color:a", 0.0, fade_duration)
	await tween.finished
	
	# Play Section 1
	await _type_text_section(intro_beginning_text)
	await get_tree().create_timer(transition_pause).timeout
	
	# Transition: Fade screen to black, clear text, fade back in
	var fade_out = create_tween()
	fade_out.tween_property(fade_overlay, "color:a", 1.0, fade_duration)
	await fade_out.finished
	
	text_label.text = "" # Clear first paragraph
	
	var fade_in = create_tween()
	fade_in.tween_property(fade_overlay, "color:a", 0.0, fade_duration)
	await fade_in.finished
	
	# Play Section 2
	await _type_text_section(intro_finishing_text)
	await get_tree().create_timer(2.0).timeout
	
	_transition_to_gameplay()

# --- STEP 3: Reusable Typewriter Logic ---
func _type_text_section(target_text: String) -> void:
	text_label.text = ""
	current_text_part = target_text
	is_typing = true
	
	for i in range(target_text.length()):
		if not is_typing:
			break
		text_label.text += target_text[i]
		
		# Short pause on punctuation for cinematic cadence
		if target_text[i] in [".", "!", "?"]:
			await get_tree().create_timer(0.35).timeout
		else:
			await get_tree().create_timer(text_speed).timeout
	
	text_label.text = target_text
	is_typing = false

# --- STEP 4: Skip & Transition Logic ---
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		if is_typing:
			# Skip typewriter for current section only
			is_typing = false
		else:
			# Skip directly to gameplay if clicked during pauses
			_transition_to_gameplay()

func _transition_to_gameplay() -> void:
	set_process_input(false)
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color:a", 1.0, fade_duration)
	await tween.finished
	
	if ResourceLoader.exists("res://scenes/gameplay/Main.tscn"):
		get_tree().change_scene_to_file("res://scenes/gameplay/Main.tscn")
	else:
		print("Main.tscn not found.")
		
		
