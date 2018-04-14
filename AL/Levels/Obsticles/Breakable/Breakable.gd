extends Node2D

enum STATE{Normal, Cracked, Broken, Dead}
export(STATE) var state = STATE.Normal

var hit = null

func _ready():
	set_physics_process(true)
	if state == null:
		state = STATE.Normal

func _check_ray(ray):
	if ray.is_colliding():
		return _update_body(ray.get_collider())
	return false

func _physics_process(delta):
	if state == STATE.Dead:
		return # Don't care... we dead!
	if _check_ray($Body/Ray_Left) == false:
		if _check_ray($Body/Ray_Right) == false:
			hit = null

func _set_dead():
	$Norm_Bright.visible = false
	$Norm_Reg.visible = false
	$Cracked.visible = false
	$Broken.visible = false
	$Body/CollisionShape2D.disabled = true
	$Particles2D.emitting = true

func _update_body(body):
	if body.get_name() == "Player" and body.dashed > 0 and body.state == body.STATE.Ball: # the latter part is cheating
		if hit == null:
			hit = body
			if state == STATE.Normal:
				state = STATE.Cracked
				$AnimationPlayer.play("Cracked")
			elif state == STATE.Cracked:
				state = STATE.Broken
				$AnimationPlayer.play("Broken")
			elif state == STATE.Broken:
				state = STATE.Dead
				_set_dead()
		return true
	return false