extends Control

# UI Elements
var background: ColorRect
var title_label: Label
var status_label: Label
var start_button: Button
var quit_button: Button
var button_container: VBoxContainer
var tower_rect: ColorRect
var warning_light: ColorRect

func _ready() -> void:
	# 1. Expand root node to fill the entire screen
	set_anchors_preset(PRESET_FULL_RECT)
	
	_create_background()
	_create_tower_code_placeholder()
	_create_header_text()
	_create_menu_buttons()
	_apply_dystopian_styles()

# --- STEP 1: Dark Background ---
func _create_background() -> void:
	background = ColorRect.new()
	background.set_anchors_preset(PRESET_FULL_RECT)
	background.color = Color("#07080a")
	add_child(background)

# --- STEP 2: Title & Dystopian Status Text ---
func _create_header_text() -> void:
	title_label = Label.new()
	title_label.text = "ARCOLOGY"
	title_label.position = Vector2(80, 80)
	title_label.add_theme_font_size_override("font_size", 50)
	title_label.add_theme_color_override("font_color", Color("#e0e6ed"))
	add_child(title_label)

	status_label = Label.new()
	status_label.text = "SYS_LOC: ARC-09 | OUTSIDE AIR: FATAL | CITIZEN STATUS: CONFINED"
	status_label.position = Vector2(80, 140)
	status_label.add_theme_font_size_override("font_size", 18)
	status_label.add_theme_color_override("font_color", Color("#ff4a4a")) # Warning Red
	add_child(status_label)

# --- STEP 3: Create Buttons in a Vertical Box ---
func _create_menu_buttons() -> void:
	button_container = VBoxContainer.new()
	button_container.position = Vector2(80, 260)
	button_container.add_theme_constant_override("separation", 15)
	add_child(button_container)

	start_button = Button.new()
	start_button.text = "> ENTER TOWER"
	start_button.custom_minimum_size = Vector2(300, 60)
	start_button.pressed.connect(_on_start_pressed)
	button_container.add_child(start_button)

	quit_button = Button.new()
	quit_button.text = "> DISCONNECT"
	quit_button.custom_minimum_size = Vector2(300, 60)
	quit_button.pressed.connect(_on_quit_pressed)
	button_container.add_child(quit_button)

# --- STEP 4: Styling (CSS Equivalent using StyleBoxFlat) ---
func _apply_dystopian_styles() -> void:
	# Define normal state style (Dark with Neon Cyan Border)
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color("#0e1217")
	style_normal.border_color = Color("#00f0ff") # Neon Cyan
	style_normal.set_border_width_all(1)
	style_normal.set_corner_radius_all(0) # Sharp industrial corners
	style_normal.content_margin_left = 20

	# Define hover state style (Lights up cyan)
	var style_hover = style_normal.duplicate()
	style_hover.bg_color = Color("#00f0ff")
	style_hover.border_color = Color("#ffffff")

	# Apply custom font if available in your project
	var font_path = "res://assets/fonts/Micro5Charted-Regular.ttf"
	if ResourceLoader.exists(font_path):
		var custom_font = load(font_path)
		title_label.add_theme_font_override("font", custom_font)
		status_label.add_theme_font_override("font", custom_font)
		start_button.add_theme_font_override("font", custom_font)
		quit_button.add_theme_font_override("font", custom_font)

	# Apply styles to buttons
	for btn in [start_button, quit_button]:
		btn.add_theme_stylebox_override("normal", style_normal)
		btn.add_theme_stylebox_override("hover", style_hover)
		btn.add_theme_color_override("font_color", Color("#00f0ff"))
		btn.add_theme_color_override("font_hover_color", Color("#07080a"))
		btn.add_theme_font_size_override("font_size", 28)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT

# --- STEP 5: Signal Event Handlers ---
func _on_start_pressed() -> void:
	# Transition to your main gameplay scene
	if ResourceLoader.exists("res://scenes/intro/intro.tscn"):
		get_tree().change_scene_to_file("res://scenes/intro/intro.tscn")
	else:
		print("intro.tscn not found yet. Creating gameplay scene next.")

func _on_quit_pressed() -> void:
	get_tree().quit()
	

func _create_tower_code_placeholder() -> void:
	# 1. Main Tower Silhouette
	tower_rect = ColorRect.new()
	tower_rect.color = Color("#0b0e14") # Deep metallic dark blue/gray
	
	# Position on the right side spanning top to bottom
	var screen_width = get_viewport_rect().size.x
	var screen_height = get_viewport_rect().size.y
	
	tower_rect.size = Vector2(350, screen_height)
	tower_rect.position = Vector2(screen_width - 380, 0)
	
	add_child(tower_rect)
	move_child(tower_rect, 1) # Put behind UI text
	
	# 2. Glowing Red Beacon Light at the top edge of the tower
	warning_light = ColorRect.new()
	warning_light.color = Color("#ff2222") # Warning Red
	warning_light.size = Vector2(6, 6)
	warning_light.position = Vector2(screen_width - 380 + 20, 20)
	add_child(warning_light)
