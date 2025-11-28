@tool
extends EditorPlugin


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	add_custom_type("PageController", "Node", preload("Scripts/Managers/PageController.gd"), preload("Icons/pc_icon.svg"))
	add_custom_type("Page", "Control", preload("Scripts/Classes/Page.gd"), preload("Icons/page_icon.svg"))

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_custom_type("PageController")
	remove_custom_type("Page")
