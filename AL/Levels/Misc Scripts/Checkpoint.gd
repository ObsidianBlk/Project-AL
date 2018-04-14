extends Area2D

export(int) var checkpoint_id = 0

onready var parent = $"."

func _ready():
	self.connect("body_entered", self, "on_body_entered")

func on_body_entered(body):
	if body.get_name() == "Player":
		player.set_checkpoint(checkpoint_id, parent.position)
