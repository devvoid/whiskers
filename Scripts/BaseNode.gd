class_name BaseNode

extends GraphNode

onready var undo_redo = EditorSingleton.undo_redo

onready var old_text = get_text()

func _on_Node_close_request():
	undo_redo.create_action("delete_node_"+name)
	undo_redo.add_do_method(get_parent(), "_undo_add_node", name)
	undo_redo.add_undo_method(get_parent(), "_redo_add_node", load("res://Scenes/Nodes/"+get_type(name)+".tscn"), name, offset, get_text())
	undo_redo.commit_action()

func _on_Node_resize_request(new_minsize):
	# Trying to allow undo/redo on this
	# caused some very odd bugs.
	rect_size = new_minsize

func _on_Node_dragged(from, to):
	get_node('../').lastNodePosition = to
	undo_redo.create_action("move_node_"+name)
	undo_redo.add_do_property(self, "offset", to)
	undo_redo.add_undo_property(self, "offset", from)
	undo_redo.commit_action()

func _on_Node_resized():
	get_node("Lines").rect_min_size.y = self.get_rect().size.y - 45

func get_type(name):
	var nodes = EditorSingleton.node_names
	for i in range(0, nodes.size()):
		if name in nodes[i]:
			return nodes[i]

func get_text():
	if self.has_node('Lines'):
		return self.get_node('Lines').get_child(0).get_text()
	else:
		return ''

func add_undo(new_text):
	undo_redo.create_action("edit_text_"+name)
	undo_redo.add_do_method(self, "set_text", new_text)
	undo_redo.add_undo_method(self, "set_text", old_text)
	undo_redo.commit_action()
	
	old_text = new_text

func set_text(text):
	if has_node("Lines/LineEdit"):
		$Lines/LineEdit.text = text

func _on_LineEdit_focus_exited():
	add_undo($Lines/LineEdit.text)

func _on_LineEdit_text_entered(new_text):
	add_undo(new_text)

func _on_Node_raise_request():
	self.raise()
