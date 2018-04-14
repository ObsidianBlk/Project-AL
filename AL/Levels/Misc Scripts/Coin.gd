extends Area2D

export(bool) var special = false

var score = 10

func _ready():
	if special != true:
		special = false
	else:
		$Sprite.region_rect.position.y += 8
	self.connect("body_entered", self, "on_body_entered")

func on_body_entered(body):
	if body.get_name() == "Player":
		var total_score = score
		if special:
			total_score *= 4
			
		player.score(total_score)
		self.disconnect("body_entered", self, "on_body_entered")
		self.visible = false
		$CollisionShape2D.disabled = true
		$AudioStreamPlayer2D.play(0)
