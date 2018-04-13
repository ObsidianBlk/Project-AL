extends Area2D

var dmg = 10

func _ready():
	self.connect("body_entered", self, "on_entered")

func on_entered(body):
	if body.get("invincible") != null:
		if not body.invincible:
			var flyback = body.global_position - self.global_position
			body.dmg_and_throw(dmg, flyback)
