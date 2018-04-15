extends Area2D

export(NodePath) var CameraPath
var cam = null
var triggered = false

func _ready():
	if CameraPath != null:
		cam = get_node(CameraPath)
		if cam != null:
			self.connect("body_entered", self, "on_body_entered")

func on_body_entered(body):
	if triggered == false:
		if body.get_name() == "Player":
			triggered = true
			cam.TargetPath = body.get_path()
			cam.Offset = Vector2(16, 0)
