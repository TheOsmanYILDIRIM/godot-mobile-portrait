@tool
class_name MobileTouchToolbar
extends PanelContainer

signal play_project_requested()
signal play_scene_requested()
signal stop_project_requested()
signal undo_requested()
signal redo_requested()
signal orientation_toggle_requested()

func _init() -> void:
	custom_minimum_size = Vector2(0, 44)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL

func _ready() -> void:
	_setup_ui()

func _setup_ui() -> void:
	for child in get_children():
		child.queue_free()

	# Floating Top / Quick Bar Style
	var style_box := StyleBoxFlat.new()
	style_box.bg_color = Color(0.12, 0.13, 0.16, 0.95)
	style_box.border_width_bottom = 1
	style_box.border_color = Color(0.25, 0.28, 0.35, 1.0)
	style_box.content_margin_left = 6
	style_box.content_margin_right = 6
	style_box.content_margin_top = 4
	style_box.content_margin_bottom = 4
	add_theme_stylebox_override("panel", style_box)

	var hbox := HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_theme_constant_override("separation", 6)
	add_child(hbox)

	# 1. Project Title / Logo Badge
	var title_lbl := Label.new()
	title_lbl.text = "⚡ Godot Mobile"
	title_lbl.add_theme_font_size_override("font_size", 12)
	title_lbl.add_theme_color_override("font_color", Color(0.4, 0.75, 1.0))
	hbox.add_child(title_lbl)

	# Spacer
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)

	# 2. Undo Button
	var undo_btn := _create_quick_btn("↶", "Geri Al", func(): undo_requested.emit())
	hbox.add_child(undo_btn)

	# 3. Redo Button
	var redo_btn := _create_quick_btn("↷", "İleri Al", func(): redo_requested.emit())
	hbox.add_child(redo_btn)

	# 4. Play Scene Button
	var play_scene_btn := _create_quick_btn("▶🎬", "Sahneyi Oynat", func(): play_scene_requested.emit(), Color(0.2, 0.65, 0.3, 0.8))
	hbox.add_child(play_scene_btn)

	# 5. Play Project Button
	var play_proj_btn := _create_quick_btn("▶", "Projeyi Oynat", func(): play_project_requested.emit(), Color(0.15, 0.5, 0.85, 0.8))
	hbox.add_child(play_proj_btn)

	# 6. Stop Button
	var stop_btn := _create_quick_btn("⏹", "Durdur", func(): stop_project_requested.emit(), Color(0.75, 0.2, 0.2, 0.8))
	hbox.add_child(stop_btn)

func _create_quick_btn(icon_text: String, tooltip: String, on_press: Callable, bg_color: Color = Color(0.2, 0.22, 0.28, 0.9)) -> Button:
	var btn := Button.new()
	btn.text = icon_text
	btn.tooltip_text = tooltip
	btn.custom_minimum_size = Vector2(44, 40) # 44dp touch target
	btn.focus_mode = Control.FOCUS_NONE

	var sb := StyleBoxFlat.new()
	sb.bg_color = bg_color
	sb.corner_radius_top_left = 6
	sb.corner_radius_top_right = 6
	sb.corner_radius_bottom_left = 6
	sb.corner_radius_bottom_right = 6
	sb.content_margin_left = 8
	sb.content_margin_right = 8

	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_font_size_override("font_size", 13)
	btn.pressed.connect(on_press)
	return btn
