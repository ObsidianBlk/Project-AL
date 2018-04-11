extends Area2D

func _ready():
	self.connect("body_entered", self, "_on_body_entered")
	self.connect("body_exited", self, "_on_body_exited")


func _on_body_entered(body):
	if body.get("on_ladder") != null:
		body.on_ladder = true

func _on_body_exited(body):
	if body.get("on_ladder") != null:
		body.on_ladder = false
