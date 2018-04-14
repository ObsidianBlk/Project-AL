extends Node

var life_force = 100
var checkpoint = null
var last_checkpoint_id = 0
var current_score = 0

func reset():
	life_force = 100
	checkpoint = null
	last_checkpoint_id = 0

func revive():
	life_force = 100

func score(val):
	if val > 0:
		current_score += val

func damage(dmg):
	if dmg > 0:
		life_force = max(life_force - dmg, 0)

func set_checkpoint(id, pos):
	if id > last_checkpoint_id:
		last_checkpoint_id = id
		checkpoint = pos
