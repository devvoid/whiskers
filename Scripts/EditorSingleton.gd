extends Node

onready var modal_save = get_node("/root/Editor/Mount/Modals/Save")
onready var modal_open = get_node("/root/Editor/Mount/Modals/Open")
onready var modal_quit_conf = get_node("/root/Editor/Mount/Modals/QuitConf")
onready var modal_about = get_node("/root/Editor/Mount/Modals/About")
onready var modal_import = get_node("/root/Editor/Mount/Modals/Import")

onready var menu_file = get_node("/root/Editor/Mount/MainWindow/MenuBar/Menus/File/Menu")
onready var menu_edit = get_node("/root/Editor/Mount/MainWindow/MenuBar/Menus/Edit/Menu")
onready var menu_help = get_node("/root/Editor/Mount/MainWindow/MenuBar/Menus/Help/Menu")

var in_menu : = false

var undo_redo = UndoRedo.new()

# Used primarily in Graph, but here because it needs to be global.
# warning-ignore:unused_class_variable
var has_player_singleton = false

# For history
var current_history : = 0
var history_objects = Dictionary()

# Used in Graph.gd and GraphNode.gd
# TODO: Rewrite GraphNode.get_type to not use node_names, so that this can be moved to Graph
# warning-ignore:unused_class_variable
var node_names : = ['Dialogue', 'Option', 'Expression', 'Condition', 'Jump', 'End', 'Start', 'Comment']

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
		if Input.is_action_pressed("save"):
			close_all()
			modal_save.show()
			modal_save.current_file = get_node("/root/Editor/Mount/MainWindow/Editor/Info/Info/Name/Input").get_text()+'.json'
		if Input.is_action_pressed("open"):
			close_all()
			modal_open.show()
		if Input.is_action_pressed("quit"):
			close_all()
			modal_quit_conf.show()
		if Input.is_action_pressed("help"):
			close_all()
			modal_about.show()
		if Input.is_action_pressed("new"):
			close_all()
			get_node("/root/Editor/Mount/Modals/New").show()
		if Input.is_action_pressed("import"):
			close_all()
			modal_import.show()
		if Input.is_action_pressed("undo"):
			undo_history()
		if Input.is_action_pressed("redo"):
			redo_history()

func close_all() -> void:
	# Modals
	modal_save.hide()
	modal_open.hide()
	modal_quit_conf.hide()
	modal_about.hide()
	modal_import.hide()
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
func add_history(_node, _name, _offset, _text, _connects_from, _action) -> void:
	pass

func undo_history() -> void:
	if !undo_redo.is_commiting_action():
		undo_redo.undo()

func last_instance_of(name : String) -> int:
	var last_instance_position : int
	for i in range(0, current_history - 1):
		if history_objects[i]['name'] == name:
			last_instance_position = i
	return last_instance_position

func connection_in_timeline(name : String) -> void:
	var graph : GraphEdit = get_node("/root/Editor/Mount/MainWindow/Editor/Graph/Dialogue Graph")
	var list : Array = graph.get_connection_list()
	var connections : = Dictionary()
	var connects_from : = Array()
	
	for i in range(0, current_history - 1):
		if name == history_objects[i]['name']:
			connections = history_objects[i]['connects_from']

	var connection_count : int = connections.size()
	for i in range(0, connection_count):
		if connection_count > 0:
			connects_from.append(connections[i+1])

	for i in range(0, list.size()):
		if graph.has_node(list[i]['to']) and not list[i]['from'] in connects_from:
			graph.disconnect_node(list[i]['from'], 0, name, 0)
	
	for i in range(0, current_history - 1):
		if history_objects[i]['connects_from']:
			for j in range(0, history_objects[i]['connects_from'].size()):
				if history_objects[i]['connects_from'][j+1] != name and history_objects[i]['name'] == name:
					var err = graph.connect_node(history_objects[i]['connects_from'][j+1], 0, name, 0)
					
					if (err):
						print("[EditorSingleton.connection_in_timeline]: Failed to connect nodes")

func redo_history() -> void:
	if !undo_redo.is_commiting_action():
		undo_redo.redo()

func update_tab_title(unsaved : bool) -> void:
	var graph = get_node('/root/Editor/Mount/MainWindow/Editor/Graph')
	
	if unsaved:
		graph.set_tab_title(0, 'Dialogue Graph*')
	else:
		graph.set_tab_title(0, 'Dialogue Graph')
	
	graph.update()

func update_stats(what : String, amount : String) -> void:
	if 'Option' in what:
		var amount_node = get_node("/root/Editor/Mount/MainWindow/Editor/Info/Nodes/Stats/PanelContainer/StatsCon/ONodes/Amount")
		amount_node.set_text(str(int(amount_node.get_text()) + int(amount)))
	if 'Dialogue' in what:
		var amount_node = get_node("/root/Editor/Mount/MainWindow/Editor/Info/Nodes/Stats/PanelContainer/StatsCon/DNodes/Amount")
		amount_node.set_text(str(int(amount_node.get_text()) + int(amount)))