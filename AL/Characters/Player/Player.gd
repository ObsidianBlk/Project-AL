extends KinematicBody2D

export var speed = 65
#export var accel_rate = 2.5
#export var decel_rate = 0.8
export var jump_strength_multiplier = 0.35
export(float, 0.25, 1.0) var dash_btn_delay = 1.0
export(float, 0.3, 1.0) var dash_time = 0.3

enum STATE{Idle, Running, Crouching, Jumping, Falling, Climbing, Clinging, Ball}
var state = STATE.Idle
var velocity = Vector2()
var jump_released = true

var facing = Vector2(1,0)
var on_ladder = false #NOTE: This is only changed by an area trigger :)


var ctrl = {
	left={down=false, timestamp=0},
	right={down=false, timestamp=0},
	crouch={down=false, timestamp=0},
	jump={down=false, timestamp=0},
	climb={down=false, timestamp=0}
}

var currentAudio = null

var invincible = false
var invincible_timer = 0
var dmg_timer = 0

var dash_check_timestamp = 0
var dash_check_direction = 0
var dash_timer = 0
var dashed = 0

var cling_delay = 0

var revive_delay = 0
var next_level = ""


func playSFX(sfx):
	var nsfx = get_node("A_" + sfx)
	if nsfx != null:
		if currentAudio != nsfx:
			if currentAudio != null:
				currentAudio.stop()
			currentAudio = nsfx
			currentAudio.play(0)
		elif not currentAudio.is_playing():
			currentAudio.play(0)


func check_dash(dir, btn_timestamp):
	if dmg_timer > 0:
		return
	if dash_check_direction == 0 or dash_check_direction == dir:
		if dash_check_timestamp > 0 and dash_check_timestamp < btn_timestamp:
			if OS.get_ticks_msec() - dash_check_timestamp <= (dash_btn_delay*300):
				set_invincible(true)
				dash_timer = dash_time
				$Dash_Particles.emitting = true
			dash_check_timestamp = 0
			dash_check_direction = 0
		else:
			dash_check_timestamp = OS.get_ticks_msec()
			dash_check_direction = dir
	else:
		dash_check_direction = 0
		dash_check_timestamp = 0


func flip(dir):
	if $Spr_Character.flip_h and dir == 1:
		$Spr_Character.flip_h = false
		$Dash_Particles.transform.rotated(180)
		facing = Vector2(1,0)
	elif not $Spr_Character.flip_h and dir == -1:
		$Spr_Character.flip_h = true
		$Dash_Particles.transform.rotated(0)
		facing = Vector2(-1,0)


func idle():
	if player.life_force <= 0:
		return
		
	velocity.x = 0
	state = STATE.Idle
	$AnimationPlayer.play("Idle")

func run(dir, state_change_only=false):
	if dmg_timer > 0 or player.life_force <= 0:
		return
	if state != STATE.Running:
		state = STATE.Running
		$AnimationPlayer.play("Run")
	flip(dir)
	if not state_change_only:
		move(dir)

func move(dir, delta = 0):
	if dmg_timer > 0 or player.life_force <= 0:
		return
	flip(dir)
	if state == STATE.Running or state == STATE.Climbing or state == STATE.Clinging or state == STATE.Ball:
		if dash_timer > 0:
			velocity.x = dir*speed*3
		else:
			velocity.x = dir*speed
	elif state == STATE.Jumping or state == STATE.Falling:
		if state == STATE.Jumping and dash_timer > 0:
			velocity.y = 0
			velocity.x = dir*speed*3
		else:
			velocity.x = clamp(velocity.x + ((dir*speed*2)*delta), -speed, speed)

func climb(dir):
	if dmg_timer > 0 or player.life_force <= 0:
		return
	if on_ladder:
		state = STATE.Climbing
		if dir == 0:
			velocity.y = 0
			if $AnimationPlayer.current_animation == "Climb":
				$AnimationPlayer.stop()
		else:
			velocity.y = dir*speed*0.5
			if $AnimationPlayer.current_animation == "Climb":
				if not $AnimationPlayer.is_playing():
					$AnimationPlayer.play()
			else:
				$AnimationPlayer.play("Climb")

func cling():
	if dmg_timer > 0 or player.life_force <= 0:
		return
	state = STATE.Clinging
	$AnimationPlayer.play("Wall Grip")

func crouch():
	if dmg_timer > 0 or player.life_force <= 0:
		return
	state = STATE.Crouching
	velocity.x = 0
	$AnimationPlayer.play("Crouch")

func jump(high_jump=false):
	if dmg_timer > 0 or player.life_force <= 0:
		return
	if jump_released:
		jump_released = false
		state = STATE.Jumping
		if high_jump:
			playSFX("Jump_High")
			velocity.y = -(ENV.GRAVITY*jump_strength_multiplier*1.5)
		else:
			playSFX("Jump")
			velocity.y = -(ENV.GRAVITY*jump_strength_multiplier)
		$AnimationPlayer.play("Jump")


func ball(enable):
	if dmg_timer > 0 or player.life_force <= 0:
		return
		
	if enable == true and state != STATE.Ball:
		state = STATE.Ball
		$AnimationPlayer.play("To Ball")
	elif enable == false and state == STATE.Ball:
		if $Ball_Ceiling_Checker.is_colliding():
			var colName = $Ball_Ceiling_Checker.get_collider().get_name()
			if not (colName.begins_with("Trigger_") or colName.begins_with("Coin") or colName.begins_with("Special")):
			#if not $Ball_Ceiling_Checker.get_collider().get_name().begins_with("Trigger_"):
				return;
		$AnimationPlayer.play_backwards("To Ball")
		$AnimationPlayer.connect("animation_finished", self, "on_end_ball")

func on_end_ball(val):
	$AnimationPlayer.disconnect("animation_finished", self, "on_end_ball")
	idle()

func fall():
	state = STATE.Falling
	$AnimationPlayer.play("Land")


func dmg_and_throw(dmg_val, vdir):
	if player.life_force <= 0:
		return
		
	player.damage(dmg_val)
	if player.life_force <= 0:
		$AnimationPlayer.play("Death")
		$AnimationPlayer.connect("animation_finished", self, "on_dead")
	else:
		dmg_timer = 1.0
		$AnimationPlayer.play("Damaged")
		invincible = true
		invincible_timer = 2.0
		velocity = vdir.normalized()*speed*0.25
	playSFX("Hit")

func on_dead(val):
	$AnimationPlayer.disconnect("animation_finished", self, "on_dead")
	revive_delay = 2.0

func set_invincible(enable):
	if invincible_timer <= 0 and dmg_timer <= 0:
		if enable == true:
			invincible = true
			$Spr_Character.modulate.a = 0.5
		else:
			invincible = false
			$Spr_Character.modulate.a = 1.0

func update_idle():
	if state == STATE.Idle:
		if $AnimationPlayer.is_playing() == false:
			var rnd = floor(rand_range(0, 100))
			if rnd >= 0 and rnd < 50:
				$AnimationPlayer.play("Idle")
			elif rnd >= 50 and rnd < 75:
				$AnimationPlayer.play("Idle A1")
			else:
				$AnimationPlayer.play("Idle A2")

func _ready():
	set_process_unhandled_input(true)
	#set_process_input(true)
	pass


func store_event_state(event, actionName, ctrlName):
	if event.is_action_pressed(actionName):
		ctrl[ctrlName].down = true
		ctrl[ctrlName].timestamp = OS.get_ticks_msec()
	elif event.is_action_released(actionName):
		ctrl[ctrlName].down = false
		ctrl[ctrlName].timestamp = OS.get_ticks_msec()

func _unhandled_input(event):
	store_event_state(event, "player_left", "left")
	store_event_state(event, "player_right", "right")
	store_event_state(event, "player_jump", "jump")
	store_event_state(event, "player_crouch", "crouch")
	store_event_state(event, "player_climb", "climb")
	if ctrl.jump.down == false:
		jump_released = true


func process_ctrls(delta):
	match state:
		STATE.Idle:
			if (ctrl.left.down or ctrl.right.down) and ctrl.left.down != ctrl.right.down:
				if ctrl.left.down:
					check_dash(-1, ctrl.left.timestamp)
					run(-1)
				elif ctrl.right.down:
					check_dash(1, ctrl.right.timestamp)
					run(1)
			elif ctrl.crouch.down:
				if on_ladder:
					climb(1)
				else:
					crouch()
			elif ctrl.climb.down:
				if on_ladder:
					climb(-1)
				elif next_level != "":
					global.level_change(next_level)
					next_level = ""
			elif ctrl.jump.down:
				jump()
				
		STATE.Crouching:
			if not ctrl.crouch.down:
				idle()
			else:
				if OS.get_ticks_msec() - ctrl.crouch.timestamp > 1000:
					ball(true)
				if ctrl.jump.down:
					jump(true)
			if ctrl.left.down:
				flip(-1)
			elif ctrl.right.down:
				flip(1)
		STATE.Running:
			if dash_timer <= 0:
				if (ctrl.left.down or ctrl.right.down) and ctrl.left.down != ctrl.right.down:
					if ctrl.left.down:
						check_dash(-1, ctrl.left.timestamp)
						run(-1)
					elif ctrl.right.down:
						check_dash(1, ctrl.right.timestamp)
						run(1)
				else:
					idle()
				if ctrl.climb.down and next_level != "":
					global.level_change(next_level)
					next_level = ""
				if ctrl.jump.down:
					jump()
				if ctrl.crouch.down:
					if on_ladder:
						climb(1)
					else:
						crouch()
		STATE.Jumping, STATE.Falling:
			if dash_timer <= 0:
				if (ctrl.left.down or ctrl.right.down) and ctrl.left.down != ctrl.right.down:
					if ctrl.left.down:
						if state == STATE.Jumping:
							check_dash(-1, ctrl.left.timestamp)
						move(-1, delta)
					elif ctrl.right.down:
						if state == STATE.Jumping:
							check_dash(1, ctrl.right.timestamp)
						move(1, delta)
		STATE.Climbing:
			if (ctrl.crouch.down or ctrl.climb.down) and ctrl.climb.down != ctrl.crouch.down:
				if ctrl.crouch.down:
					climb(1)
				else:
					climb(-1)
			else:
				climb(0)
			if (ctrl.left.down or ctrl.right.down) and ctrl.left.down != ctrl.right.down:
				if ctrl.left.down:
					check_dash(-1, ctrl.left.timestamp)
					move(-1)
				elif ctrl.right.down:
					check_dash(1, ctrl.right.timestamp)
					move(1)
			if ctrl.jump.down:
				jump()
		STATE.Clinging:
			if ctrl.left.down or ctrl.right.down:
				if ctrl.left.down and $Spr_Character.flip_h == true:
						move(-1)
				if ctrl.right.down and $Spr_Character.flip_h == false:
						move(1)
			if ctrl.jump.down and jump_released == true:
				if $Spr_Character.flip_h == false:
					move(-1) # Start moving in OPPOSITE Direction of where we're "gripping" the wall.
					jump(true) # Then JUMP!
					ctrl.right.down = false # This is a bold faced LIE!
				else:
					move(1)
					jump(true)
					print (velocity)
					ctrl.left.down = false
		STATE.Ball:
			if $AnimationPlayer.current_animation != "To Ball" and dash_timer <= 0:
				if (ctrl.left.down or ctrl.right.down) and ctrl.left.down != ctrl.right.down:
					if ctrl.left.down:
						if $AnimationPlayer.current_animation != "Roll":
							$AnimationPlayer.play("Roll")
						check_dash(-1, ctrl.left.timestamp)
						move(-1)
					elif ctrl.right.down:
						if $AnimationPlayer.current_animation != "Roll":
							$AnimationPlayer.play("Roll")
						check_dash(1, ctrl.right.timestamp)
						move(1)
				else:
					$AnimationPlayer.stop()
					move(0)
				if ctrl.climb.down:
					if next_level != "":
						global.level_change(next_level)
						next_level = ""
					else:
						ball(false)


func _process_revival(delta):
	revive_delay = max(revive_delay - delta, 0)
	if revive_delay <= 0:
		player.revive()
		self.position = player.checkpoint


func _physics_process(delta):
	if revive_delay > 0:
		_process_revival(delta)
		return

	process_ctrls(delta)
	if dashed > 0:
		dashed = max(dashed - delta, 0)
	if velocity.y < 0 and is_on_ceiling():
		velocity.y = 0
	
	if dash_timer <= 0:
		if not on_ladder and dmg_timer <= 0:
			if not is_on_floor():
				if state == STATE.Clinging:
					velocity.y = min(velocity.y + (ENV.GRAVITY*delta), ENV.MAX_GRAVITY*0.05)
				else:
					velocity.y = min(velocity.y + (ENV.GRAVITY*delta), ENV.MAX_GRAVITY)
			elif velocity.y > 0:
				velocity.y = 0
	else:
		dash_timer = max(dash_timer - delta, 0)
		if dash_timer <= 0:
			velocity.x = 0
			$Dash_Particles.emitting = false
			set_invincible(false)
	
	move_and_slide(velocity, ENV.UP, 12.0, 3, 0.8726639)
	
	if state == STATE.Climbing:
		velocity = Vector2(0,0)
		if not on_ladder or is_on_floor():
			idle()
	else:
		if is_on_wall():
			velocity.x = 0
			if dash_timer > 0:
				dash_timer = 0
				dashed = 0.5
				set_invincible(false)
				playSFX("Move_Collide")
			$Dash_Particles.emitting = false
		if state == STATE.Jumping or state == STATE.Falling:
			if on_ladder and state == STATE.Falling:
				velocity.y = 0
				idle()
			elif is_on_floor():
				playSFX("Move_Collide")
				if (ctrl.left.down or ctrl.right.down) and ctrl.left.down != ctrl.right.down:
					if ctrl.left.down:
						run(-1, true)
					else:
						run(1, true)
				else:
					idle()
			elif is_on_wall():
				cling()
		elif state == STATE.Clinging:
			if is_on_floor():
				idle()
			elif not is_on_wall():
				fall()
		elif on_ladder:
			velocity.y = 0
		if velocity.y > ENV.GRAVITY*0.1 and state != STATE.Falling and state != STATE.Clinging and state != STATE.Ball:
			fall()
	
	if invincible_timer > 0:
		invincible_timer = max(invincible_timer - delta, 0)
		if invincible_timer <= 0:
			set_invincible(false)
	if dmg_timer > 0:
		dmg_timer = max(dmg_timer - delta, 0)
		if dmg_timer <= 0:
			$AnimationPlayer.stop()
			$Spr_Character.modulate.a = 0.5 # We should still have some invincibility!
	update_idle()





