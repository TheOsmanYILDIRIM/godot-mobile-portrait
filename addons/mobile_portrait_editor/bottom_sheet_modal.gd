@tool
class_name MobileBottomSheetModal
extends PanelContainer

signal closed()
signal height_changed(ratio: float)

enum SheetState {
	HIDDEN,
	HALF_SCREEN,
	FULL_SCREEN
}

var current_state: SheetState = SheetState.HIDDEN
var header_label: Label
var content_container: MarginContainer
var close_btn: Button
var expand_btn: Button
var drag_handle: Control

var is_dragging: bool = false
var drag_start_y: float = 0.0
var original_height: float = 0.0

func _init() -> void:
	visible = false
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

func _ready() -> void:
	_setup_ui()

func _setup_ui() -> void:
	for child in get_children():
		child.queue_free()

	# Mobile Bottom Sheet Style (Rounded top corners, elevated shadow look)
	var style_box := StyleBoxFlat.new()
	style_box.bg_color = Color(0.14, 0.15, 0.19, 0.98)
	style_box.corner_radius_top_left = 16
	style_box.corner_radius_top_right = 16
	style_box.border_width_top = 2
	style_box.border_color = Color(0.3, 0.35, 0.45, 0.8)
	style_box.shadow_color = Color(0.0, 0.0, 0.0, 0.5)
	style_box.shadow_size = 12
	add_theme_stylebox_override("panel", style_box)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 4)
	add_child(vbox)

	# --- Header Bar (Drag handle & title) ---
	var header_bar := PanelContainer.new()
	var header_sb := StyleBoxFlat.new()
	header_sb.bg_color = Color(0.10, 0.11, 0.14, 0.95)
	header_sb.corner_radius_top_left = 16
	header_sb.corner_radius_top_right = 16
	header_sb.content_margin_top = 6
	header_sb.content_margin_bottom = 6
	header_sb.content_margin_left = 12
	header_sb.content_margin_right = 8
	header_bar.add_theme_stylebox_override("panel", header_sb)
	vbox.add_child(header_bar)

	var header_vbox := VBoxContainer.new()
	header_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	header_bar.add_child(header_vbox)

	# Pill handle for dragging
	var pill := Panel.new()
	pill.custom_minimum_size = Vector2(40, 5)
	pill.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var pill_sb := StyleBoxFlat.new()
	pill_sb.bg_color = Color(0.5, 0.55, 0.65, 0.8)
	pill_sb.corner_radius_top_left = 3
	pill_sb.corner_radius_top_right = 3
	pill_sb.corner_radius_bottom_left = 3
	pill_sb.corner_radius_bottom_right = 3
	pill.add_theme_stylebox_override("panel", pill_sb)
	header_vbox.add_child(pill)

	# Header HBox with Title and Control Buttons
	var header_hbox := HBoxContainer.new()
	header_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_vbox.add_child(header_hbox)

	header_label = Label.new()
	header_label.text = "Panel Başlığı"
	header_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_label.add_theme_font_size_override("font_size", 14)
	header_label.add_theme_color_override("font_color", Color(0.9, 0.92, 0.96))
	header_hbox.add_child(header_label)

	# Expand / Restore button
	expand_btn = Button.new()
	expand_btn.text = " ⤢ "
	expand_btn.custom_minimum_size = Vector2(44, 40)
	expand_btn.flat = true
	expand_btn.pressed.connect(_on_expand_pressed)
	header_hbox.add_child(expand_btn)

	# Close button
	close_btn = Button.new()
	close_btn.text = " ✕ "
	close_btn.custom_minimum_size = Vector2(44, 40)
	close_btn.flat = true
	close_btn.pressed.connect(close)
	header_hbox.add_child(close_btn)

	# --- Content Container ---
	content_container = MarginContainer.new()
	content_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_container.add_theme_constant_override("margin_left", 6)
	content_container.add_theme_constant_override("margin_right", 6)
	content_container.add_theme_constant_override("margin_top", 4)
	content_container.add_theme_constant_override("margin_bottom", 6)
	vbox.add_child(content_container)

	# Gesture drag support
	header_bar.gui_input.connect(_on_header_gui_input)

func open(title: String, target_control: Control = null, state: SheetState = SheetState.HALF_SCREEN) -> void:
	header_label.text = title
	visible = true
	current_state = state

	# Attach content if provided
	if target_control and target_control.get_parent() != content_container:
		if target_control.get_parent():
			target_control.get_parent().remove_child(target_control)
		content_container.add_child(target_control)
		target_control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		target_control.size_flags_vertical = Control.SIZE_EXPAND_FILL
		target_control.visible = true

	_apply_state_layout()

func close() -> void:
	current_state = SheetState.HIDDEN
	visible = false
	closed.emit()

func _on_expand_pressed() -> void:
	if current_state == SheetState.HALF_SCREEN:
		current_state = SheetState.FULL_SCREEN
		expand_btn.text = " ⤡ "
	else:
		current_state = SheetState.HALF_SCREEN
		expand_btn.text = " ⤢ "
	_apply_state_layout()

func _apply_state_layout() -> void:
	var parent_viewport_h := get_viewport_rect().size.y
	if parent_viewport_h <= 0:
		parent_viewport_h = 800.0

	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	match current_state:
		SheetState.HALF_SCREEN:
			var target_h = parent_viewport_h * 0.55
			custom_minimum_size = Vector2(0, target_h)
			tween.tween_property(self, "custom_minimum_size:y", target_h, 0.2)
		SheetState.FULL_SCREEN:
			var target_h = parent_viewport_h * 0.88
			custom_minimum_size = Vector2(0, target_h)
			tween.tween_property(self, "custom_minimum_size:y", target_h, 0.2)
		SheetState.HIDDEN:
			visible = false

func _on_header_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag or (event is InputEventMouseMotion and (event as InputEventMouseMotion).button_mask == MOUSE_BUTTON_MASK_LEFT):
		var dy = event.relative.y
		if dy > 15: # Dragged down significantly
			close()
		elif dy < -15 and current_state == SheetState.HALF_SCREEN: # Dragged up
			current_state = SheetState.FULL_SCREEN
			expand_btn.text = " ⤡ "
			_apply_state_layout()
