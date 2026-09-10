@tool
class_name MobileBottomNavBar
extends PanelContainer

signal tab_selected(tab_id: String)
signal toggle_requested(tab_id: String)

enum TabID {
	VIEWPORT_2D,
	VIEWPORT_3D,
	SCENE_TREE,
	INSPECTOR,
	FILESYSTEM,
	SCRIPT,
	OUTPUT_LOG
}

var current_active_tab: String = "viewport_2d"
var button_group: ButtonGroup = ButtonGroup.new()
var buttons: Dictionary = {}

func _init() -> void:
	custom_minimum_size = Vector2(0, 56) # 56dp standard mobile navigation bar height
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_SHRINK_END

func _ready() -> void:
	_setup_ui()

func _setup_ui() -> void:
	# Clean existing children if any
	for child in get_children():
		child.queue_free()

	# Main background styling
	var style_box := StyleBoxFlat.new()
	style_box.bg_color = Color(0.12, 0.13, 0.16, 0.98)
	style_box.border_width_top = 1
	style_box.border_color = Color(0.25, 0.28, 0.35, 1.0)
	style_box.content_margin_top = 4
	style_box.content_margin_bottom = 6
	style_box.content_margin_left = 6
	style_box.content_margin_right = 6
	add_theme_stylebox_override("panel", style_box)

	var hbox := HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 4)
	add_child(hbox)

	# Tab configuration (Title, Icon emoji / label, ID)
	var tabs = [
		{"id": "viewport", "title": "2D/3D", "icon": "🎨"},
		{"id": "scene", "title": "Sahne", "icon": "🌳"},
		{"id": "inspector", "title": "Müfettiş", "icon": "🔍"},
		{"id": "filesystem", "title": "Dosyalar", "icon": "📂"},
		{"id": "script", "title": "Kod", "icon": "📝"},
		{"id": "output", "title": "Konsol", "icon": "🐛"}
	]

	for tab in tabs:
		var btn := _create_nav_button(tab["id"], tab["title"], tab["icon"])
		hbox.add_child(btn)
		buttons[tab["id"]] = btn

	# Default active
	set_active_tab("viewport")

func _create_nav_button(id: String, title: String, icon_text: String) -> Button:
	var btn := Button.new()
	btn.text = "%s\n%s" % [icon_text, title]
	btn.custom_minimum_size = Vector2(50, 48) # Minimum touch target size >= 48dp
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
	btn.toggle_mode = true
	btn.button_group = button_group
	btn.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS

	# Modern flat styling with highlight
	var normal_sb := StyleBoxFlat.new()
	normal_sb.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	normal_sb.corner_radius_top_left = 8
	normal_sb.corner_radius_top_right = 8
	normal_sb.corner_radius_bottom_left = 8
	normal_sb.corner_radius_bottom_right = 8

	var pressed_sb := StyleBoxFlat.new()
	pressed_sb.bg_color = Color(0.2, 0.35, 0.6, 0.35)
	pressed_sb.border_width_bottom = 3
	pressed_sb.border_color = Color(0.3, 0.6, 1.0, 1.0)
	pressed_sb.corner_radius_top_left = 8
	pressed_sb.corner_radius_top_right = 8
	pressed_sb.corner_radius_bottom_left = 8
	pressed_sb.corner_radius_bottom_right = 8

	btn.add_theme_stylebox_override("normal", normal_sb)
	btn.add_theme_stylebox_override("hover", normal_sb)
	btn.add_theme_stylebox_override("pressed", pressed_sb)
	btn.add_theme_font_size_override("font_size", 10)
	btn.add_theme_color_override("font_color", Color(0.75, 0.78, 0.85))
	btn.add_theme_color_override("font_pressed_color", Color(0.4, 0.75, 1.0))

	btn.pressed.connect(func():
		_on_button_pressed(id)
	)

	return btn

func _on_button_pressed(id: String) -> void:
	if current_active_tab == id and id != "viewport" and id != "script":
		# Second tap toggles/closes the bottom sheet
		toggle_requested.emit(id)
	else:
		current_active_tab = id
		tab_selected.emit(id)

func set_active_tab(id: String) -> void:
	current_active_tab = id
	if buttons.has(id):
		buttons[id].button_pressed = true
