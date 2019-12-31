extends Node

onready var modal_new = get_node("/root/Editor/Mount/Modals/New")
onready var modal_save = get_node("/root/Editor/Mount/Modals/Save")
onready var modal_open = get_node("/root/Editor/Mount/Modals/Open")
onready var modal_quit_conf = get_node("/root/Editor/Mount/Modals/QuitConf")
onready var modal_about = get_node("/root/Editor/Mount/Modals/About")

onready var menu_file = get_node("/root/Editor/Mount/MainWindow/MenuBar/Menus/File/Menu")
onready var menu_edit = get_node("/root/Editor/Mount/MainWindow/MenuBar/Menus/Edit/Menu")
onready var menu_help = get_node("/root/Editor/Mount/MainWindow/MenuBar/Menus/Help/Menu")

var in_menu : = false

var undo_redo = UndoRedo.new()

var current_file_path: String = ""

# Used in Graph.gd and GraphNode.gd
# TODO: Rewrite GraphNode.get_type to not use node_names, so that this can be moved to Graph
# warning-ignore:unused_class_variable
var node_names = ['Dialogue', 'Option', 'Expression', 'Condition', 'Jump', 'End', 'Start', 'Comment']

func get_node_type(name : String) -> String:
	var regex : = RegEx.new()
	var err = regex.compile("[a-zA-Z]+")
	if (err):
		print("[EditorSingleton.get_node_type]: Failed to compile regex with string: [a-zA-Z]+")
	
	var result : RegExMatch = regex.search(name)
	
	if !result:
		print("[EditorSingleton.get_node_type]: Invalid regex output from input " + name)
		return ""
	
	return result.get_string()

func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("save"):
			close_all()
			
			if current_file_path == "":
				modal_save.show()
			else:
				get_node("/root/Editor/Mount/MainWindow/Editor/Graph/Dialogue Graph")._save_whiskers(current_file_path)
		if Input.is_action_just_pressed("save_as"):
			close_all()
			modal_save.show()
			modal_save.current_file = ""
		if Input.is_action_just_pressed("open"):
			close_all()
			modal_open.show()
		if Input.is_action_just_pressed("quit"):
			close_all()
			modal_quit_conf.show()
		if Input.is_action_just_pressed("help"):
			close_all()
			modal_about.show()
		if Input.is_action_just_pressed("new"):
			close_all()
			modal_new.show()
		if Input.is_action_just_pressed("undo"):
			undo_history()
		if Input.is_action_just_pressed("redo"):
			redo_history()

func close_all() -> void:
	# Modals
	modal_save.hide()
	modal_open.hide()
	modal_quit_conf.hide()
	modal_about.hide()
	# Menus
	menu_file.hide()
	menu_help.hide()
	menu_edit.hide()

func _input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			BUTTON_LEFT:
				if(!in_menu):
					menu_file.hide()
					menu_help.hide()
					menu_edit.hide()

#===== History Management
func undo_history() -> void:
	if !undo_redo.is_commiting_action():
		undo_redo.undo()

func redo_history() -> void:
	if !undo_redo.is_commiting_action():
		undo_redo.redo()

func update_stats(what : String, amount : String) -> void:
	if 'Option' in what:
		var amount_node = get_node("/root/Editor/Mount/MainWindow/Editor/Info/Nodes/Stats/PanelContainer/StatsCon/ONodes/Amount")
		amount_node.set_text(str(int(amount_node.get_text()) + int(amount)))
	if 'Dialogue' in what:
		var amount_node = get_node("/root/Editor/Mount/MainWindow/Editor/Info/Nodes/Stats/PanelContainer/StatsCon/DNodes/Amount")
		amount_node.set_text(str(int(amount_node.get_text()) + int(amount)))

