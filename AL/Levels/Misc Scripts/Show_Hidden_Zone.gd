extends Area2D

export(NodePath) var TutorialNode = null
var TutNode = null
var fade = 1.0

func _ready():
	set_process(false)
	if TutorialNode != null:
		TutNode = get_node(TutorialNode)
		if TutNode != null:
			self.connect("body_entered", self, "on_body_entered")

func _process(delta):
	if fade > 0:
		TutNode.modulate.a = fade
		fade = max(fade - delta, 0.0)
	else:
		set_process(false)

func on_body_entered(body):
	print("'Ello")
	if body.get_name() == "Player":
		print("Found Player")
		self.disconnect("body_entered", self, "on_body_entered")
		self.set_process(true)
