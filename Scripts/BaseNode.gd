class_name BaseNode

extends GraphNode

onready var undo_redo = EditorSingleton.undo_redo

onready var old_text = get_text()

func _on_Node_close_request():
	self.queue_free()
	print('removing node')
	EditorSingleton.update_stats(self.name, '-1')
	EditorSingleton.add_history(get_type(self.name), self.name, self.get_offset(), get_text(), get_node('../').get_connections(self.name), 'remove')

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
	$Lines/LineEdit.text = text

func _on_LineEdit_focus_exited():
	add_undo($Lines/LineEdit.text)

func _on_LineEdit_text_entered(new_text):
	add_undo(new_text)

func _on_Node_raise_request():
	self.raise()
