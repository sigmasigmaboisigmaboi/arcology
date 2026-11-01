extends Control

# Signals to notify the game manager when animations complete
signal transition_finished

# Configuration
var fade_duration: float = 1.0
var display_duration: float = 1.5

# Nodes
var background: ColorRect
var day_label: Label
var subtitle_label: Label
var fade_overlay: ColorRect

func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	_setup_ui()

func _setup_ui() -> void:
	# Pitch-black background
	background = ColorRect.new()
	background.set_anchors_preset(PRESET_FULL_RECT)
	background.color = Color("#05070a")
	add_child(background)

	# Container for centered text
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(PRESET_CENTER)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 10)
	add_child(vbox)

	# Day Counter Label (e.g., "DAY 01 / 14")
	day_label = Label.new()
	day_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	day_label.add_theme_color_override("font_color", Color("#00f0ff")) # Cyan accent
	day_label.add_theme_font_size_override("font_size", 48)
	
	# Subtitle / Status Label (e.g., "LOCATION: FLOOR 82 - RESIDENTIAL POD")
	subtitle_label = Label.new()
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_color_override("font_color", Color("#8a99ad"))
	subtitle_label.add_theme_font_size_override("font_size", 16)

	# Load retro pixel font if available
	var font_path = "res://assets/fonts/Micro5Charted-Regular.ttf"
	if ResourceLoader.exists(font_path):
		var custom_font = load(font_path)
		day_label.add_theme_font_override("font", custom_font)
		subtitle_label.add_theme_font_override("font", custom_font)

	vbox.add_child(day_label)
	vbox.add_child(subtitle_label)

	# Black Overlay for smooth fading
	fade_overlay = ColorRect.new()
	fade_overlay.set_anchors_preset(PRESET_FULL_RECT)
	fade_overlay.color = Color(0, 0, 0, 1) # Fully opaque black initially
	add_child(fade_overlay)

# --- REUSABLE FUNCTION: Call this to play the Day Transition ---
func play_day_transition(day_number: int, location_name: String = "FLOOR 82 — RESIDENTIAL POD") -> void:
	# Format single digits as 01, 02, etc.
	day_label.text = "DAY " + str(day_number).pad_zeros(2) + " / 14"
	subtitle_label.text = "SYS_LOC: " + location_name
	
	# 1. Fade in from black to reveal Day text
	var tween_in = create_tween()
	tween_in.tween_property(fade_overlay, "color:a", 0.0, fade_duration)
	await tween_in.finished

	# 2. Hold text on screen for player to read
	await get_tree().create_timer(display_duration).timeout

	# 3. Fade out to black before switching to gameplay
	var tween_out = create_tween()
	tween_out.tween_property(fade_overlay, "color:a", 1.0, fade_duration)
	await tween_out.finished

	# Emit signal so the parent game script knows it's ready to load the day
	transition_finished.emit()
