extends Area2D

func _ready():
	self.connect("body_entered", self, "on_entered")

func on_entered(body):
	if body.get("invincible") != null:
		if body.invincible == false:
			body.dmg_and_throw(10, body.global_position - self.global_position)
