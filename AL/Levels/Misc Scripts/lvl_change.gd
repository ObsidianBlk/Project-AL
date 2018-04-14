extends Area2D

# Script name is a misnomer. This just holds the name of the next level.
# It's actually the player script that does the transition... seriously!

export(String) var level_name

func _ready():
	if not (level_name == null or level_name == ""):
		self.connect("body_entered", self, "on_body_entered")
		self.connect("body_exited", self, "on_body_exited")

func on_body_entered(body):
	if body.get_name() == "Player":
		body.next_level = level_name

func on_body_exited(body):
	if body.get_name() == "Player":
		body.next_level = ""
