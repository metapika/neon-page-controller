@tool
extends Control

## Loading in the script that contains the PageType Enum definition
const PT = preload("res://addons/neon_page_controller/Scripts/Classes/PageType.gd")

## The Page Type that will be later used to identify this Page
@export var _page_type : PT.PageType
## Bool to check if the page should be animated
@export var _animate : bool = false
## Animation name for enabling the Page
@export var _open_animation_name : String = "open"
## Animation name for disabling the Page
@export var _close_animation_name : String = "close"

## AnimationPlayer reference for scripts to use
var _page_animator : AnimationPlayer

func _ready() -> void:
	for _child in get_children():
		if _child is AnimationPlayer:
			_page_animator = _child
