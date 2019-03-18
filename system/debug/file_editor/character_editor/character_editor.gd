extends SugarEditorTab

"""
Editor for VN scenes
"""

var character : Dictionary
var code_viewer = TextEdit.new()

var hbox_container := HBoxContainer.new()
var editor_container := VBoxContainer.new()
var main_panel := Panel.new()
var layer_list_vbox := VBoxContainer.new()
var main_panel_vbox := VBoxContainer.new()
const EDITABLE_FIELDS = {
	"name": {
		"name": "EDITOR_CHARACTER_NAME"
	}
}

const SugarGraphicsLayerEditor = preload("res://system/debug/file_editor/character_editor/graphics_layer_editor.gd")

func add_fields():
	for field in main_panel_vbox.get_children():
		field.free()
	for layer in layer_list_vbox.get_children():
		layer.free()
	for field_name in EDITABLE_FIELDS:
		if character.has(field_name):
			var field_label = Label.new()
			field_label.text = EDITABLE_FIELDS[field_name].name
			main_panel_vbox.add_child(field_label)
			var line_edit = LineEdit.new()
			
			main_panel_vbox.add_child(line_edit)
			line_edit.text = character[field_name]
			
			line_edit.connect("text_changed", self, "_on_field_text_changed", [field_name])
			
	for layer in character.graphics_layers:
		add_new_graphics_layer(layer)

func _ready():
	var buttons_container := HBoxContainer.new()
	add_child(editor_container)
	editor_container.add_child(buttons_container)
	editor_container.add_child(code_viewer)

	
	var view_code_button = Button.new()
	view_code_button.hint_tooltip = tr("SCENE_EDITOR_HINT_VIEW_CODE")
	view_code_button.icon = ImageTexture.new()
	view_code_button.icon.load("res://system/debug/file_editor/icons/icon_script.svg")
	
	buttons_container.add_child(view_code_button)
	buttons_container.alignment = HBoxContainer.ALIGN_END
	
	code_viewer.size_flags_vertical = SIZE_EXPAND_FILL
	code_viewer.visible = false
	code_viewer.syntax_highlighting = true
	code_viewer.show_line_numbers = true
	code_viewer.add_color_region("\"", "\"", Color("#ffcf7d34"))
	code_viewer.add_keyword_color("true", Color("#ffcc8242"))
	code_viewer.readonly = true

	view_code_button.connect("button_down", self, "_toggle_code_view")
	
	hbox_container.size_flags_vertical = SIZE_EXPAND_FILL
	hbox_container.size_flags_horizontal = SIZE_EXPAND_FILL
	hbox_container.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	editor_container.add_child(hbox_container)
	main_panel.size_flags_vertical = SIZE_EXPAND_FILL
	main_panel.size_flags_horizontal = SIZE_EXPAND_FILL
	
	main_panel.add_child(main_panel_vbox)
	
	main_panel_vbox.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	
	hbox_container.add_child(main_panel)
	var graphics_vbox = VBoxContainer.new()
	graphics_vbox.size_flags_vertical = SIZE_EXPAND_FILL
	graphics_vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	layer_list_vbox.size_flags_vertical = SIZE_EXPAND_FILL
	layer_list_vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	
	var layer_list_button_container = HBoxContainer.new()
	buttons_container.add_child(layer_list_button_container)
	
	layer_list_button_container.alignment = BoxContainer.ALIGN_END
	
	var add_layer_button = Button.new()
	add_layer_button.icon = ImageTexture.new()
	add_layer_button.icon.load("res://system/debug/file_editor/icons/icon_add.svg")
	add_layer_button.hint_tooltip = tr("CHARACTER_EDITOR_ADD_GRAPHICS_LAYER")
	
	add_layer_button.connect("button_down", self, "_on_add_graphics_layer")
	
	layer_list_button_container.add_child(add_layer_button)
	
	hbox_container.add_child(graphics_vbox)
	graphics_vbox.add_child(layer_list_vbox)
	
	main_panel_vbox.margin_top = 10
	main_panel_vbox.margin_left = 10
	main_panel_vbox.margin_right = -10
func _toggle_code_view():
	code_viewer.visible = !code_viewer.visible
	hbox_container.visible = !hbox_container.visible
	if code_viewer.visible:
		code_viewer.text = get_content()

func set_content(_content):
	content = _content
	character = JSON.parse(_content).result
	add_fields()
	
func add_new_graphics_layer(data):
	var layer = SugarGraphicsLayerEditor.new()
	layer.layer_data = data
	layer_list_vbox.add_child(layer)
	layer.character = path.split("/")[-1].split(".json")[0]
	layer.connect("layer_changed", self, "_on_layer_changed")
	layer.connect("move_up", self, "_on_move_layer_up")
	layer.connect("move_down", self, "_on_move_layer_down")
	layer.connect("delete", self, "_on_delete_layer")
	
func swap_layers(idx1: int, idx2: int):
	var temp : Dictionary = character.graphics_layers[idx1]
	character.graphics_layers[idx1] = character.graphics_layers[idx2]
	character.graphics_layers[idx2] = temp
	
func _on_move_layer_up(layer_idx: int):
	swap_layers(layer_idx, layer_idx-1)
func _on_move_layer_down(layer_idx: int):
	swap_layers(layer_idx, layer_idx+1)
func _on_delete_layer(layer_idx: int):
	character.graphics_layers.remove(layer_idx)
	
func _on_layer_changed(idx):
	character.graphics_layers[idx] = layer_list_vbox.get_child(idx).layer_data
	
func _on_add_graphics_layer():
	var data = SJSON.get_format_defaults("character_graphics_layer")
	character.graphics_layers.append(data)
	add_new_graphics_layer(data)
func _on_field_text_changed(value, field):
	character[field] = value
func get_content():
	return JSON.print(character, "  ")