extends Control

## Loading in the script that contains the PageType Enum definition
const PT = preload("res://addons/neon_page_controller/Scripts/Classes/PageType.gd")

var _page_controller : Node

## Store App ref
var _app : Node

func _ready() -> void:
	await get_tree().process_frame
	
	## Grab the reference to the PageController.
	## If the NeonSceneRunner Addon is present, use the already created ref, ref the Node.
	if ProjectSettings.has_setting("autoload/App"):
		_app = get_tree().root.get_node("App")
		_page_controller = _app._page_controller
		print("[NeonPageController Addon] Successfully connected to NeonSceneRunner Addon!")
	else:
		_page_controller = $"../.."

## Go to in-game page from main menu
func _on_play_game_button_button_down() -> void:
	## Example usage of singular variables in _turn_page_off and _turn_page_on functions
	_page_controller._turn_page_off(PT.PageType.MAINMENU)
	
	## NeonSceneRunner Addon integration
	if _app:
		_app._runner._change_scene("ExampleScene1")
		await _app._runner._scene_initialized
	
	_page_controller._turn_page_on(PT.PageType.INGAME)

## Go to the in-game page again
func _on_resume_button_down() -> void:
	## Example usage of _turn_page_off for not only disabling a selected page, but switching to a new one
	_page_controller._turn_page_off(PT.PageType.PAUSED, PT.PageType.INGAME)

## Go back to main menu
func _on_main_menu_button_down() -> void:
	## You can also cast the _current_page to
	## transition from any page that is currently visible to the selected one
	_page_controller._turn_page_off(_page_controller._current_page, PT.PageType.MAINMENU)
	
	## NeonSceneRunner Addon integration
	if _app:
		_app._runner._change_scene("ExampleMainMenu")

## Show the pause menu
func _on_pause_button_down() -> void:
	_page_controller._turn_page_off(_page_controller._current_page, PT.PageType.PAUSED)
