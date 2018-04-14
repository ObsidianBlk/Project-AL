extends AnimationPlayer

func _ready():
	self.connect("animation_finished", self, "on_finished")

func on_finished(val):
	self.play("Loop")
