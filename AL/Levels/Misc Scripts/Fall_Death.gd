extends Area2D

func _ready():
	self.connect("body_entered", self, "on_body_entered")

func on_body_entered(body):
	if body.get_name() == "Player":
		body.dmg_and_throw(200, Vector2(0,0)) # The damage value should be overkill!
