## DayTransition.gd
## Reusable full-screen transition overlay that announces the current day counter
## (e.g., "DAY 01 / 14") and location header between daily gameplay cycles.
## Emits `transition_finished` once the fade-in, hold, and fade-out sequence completes.
extends Control

# --- Signals ---
## Emitted after the transition finishes fading back out to black, signaling
## the parent gameplay controller to free this overlay and load the day's scene.
signal transition_finished

# --- Timing Configuration ---
var fade_duration: float = 1.0     # Seconds for fade-in and fade-out tweens
var display_duration: float = 1.5  # Seconds to hold the day text on screen

# --- UI Nodes ---
var background: ColorRect
var day_label: Label
var subtitle_label: Label
var fade_overlay: ColorRect


## Expands the root control to fill the viewport and constructs all child UI nodes.
func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	_setup_ui()


# ==============================================================================
# UI SETUP
# ==============================================================================

## Builds the dark backdrop, centered text container, custom-styled day and
## location labels, and the top-level fade overlay.
func _setup_ui() -> void:
	# Full-screen dark background
	background = ColorRect.new()
	background.set_anchors_preset(PRESET_FULL_RECT)
	background.color = Color("#05070a")
	add_child(background)

	# Centered vertical container for the day counter and location subtitle
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(PRESET_CENTER)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 10)
	add_child(vbox)

	# Primary Day Counter Label (e.g., "DAY 01 / 14")
	day_label = Label.new()
	day_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	day_label.add_theme_color_override("font_color", Color("#00f0ff"))
	day_label.add_theme_font_size_override("font_size", 48)
	
	# Secondary Location Subtitle Label (e.g., "SYS_LOC: FLOOR 82 — RESIDENTIAL POD")
	subtitle_label = Label.new()
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_color_override("font_color", Color("#8a99ad"))
	subtitle_label.add_theme_font_size_override("font_size", 16)

	# Load and apply custom fonts if present in the project
	var font_path_day := "res://assets/fonts/80s-retro-future.ttf"
	if ResourceLoader.exists(font_path_day):
		var day_font: Font = load(font_path_day)
		day_label.add_theme_font_override("font", day_font)
		
	var font_path_subtitle := "res://assets/fonts/Micro5Charted-Regular.ttf"
	if ResourceLoader.exists(font_path_subtitle):
		var subtitle_font: Font = load(font_path_subtitle)
		subtitle_label.add_theme_font_override("font", subtitle_font)

	vbox.add_child(day_label)
	vbox.add_child(subtitle_label)

	# Full-screen black overlay placed last so it renders above text during fades
	fade_overlay = ColorRect.new()
	fade_overlay.set_anchors_preset(PRESET_FULL_RECT)
	fade_overlay.color = Color(0, 0, 0, 1) # Start completely opaque
	add_child(fade_overlay)


# ==============================================================================
# TRANSITION PLAYBACK
# ==============================================================================

## Formats the day counter and location text, fades in from black, holds on screen,
## fades back to black, and emits `transition_finished`.
## [param day_number]: Current day in the 14-day cycle (zero-padded to 2 digits).
## [param location_name]: Starting sector/room label displayed beneath the day counter.
func play_day_transition(day_number: int, location_name: String = "FLOOR 82 — RESIDENTIAL POD") -> void:
	# Format single-digit days with a leading zero (e.g., 1 -> "01")
	day_label.text = "DAY " + str(day_number).pad_zeros(2) + " / 14"
	subtitle_label.text = "SYS_LOC: " + location_name
	
	# 1. Fade in from black to reveal the day header
	var tween_in := create_tween()
	tween_in.tween_property(fade_overlay, "color:a", 0.0, fade_duration)
	await tween_in.finished

	# 2. Hold text on screen for the player to read
	await get_tree().create_timer(display_duration).timeout

	# 3. Fade back out to black before switching to the day's gameplay scene
	var tween_out := create_tween()
	tween_out.tween_property(fade_overlay, "color:a", 1.0, fade_duration)
	await tween_out.finished

	# Notify the parent controller (Main.gd) that the transition is complete
	transition_finished.emit()
