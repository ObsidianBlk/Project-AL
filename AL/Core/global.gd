extends Node

onready var root = get_tree().get_root()
onready var base_size = Vector2(340, 240)

func _ready():
	root.connect("size_changed", self, "_on_screen_resized")
	_on_screen_resized()

func _on_screen_resized():
	# First... make sure the new window size does not shrink more than the game's
	# actual resolution
	var new_window_size = OS.get_window_size()
	new_window_size.x = max(new_window_size.x, base_size.x)
	new_window_size.y = max(new_window_size.y, base_size.y)
	OS.set_window_size(new_window_size)
	
	# Reset the viewport to the "base size".
	root.set_size(base_size)