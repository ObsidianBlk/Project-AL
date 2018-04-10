extends KinematicBody2D

export var speed = 65
export var accel_rate = 2.5
export var decel_rate = 0.8
export var jump_strength_multiplier = 0.45

enum STATE{Idle, Running, Crouching, Jumping, Falling, Climbing}
var state = STATE.Idle
var velocity = Vector2()

var ctrl = {
	left={down=false, timestamp=0},
	right={down=false, timestamp=0},
	crouch={down=false, timestamp=0},
	jump={down=false, timestamp=0}
}

var dash_check_timestamp = 0
var dash_check_direction = 0
var dash_timer = 0


func check_dash(dir, btn_timestamp):
	if dash_check_direction == 0 or dash_check_direction == dir:
		if dash_check_timestamp > 0 and dash_check_timestamp < btn_timestamp:
			if OS.get_ticks_msec() - dash_check_timestamp <= 300:
				dash_timer = 0.3
			dash_check_timestamp = 0
			dash_check_direction = 0
		else:
			dash_check_timestamp = OS.get_ticks_msec()
			dash_check_direction = dir


func flip(dir):
	if $Spr_Character.flip_h and dir == 1:
		$Spr_Character.flip_h = false
	elif not $Spr_Character.flip_h and dir == -1:
		$Spr_Character.flip_h = true


func idle():
	velocity.x = 0
	state = STATE.Idle
	$AnimationPlayer.play("Idle")

func run(dir, state_change_only=false):
	if state != STATE.Running:
		state = STATE.Running
		$AnimationPlayer.play("Run")
	flip(dir)
	if not state_change_only:
		move(dir)

func move(dir, delta = 0):
	flip(dir)
	if state == STATE.Running:
		if dash_timer > 0:
			velocity.x = dir*speed*2
		else:
			velocity.x = dir*speed
	elif state == STATE.Jumping or state == STATE.Falling:
		if state == STATE.Jumping and dash_timer > 0:
			velocity.y = 0
			velocity.x = dir*speed*2
		else:
			velocity.x = clamp(velocity.x + ((dir*speed*2)*delta), -speed, speed)

func crouch():
	state = STATE.Crouching
	velocity.x = 0
	$AnimationPlayer.play("Crouch")

func jump():
	state = STATE.Jumping
	velocity.y = -(ENV.GRAVITY*jump_strength_multiplier)
	$AnimationPlayer.play("Jump")


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
				crouch()
			elif ctrl.jump.down:
				jump()
				
		STATE.Crouching:
			if not ctrl.crouch.down:
				idle()
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
				if ctrl.jump.down:
					jump()
				if ctrl.crouch.down:
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


func _physics_process(delta):
	process_ctrls(delta)
	if velocity.y < 0 and is_on_ceiling():
		velocity.y = 0
	
	if dash_timer <= 0:
		if not is_on_floor():
			velocity.y = min(velocity.y + (ENV.GRAVITY*delta), ENV.MAX_GRAVITY)
		elif velocity.y > 0:
			velocity.y = 0
	else:
		dash_timer = max(dash_timer - delta, 0)
		if dash_timer <= 0:
			velocity.x = 0
	
	move_and_slide(velocity, ENV.UP, 12.0, 3, 0.8726639)
		
	if is_on_wall():
		# TODO: If "Wall Jump" unlocked, test if we're in a landing state and set state accordingly.
		velocity.x = 0
		dash_timer = 0
	if is_on_floor():
		if state == STATE.Jumping or state == STATE.Falling:
			if (ctrl.left.down or ctrl.right.down) and ctrl.left.down != ctrl.right.down:
				if ctrl.left.down:
					run(-1, true)
				else:
					run(1, true)
			else:
				idle()
	elif velocity.y > ENV.GRAVITY*0.15:
		state = STATE.Falling
		$AnimationPlayer.play("Land")





