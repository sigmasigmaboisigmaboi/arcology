extends Control

# UI Elements
var background: ColorRect
var background_texture: TextureRect
var title_label: Label
var status_label: Label
var start_button: Button
var quit_button: Button
var button_container: VBoxContainer
var tower_rect: ColorRect
var sfx_player: AudioStreamPlayer
var sound_enter: AudioStream
var sound_disconnect: AudioStream
var rain_particles: GPUParticles2D

func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	
	_create_background_image()
	_create_rain_effect()
	_create_header_text()
	_create_menu_buttons()
	_apply_dystopian_styles()
	_setup_audio()

# --- REGEN ANIMATION (GPUParticles2D) ---
func _create_rain_effect() -> void:
	rain_particles = GPUParticles2D.new()
	
	# Partikel ganz oben außerhalb des Screens platzieren & über Breite verteilen
	var screen_size = get_viewport_rect().size
	rain_particles.position = Vector2(screen_size.x / 2.0, -10)
	
	# Material für die Partikel-Physik erstellen
	var particle_mat = ParticleProcessMaterial.new()
	
	# Emission-Zone über die gesamte Bildschirmbreite
	particle_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	particle_mat.emission_box_extents = Vector3(screen_size.x / 2.0, 1, 1)
	
	# Fallrichtung nach unten, leicht schräg wegen Wind
	particle_mat.direction = Vector3(-0.2, 1, 0)
	particle_mat.spread = 5.0
	particle_mat.initial_velocity_min = 400.0
	particle_mat.initial_velocity_max = 600.0
	particle_mat.gravity = Vector3(0, 98, 0)
	
	# Farbe der Tropfen: Leicht transparentes Cyan/Blau für Dystopie-Look
	particle_mat.color = Color("#00f0ff88")
	
	# Material zuweisen
	rain_particles.process_material = particle_mat
	rain_particles.amount = 120              # Anzahl der sichtbaren Tropfen
	rain_particles.lifetime = 2.0             # Lebensdauer der Tropfen
	rain_particles.preprocess = 2.0           # Startet direkt mitten im Regen
	
	# Vor dem Text/Buttons, aber vor dem Hintergrund platzieren
	add_child(rain_particles)
	move_child(rain_particles, 1)

# --- STEP 2: Title & Dystopian Status Text ---
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
	status_label.add_theme_color_override("font_color", Color("#8b0000")) # Startet mit einem dunkleren Rot
	add_child(status_label)
	
	# Startet das Aufleuchten der Statuszeile
	_animate_status_pulse()


# --- Pulsierender Effekt für den Statustext ---
func _animate_status_pulse() -> void:
	if not is_instance_valid(status_label):
		return

	# Erstellt ein unendliches Tween
	var tween = create_tween().set_loops()
	
	# 1. Wechselt zu einem extrem hellen, strahlenden Neon-Rot (Dauer: 0.9 Sekunden)
	tween.tween_property(status_label, "theme_override_colors/font_color", Color("e7003cff"), 0.9)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# 2. Wechselt zurück zu einem dunklen, bedrohlichen Rot (Dauer: 0.9 Sekunden)
	tween.tween_property(status_label, "theme_override_colors/font_color", Color("6c0909ff"), 0.9)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

# --- STEP 3: Create Buttons in a Vertical Box ---
func _create_menu_buttons() -> void:
	button_container = VBoxContainer.new()
	button_container.position = Vector2(80, 220)
	button_container.add_theme_constant_override("separation", 15)
	add_child(button_container)

	# --- Start Button ---
	start_button = Button.new()
	start_button.text = "> ENTER TOWER"
	start_button.custom_minimum_size = Vector2(185, 50) # Schmalere Breite (180px)
	start_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN # Stoppt automatisches Dehnen
	start_button.pressed.connect(_on_start_pressed)
	button_container.add_child(start_button)

	# --- Quit Button ---
	quit_button = Button.new()
	quit_button.text = "> DISCONNECT"
	quit_button.custom_minimum_size = Vector2(185, 50) # Gleiche schmalere Breite (180px)
	quit_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	quit_button.pressed.connect(_on_quit_pressed)
	button_container.add_child(quit_button)

# --- STEP 4: Styling (CSS Equivalent using StyleBoxFlat) ---
func _apply_dystopian_styles() -> void:
	# Define normal state style (Completely Transparent Background with Neon Cyan Border)
	var style_normal = StyleBoxFlat.new()
	
	# Option A: Vollständig transparent (Alpha = 0)
	style_normal.bg_color = Color(0, 0, 0, 0)
	
	# Option B: Falls du einen ganz leicht abgedunkelten / halb-transparenten Effekt möchtest (z. B. 20% Deckkraft):
	# style_normal.bg_color = Color("#0c101733")
	
	style_normal.border_color = Color("#00f0ff") # Neon Cyan Border
	style_normal.set_border_width_all(1)
	style_normal.set_corner_radius_all(0) # Sharp industrial corners
	style_normal.content_margin_left = 25

	# Define hover state style (Lights up cyan when hovered)
	var style_hover = style_normal.duplicate()
	style_hover.bg_color = Color("#00f0ff") # Beim Drüberfahren schlägt die Farbe voll an
	style_hover.border_color = Color("#ffffff")
	# Apply custom font if available in your project
	var font_path_dystopian = "res://assets/fonts/Micro5Charted-Regular.ttf"
	if ResourceLoader.exists(font_path_dystopian):
		var custom_font = load(font_path_dystopian)
		status_label.add_theme_font_override("font", custom_font)
		start_button.add_theme_font_override("font", custom_font)
		quit_button.add_theme_font_override("font", custom_font)
		
	var font_path_title = "res://assets/fonts/80s-retro-future.ttf"
	if ResourceLoader.exists(font_path_title):
		var custom_font = load(font_path_title)
		title_label.add_theme_font_override("font", custom_font)

	# Apply styles to buttons
	for btn in [start_button, quit_button]:
		btn.add_theme_stylebox_override("normal", style_normal)
		btn.add_theme_stylebox_override("hover", style_hover)
		btn.add_theme_color_override("font_color", Color("#00f0ff"))
		btn.add_theme_color_override("font_hover_color", Color("#07080a"))
		btn.add_theme_font_size_override("font_size", 28)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT

# --- AUDIO SETUP ---
func _setup_audio() -> void:
	# Ein einziger Player für alle SFX im Menü
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	
	# Beide MP3-Dateien im Speicher preloaden
	var enter_path = "res://assets/audio/connect_tower.mp3"
	var disconnect_path = "res://assets/audio/glitch_sound.mp3"
	 
	if ResourceLoader.exists(enter_path):
		sound_enter = load(enter_path)
	if ResourceLoader.exists(disconnect_path):
		sound_disconnect = load(disconnect_path)

# Universal-Funktion zum Abspielen beliebiger Sounds
func _play_sfx(sound_stream: AudioStream) -> void:
	if is_instance_valid(sfx_player) and sound_stream != null:
		sfx_player.stream = sound_stream
		sfx_player.play()

# --- SIGNALS ---
func _on_start_pressed() -> void:
	# 1. Enter-Tower Sound abspielen
	_play_sfx(sound_enter)
	
	# Warten, damit der Sound nicht abgeschnitten wird
	await get_tree().create_timer(0.2).timeout
	
	if ResourceLoader.exists("res://scenes/intro/intro.tscn"):
		get_tree().change_scene_to_file("res://scenes/intro/intro.tscn")
	else:
		print("intro.tscn not found.")

func _on_quit_pressed() -> void:
	# 2. Disconnect Sound abspielen
	_play_sfx(sound_disconnect)
	
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()
	

func _create_background_image() -> void:
	background_texture = TextureRect.new()
	
	# Path zu deinem importierten Pixel-Art-Bild
	var img_path = "res://assets/sprites/Main_no_rain.jpeg"
	
	if ResourceLoader.exists(img_path):
		background_texture.texture = load(img_path)
	
	# Pixel scharf halten (kein Weichzeichnen beim Skalieren)
	background_texture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	# Über den gesamten Bildschirm strecken
	background_texture.set_anchors_preset(PRESET_FULL_RECT)
	background_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	
	# Zur Szene hinzufügen und ganz nach hinten setzen (hinter Text & Buttons)
	add_child(background_texture)
	move_child(background_texture, 0)
