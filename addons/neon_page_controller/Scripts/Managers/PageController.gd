@tool
extends Node

## Loading in the script that contains the PageType Enum definition
const PT = preload("res://addons/neon_page_controller/Scripts/Classes/PageType.gd")

## The page that will be shown when the script starts, set to NONE for no starting page
@export var _start_page : PT.PageType

## User-defined Array of UI Pages
@export var _pages : Array[Control] = []

## Bool for if the script should output debug messages
@export var _debug_mode : bool = true

## Variable for storing the current page that's being shown
var _current_page : PT.PageType
var _previous_page : PT.PageType

## PageController init function
func _ready() -> void:
	## Setting singleton page_controller instance for other scripts to access (if NeonSceneRunner is present)
	if ProjectSettings.has_setting("autoload/App"):
		get_tree().root.get_node("App")._page_controller = self
	
	## Make sure all Pages are disabled at start
	for _page in _pages:
		_page.visible = false
	
	## Checking if _start_page has been set, if so turning it on
	if _start_page != PT.PageType.NONE:
		_turn_page_on(_start_page)

## Debug-only functions
func _debug_message(msg : String, error : bool = false):
	if error:
		assert(false, "[NeonPageController Addon Error] " + msg)
		return

	if _debug_mode:
		print( "[NeonPageController Addon] " + msg)

## Main switching page to visible function
func _turn_page_on(_page_on : PT.PageType):
	if _page_on == PT.PageType.NONE: return
	
	## Find the desired UI object reference
	var _chosen_page : Control = _get_page_reference(_page_on)
	
	if _chosen_page == null:
		return

	## Page animation check
	if _chosen_page._animate:
		_animate_page(_chosen_page, true)
		await get_tree().process_frame

	## Make the new page visible
	_chosen_page.visible = true
	_previous_page = _current_page
	_current_page = _page_on
	
	_debug_message("Page: %s is now ON." % PT.PageType.keys()[_page_on])

## Page animation function
func _animate_page(_chosen_page, _open):
	## Checking if the controller should animate the page opening and triggering the animation if so
	if _chosen_page._page_animator:
		var _anim_name = _chosen_page._open_animation_name if _open else _chosen_page._close_animation_name
		
		_chosen_page._page_animator.play(_anim_name)
		_debug_message("Animating the %s of Page: %s." % ["OPENING" if _open else "DISABLING", _chosen_page.name])
		return true
		
	_debug_message("Page: %s does not have an animator. Please add an AnimationPlayer as a child of it to make the script animate it, or disable the Animate bool on the Page." % _chosen_page.name)
	return false

## Get the desired page reference by PageType
func _get_page_reference(_page_type : PT.PageType):
	for _page in _pages:
		if _page._page_type == _page_type:
			return _page
	
	_debug_message("Could not find a page with the PageType [%s]. Check if the page you requested is added to the Pages array and that it has the appropriate PageType set." % [PT.PageType.keys()[_page_type]], true)
	
	return null

## Main disabling page function
func _turn_page_off(_page_off, _page_on = PT.PageType.NONE):
	if _page_off == PT.PageType.NONE:
		return
	
	var _chosen_page = _get_page_reference(_page_off)
	
	if _chosen_page._animate:
		## Wait until the close animation finishes to set the page off (if the animation even started)
		if _animate_page(_chosen_page, false):
			await _chosen_page._page_animator.animation_finished

	_chosen_page.visible = false
	_debug_message("Page: %s is now OFF." % PT.PageType.keys()[_page_off])
	
	## Make sure to stop the animation as it doesnt have a reset state to go to
	if _chosen_page._animate:
		_chosen_page._page_animator.stop()
	
	## Initiating the sequence for _page_on, the _turn_page_on function will see if one is requested 
	_turn_page_on(_page_on)
