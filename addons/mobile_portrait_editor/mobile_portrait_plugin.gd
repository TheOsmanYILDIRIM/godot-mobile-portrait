@tool
extends EditorPlugin

const BottomNavBarScript = preload("res://addons/mobile_portrait_editor/bottom_nav_bar.gd")
const BottomSheetScript = preload("res://addons/mobile_portrait_editor/bottom_sheet_modal.gd")
const TouchToolbarScript = preload("res://addons/mobile_portrait_editor/mobile_touch_toolbar.gd")

var is_mobile_portrait_mode: bool = false
var toggle_mode_btn: Button

# UI Components
var mobile_top_toolbar: Control
var mobile_bottom_nav: Control
var mobile_bottom_sheet: Control

# References to original editor elements
var editor_base_control: Control
var editor_main_viewport_container: Control

func _enter_tree() -> void:
	# Add custom layout toggle button to top editor toolbar
	toggle_mode_btn = Button.new()
	toggle_mode_btn.text = " 📱 Dikey Mobil UI "
	toggle_mode_btn.toggle_mode = true
	toggle_mode_btn.custom_minimum_size = Vector2(0, 36)
	toggle_mode_btn.tooltip_text = "Godot editörünü dikey mobil ve tek odaklı yerleşime dönüştürür."
	toggle_mode_btn.toggled.connect(_on_mobile_mode_toggled)

	add_control_to_container(CONTAINER_TOOLBAR, toggle_mode_btn)

	editor_base_control = get_editor_interface().get_base_control()
	_setup_mobile_ui_hierarchy()

	# Auto-detect portrait display on Android / Small screens
	_check_auto_enable_portrait()

func _exit_tree() -> void:
	# Clean up UI additions
	if toggle_mode_btn:
		remove_control_from_container(CONTAINER_TOOLBAR, toggle_mode_btn)
		toggle_mode_btn.queue_free()

	_disable_mobile_portrait_mode()

	if mobile_top_toolbar:
		mobile_top_toolbar.queue_free()
	if mobile_bottom_nav:
		mobile_bottom_nav.queue_free()
	if mobile_bottom_sheet:
		mobile_bottom_sheet.queue_free()

func _setup_mobile_ui_hierarchy() -> void:
	if not editor_base_control:
		return

	# 1. Create Floating Top Toolbar
	mobile_top_toolbar = TouchToolbarScript.new()
	mobile_top_toolbar.visible = false
	mobile_top_toolbar.play_project_requested.connect(_on_play_project)
	mobile_top_toolbar.play_scene_requested.connect(_on_play_scene)
	mobile_top_toolbar.stop_project_requested.connect(_on_stop_project)
	mobile_top_toolbar.undo_requested.connect(_on_undo)
	mobile_top_toolbar.redo_requested.connect(_on_redo)

	# 2. Create Floating Bottom Navigation Bar
	mobile_bottom_nav = BottomNavBarScript.new()
	mobile_bottom_nav.visible = false
	mobile_bottom_nav.tab_selected.connect(_on_nav_tab_selected)
	mobile_bottom_nav.toggle_requested.connect(_on_nav_toggle_requested)

	# 3. Create Bottom Sheet Modal
	mobile_bottom_sheet = BottomSheetScript.new()
	mobile_bottom_sheet.visible = false
	mobile_bottom_sheet.closed.connect(_on_bottom_sheet_closed)

	# Add to Editor Base Control with full rect anchors
	editor_base_control.add_child(mobile_top_toolbar)
	editor_base_control.add_child(mobile_bottom_sheet)
	editor_base_control.add_child(mobile_bottom_nav)

	_update_anchors()

func _update_anchors() -> void:
	if mobile_top_toolbar:
		mobile_top_toolbar.anchor_left = 0.0
		mobile_top_toolbar.anchor_right = 1.0
		mobile_top_toolbar.anchor_top = 0.0
		mobile_top_toolbar.anchor_bottom = 0.0
		mobile_top_toolbar.offset_top = 0.0
		mobile_top_toolbar.offset_bottom = 44.0

	if mobile_bottom_nav:
		mobile_bottom_nav.anchor_left = 0.0
		mobile_bottom_nav.anchor_right = 1.0
		mobile_bottom_nav.anchor_top = 1.0
		mobile_bottom_nav.anchor_bottom = 1.0
		mobile_bottom_nav.offset_top = -56.0
		mobile_bottom_nav.offset_bottom = 0.0

	if mobile_bottom_sheet:
		mobile_bottom_sheet.anchor_left = 0.0
		mobile_bottom_sheet.anchor_right = 1.0
		mobile_bottom_sheet.anchor_top = 0.2
		mobile_bottom_sheet.anchor_bottom = 1.0
		mobile_bottom_sheet.offset_bottom = -56.0 # Sits right above the bottom nav bar

func _check_auto_enable_portrait() -> void:
	var vp_size = editor_base_control.get_viewport_rect().size
	if vp_size.x > 0 and vp_size.y > 0:
		# If height > width (Portrait) or width < 600dp, automatically activate
		if vp_size.y > vp_size.x or vp_size.x <= 600:
			toggle_mode_btn.button_pressed = true

func _on_mobile_mode_toggled(pressed: bool) -> void:
	is_mobile_portrait_mode = pressed
	if is_mobile_portrait_mode:
		_enable_mobile_portrait_mode()
	else:
		_disable_mobile_portrait_mode()

func _enable_mobile_portrait_mode() -> void:
	_update_anchors()
	if mobile_top_toolbar:
		mobile_top_toolbar.visible = true
	if mobile_bottom_nav:
		mobile_bottom_nav.visible = true

	# Set default main view to 2D Viewport
	get_editor_interface().set_main_screen_editor("2D")

func _disable_mobile_portrait_mode() -> void:
	if mobile_top_toolbar:
		mobile_top_toolbar.visible = false
	if mobile_bottom_nav:
		mobile_bottom_nav.visible = false
	if mobile_bottom_sheet:
		mobile_bottom_sheet.close()

func _on_nav_tab_selected(tab_id: String) -> void:
	match tab_id:
		"viewport":
			mobile_bottom_sheet.close()
			get_editor_interface().set_main_screen_editor("2D")
		"script":
			mobile_bottom_sheet.close()
			get_editor_interface().set_main_screen_editor("Script")
		"scene":
			var scene_tree_dock = _find_editor_control_by_class(editor_base_control, "SceneTreeDock")
			mobile_bottom_sheet.open("🌳 Sahne Ağacı (Scene)", scene_tree_dock)
		"inspector":
			var inspector_dock = _find_editor_control_by_class(editor_base_control, "EditorInspector")
			mobile_bottom_sheet.open("🔍 Nesne Müfettişi (Inspector)", inspector_dock)
		"filesystem":
			var fs_dock = get_editor_interface().get_file_system_dock()
			mobile_bottom_sheet.open("📂 Dosya Yöneticisi (FileSystem)", fs_dock)
		"output":
			mobile_bottom_sheet.open("🐛 Konsol & Hata Ayıklama (Output/Log)", null)

func _on_nav_toggle_requested(tab_id: String) -> void:
	if mobile_bottom_sheet.visible:
		mobile_bottom_sheet.close()
	else:
		_on_nav_tab_selected(tab_id)

func _on_bottom_sheet_closed() -> void:
	if mobile_bottom_nav:
		mobile_bottom_nav.set_active_tab("viewport")

# --- Quick Action Handlers ---
func _on_play_project() -> void:
	get_editor_interface().play_main_scene()

func _on_play_scene() -> void:
	get_editor_interface().play_current_scene()

func _on_stop_project() -> void:
	get_editor_interface().stop_playing_scene()

func _on_undo() -> void:
	var undo_redo = get_undo_redo()
	if undo_redo:
		undo_redo.undo()

func _on_redo() -> void:
	var undo_redo = get_undo_redo()
	if undo_redo:
		undo_redo.redo()

func _find_editor_control_by_class(node: Node, target_class_name: String) -> Control:
	if not node:
		return null
	if node.get_class() == target_class_name:
		return node as Control
	for child in node.get_children():
		var found = _find_editor_control_by_class(child, target_class_name)
		if found:
			return found
	return null
