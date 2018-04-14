extends Area2D

export(NodePath) var TutorialNode = null

onready var parent = $'..'
var triggered = false
var triggered_out = false
var done = false
var wait_time = 3.0
var fade_time = 1.0
var TutNode = null

func _ready():
	if TutorialNode != null:
		TutNode = get_node(TutorialNode)
		if TutNode != null:
			set_process(true)
			self.connect("body_entered", self, "on_body_entered")
			self.connect("body_exited", self, "on_body_exit")

func _process(delta):
	if triggered == true and wait_time == 0:
		if triggered_out == false:
			if fade_time > 0:
				fade_time = max(fade_time - delta, 0)
				TutNode.modulate.a = 1.0 - fade_time
		else:
			if fade_time > 0:
				fade_time = max(fade_time - delta, 0)
				TutNode.modulate.a = fade_time
			else:
				done = true
				set_process(false)
	else:
		wait_time = max(wait_time - delta, 0)
		

func on_body_entered(body):
	if triggered == false:
		if body.get_name() == "Player":
			triggered = true
			self.disconnect("body_entered", self, "on_body_entered")

func on_body_exit(body):
	if triggered == true and body.get_name() == "Player":
		triggered_out = true
		fade_time = TutNode.modulate.a
		self.disconnect("body_exit", self, "on_body_exit")
