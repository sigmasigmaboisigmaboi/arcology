## MainMenu.gd
## Constructs and manages the dystopian main menu interface programmatically.
## Handles background rendering, procedural rain particles, pulsing status text,
## custom UI styling, audio feedback, and scene transitions.
extends Control

# --- UI Nodes ---
var background_texture: TextureRect
var title_label: Label
var status_label: Label
var button_container: VBoxContainer
var start_button: Button
var quit_button: Button

# --- VFX & Audio Nodes ---
var rain_particles: GPUParticles2D
var sfx_player: AudioStreamPlayer
var sound_enter: AudioStream
var sound_disconnect: AudioStream


## Initializes the full-screen layout and constructs all visual, UI, and audio layers.
func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	
	_create_background_image()
	_create_rain_effect()
	_create_header_text()
	_create_menu_buttons()
	_apply_dystopian_styles()
	_setup_audio()


# ==============================================================================
# VISUALS & ENVIRONMENT
# ==============================================================================

## Loads and configures the pixel-art background image to cover the full viewport.
func _create_background_image() -> void:
	background_texture = TextureRect.new()
	var img_path := "res://assets/sprites/Main_no_rain.jpeg"
	
	if ResourceLoader.exists(img_path):
		background_texture.texture = load(img_path)
	else:
		push_warning("Background texture not found at: " + img_path)
	
	# Keep pixel art sharp without bilinear blurring
	background_texture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	# Stretch across the entire screen while preserving aspect ratio
	background_texture.set_anchors_preset(PRESET_FULL_RECT)
	background_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	
	# Place at index 0 so it renders behind all particles and UI elements
	add_child(background_texture)
	move_child(background_texture, 0)


## Generates a procedural 2D particle rain effect layered over the background.
func _create_rain_effect() -> void:
	rain_particles = GPUParticles2D.new()
	
	# Spawn particles slightly above the top edge of the screen
	var screen_size := get_viewport_rect().size
	rain_particles.position = Vector2(screen_size.x / 2.0, -10.0)
	
	# Configure particle physics and appearance
	var particle_mat := ParticleProcessMaterial.new()
	particle_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	particle_mat.emission_box_extents = Vector3(screen_size.x / 2.0, 1.0, 1.0)
	
	# Fall downward with a slight diagonal wind slant
	particle_mat.direction = Vector3(-0.2, 1.0, 0.0)
	particle_mat.spread = 5.0
	particle_mat.initial_velocity_min = 400.0
	particle_mat.initial_velocity_max = 600.0
	particle_mat.gravity = Vector3(0.0, 98.0, 0.0)
	particle_mat.color = Color("#00f0ff88") # Semi-transparent neon cyan
	
	rain_particles.process_material = particle_mat
	rain_particles.amount = 120
	rain_particles.lifetime = 2.0
	rain_particles.preprocess = 2.0 # Pre-warm simulation so rain is active immediately
	
	# Render above the background image (index 1) but behind UI text and buttons
	add_child(rain_particles)
	move_child(rain_particles, 1)


# ==============================================================================
# UI LAYOUT & ANIMATION
# ==============================================================================

## Creates the main title and the dystopian terminal status line.
func _create_header_text() -> void:
	title_label = Label.new()
	title_label.text = "ARCOLOGY"
	title_label.position = Vector2(80, 120)
	title_label.add_theme_font_size_override("font_size", 50)
	title_label.add_theme_color_override("font_color", Color("#e0e6ed"))
	add_child(title_label)

	status_label = Label.new()
	status_label.text = "SYS_LOC: ARC-09 | OUTSIDE AIR: FATAL | CITIZEN STATUS: CONFINED"
	status_label.position = Vector2(80, 170)
	status_label.add_theme_font_size_override("font_size", 18)
	status_label.add_theme_color_override("font_color", Color("#8b0000"))
	add_child(status_label)
	
	_animate_status_pulse()


## Runs an infinite looping tween that pulses the status label between dark and bright red.
func _animate_status_pulse() -> void:
	if not is_instance_valid(status_label):
		return

	var tween := create_tween().set_loops()
	
	# Pulse to bright neon red
	tween.tween_property(status_label, "theme_override_colors/font_color", Color("#e7003cff"), 0.9)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Fade back to deep warning red
	tween.tween_property(status_label, "theme_override_colors/font_color", Color("#6c0909ff"), 0.9)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## Instantiates the vertical button container and connects menu button signals.
func _create_menu_buttons() -> void:
	button_container = VBoxContainer.new()
	button_container.position = Vector2(80, 220)
	button_container.add_theme_constant_override("separation", 15)
	add_child(button_container)

	# Start / Enter Tower button
	start_button = Button.new()
	start_button.text = "> ENTER TOWER"
	start_button.custom_minimum_size = Vector2(185, 50)
	start_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN # Prevent container stretching
	start_button.pressed.connect(_on_start_pressed)
	button_container.add_child(start_button)

	# Quit / Disconnect button
	quit_button = Button.new()
	quit_button.text = "> DISCONNECT"
	quit_button.custom_minimum_size = Vector2(185, 50)
	quit_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	quit_button.pressed.connect(_on_quit_pressed)
	button_container.add_child(quit_button)


## Applies custom fonts, sharp industrial borders, and hover states to all UI controls.
func _apply_dystopian_styles() -> void:
	# Normal button state: transparent fill with thin neon cyan border
	var style_normal := StyleBoxFlat.new()
	style_normal.bg_color = Color(0, 0, 0, 0)
	style_normal.border_color = Color("#00f0ff")
	style_normal.set_border_width_all(1)
	style_normal.set_corner_radius_all(0) # Sharp corners
	style_normal.content_margin_left = 25

	# Hover button state: solid cyan fill with white border
	var style_hover := style_normal.duplicate()
	style_hover.bg_color = Color("#00f0ff")
	style_hover.border_color = Color("#ffffff")

	# Load custom retro/dystopian fonts if present
	var font_path_dystopian := "res://assets/fonts/Micro5Charted-Regular.ttf"
	if ResourceLoader.exists(font_path_dystopian):
		var dystopian_font: Font = load(font_path_dystopian)
		status_label.add_theme_font_override("font", dystopian_font)
		start_button.add_theme_font_override("font", dystopian_font)
		quit_button.add_theme_font_override("font", dystopian_font)
		
	var font_path_title := "res://assets/fonts/80s-retro-future.ttf"
	if ResourceLoader.exists(font_path_title):
		var title_font: Font = load(font_path_title)
		title_label.add_theme_font_override("font", title_font)

	# Apply StyleBoxes and text colors to menu buttons
	for btn in [start_button, quit_button]:
		btn.add_theme_stylebox_override("normal", style_normal)
		btn.add_theme_stylebox_override("hover", style_hover)
		btn.add_theme_color_override("font_color", Color("#00f0ff"))
		btn.add_theme_color_override("font_hover_color", Color("#07080a"))
		btn.add_theme_font_size_override("font_size", 28)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT


# ==============================================================================
# AUDIO & SIGNAL HANDLERS
# ==============================================================================

## Initializes a single reusable AudioStreamPlayer and preloads menu SFX streams.
func _setup_audio() -> void:
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	
	var enter_path := "res://assets/audio/connect_tower.mp3"
	var disconnect_path := "res://assets/audio/glitch_sound.mp3"
	
	if ResourceLoader.exists(enter_path):
		sound_enter = load(enter_path)
	if ResourceLoader.exists(disconnect_path):
		sound_disconnect = load(disconnect_path)


## Plays the given AudioStream through the shared menu SFX player.
func _play_sfx(sound_stream: AudioStream) -> void:
	if is_instance_valid(sfx_player) and sound_stream != null:
		sfx_player.stream = sound_stream
		sfx_player.play()


## Plays the connection SFX, waits briefly so audio isn't cut off, and loads the intro scene.
func _on_start_pressed() -> void:
	_play_sfx(sound_enter)
	await get_tree().create_timer(0.2).timeout
	
	var intro_scene_path := "res://scenes/intro/intro.tscn"
	if ResourceLoader.exists(intro_scene_path):
		get_tree().change_scene_to_file(intro_scene_path)
	else:
		push_warning("Intro scene not found at: " + intro_scene_path)


## Plays the disconnect glitch SFX, waits briefly, and closes the application.
func _on_quit_pressed() -> void:
	_play_sfx(sound_disconnect)
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()
