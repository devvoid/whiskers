extends GridContainer

# Menus
onready var fileMenu = $File/Menu
onready var helpMenu = $Help/Menu
onready var editMenu = $Edit/Menu


#Dialog Windows
onready var saveDialog = get_node("../../../Modals/Save")
onready var openDialog = get_node("../../../Modals/Open")
onready var quitDialog = get_node("../../../Modals/QuitConf")
onready var aboutDialog = get_node("../../../Modals/About")
onready var newDialog = get_node("../../../Modals/New")

func _on_File_pressed():
	if(fileMenu.is_visible()):
		fileMenu.hide()
	else:
		EditorSingleton.close_all()
		fileMenu.show()
		fileMenu.set_as_toplevel(true)

func _on_QuitConf_confirmed():
	get_tree().quit()

func _on_Help_pressed():
	if(helpMenu.is_visible()):
		helpMenu.hide()
	else:
		EditorSingleton.close_all()
		helpMenu.show()
		helpMenu.set_as_toplevel(true)

func _on_Edit_pressed():
	if(editMenu.is_visible()):
		editMenu.hide()
	else:
		EditorSingleton.close_all()
		editMenu.show()
		editMenu.set_as_toplevel(true)

func _on_About_pressed():
	EditorSingleton.close_all()
	aboutDialog.show()

func _on_Save_pressed():
	EditorSingleton.close_all()
	
	if EditorSingleton.current_file_path == "":
		saveDialog.show()
	else:
		get_node("/root/Editor/Mount/MainWindow/Editor/Graph/Dialogue Graph")._save_whiskers(EditorSingleton.current_file_path)

func _on_SaveAs_pressed():
	EditorSingleton.close_all()
	saveDialog.show()

func _on_New_pressed():
	EditorSingleton.close_all()
	newDialog.show()

func _on_Open_pressed():
	EditorSingleton.close_all()
	openDialog.show()

func _on_Quit_pressed():
	EditorSingleton.close_all()
	quitDialog.show()

func _on_menAct_mouse_entered():
	EditorSingleton.in_menu = true

func _on_menAct_mouse_exited():
	if(EditorSingleton.in_menu == true):
		EditorSingleton.in_menu = false

func _on_Undo_pressed():
	EditorSingleton.close_all()
	EditorSingleton.undo_history()

func _on_Redo_pressed():
	EditorSingleton.close_all()
	EditorSingleton.redo_history()

func _on_source_pressed():
	var err = OS.shell_open("https://github.com/littleMouseGames/whiskers")
	
	if (err):
		print("Failed to open URL. View it manually in your browser: "
				+ "https://github.com/littleMouseGames/whiskers")

