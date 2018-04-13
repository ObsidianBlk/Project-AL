extends Area2D

onready var parent = $'..'
var triggered = false

func _ready():
	self.connect("body_entered", self, "on_body_entered")

func on_body_entered(body):
	if triggered == false:
		if body.get_name() == "Player":
			triggered = true
			var cam = parent.get_node("Camera_Offset_View")
			cam.TargetPath = body.get_path()
			cam.Offset = Vector2(48, 0)
