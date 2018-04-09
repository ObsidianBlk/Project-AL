extends KinematicBody2D

export var speed = 100

enum STATE{Idle, Running, Crouching, Jumping, Falling, Climbing}
var state = STATE.Idle
var velocity = Vector2()

var is_running = 0


func flip(dir):
	if $Spr_Character.flip_h and dir == 1:
		$Spr_Character.flip_h = false
	elif not $Spr_Character.flip_h and dir == -1:
		$Spr_Character.flip_h = true


func idle():
	print("Idle")
	velocity.x = 0
	state = STATE.Idle
	$AnimationPlayer.play("Idle")

func run(dir):
	print("Run")
	if state != STATE.Running:
		state = STATE.Running
		$AnimationPlayer.play("Run")
	flip(dir)
	velocity.x = dir*speed


func crouch():
	print("Crouch")
	state = STATE.Crouching
	velocity.x = 0
	$AnimationPlayer.play("Crouch")

func jump():
	print("Jump")
	state = STATE.Jumping
	velocity.y = -ENV.GRAVITY
	$AnimationPlayer.play("Jump")


func _ready():
	set_process_unhandled_input(true)
	#set_process_input(true)
	pass

func _unhandled_input(event):
	match state:
		STATE.Idle:
			is_running = 0
			if event.is_action_pressed("player_left"):
				run(-1)
				is_running = -1
			elif event.is_action_pressed("player_right"):
				run(1)
				is_running = 1
			elif event.is_action_pressed("player_crouch"):
				crouch()
			elif event.is_action_pressed("player_jump"):
				jump()
				
		STATE.Crouching:
			if not event.is_action_pressed("player_crouch"):
				idle()
			if event.is_action_pressed("player_left"):
				flip(-1)
			elif event.is_action_pressed("player_right"):
				flip(1)
		STATE.Running:
			if event.is_action_pressed("player_left"):
				run(-1)
				is_running = -1
			elif event.is_action_pressed("player_right"):
				run(1)
				is_running = 1
			elif event.is_action_released("player_left") or event.is_action_released("player_right"):
				idle()
				is_running = 0
			if event.is_action_pressed("player_jump"):
				jump()
			if event.is_action_pressed("player_crouch"):
				crouch()
		STATE.Jumping, STATE.Falling:
			if event.is_action_pressed("player_left"):
				is_running = -1
			elif event.is_action_pressed("player_right"):
				is_running = 1
			elif event.is_action_released("player_left") or event.is_action_released("player_right"):
				print("Releasing Run X")
				is_running = 0



func _physics_process(delta):
	if not is_on_floor():
		velocity.y = min(velocity.y + (ENV.GRAVITY*delta), ENV.MAX_GRAVITY)
	elif velocity.y > 0:
		velocity.y = 0
	
	move_and_slide(velocity, ENV.UP)
		
	if is_on_wall():
		# TODO: If "Wall Jump" unlocked, test if we're in a landing state and set state accordingly.
		velocity.x = 0
	if is_on_floor():
		if state == STATE.Falling:
			print(is_running)
			if is_running != 0:
				run(is_running)
			else:
				idle()
			#if velocity.x > 0:
			#	run(1)
			#elif velocity.x < 0:
			#	run(-1)
			#else:
			#	idle()
	elif velocity.y > ENV.GRAVITY*0.15:
		state = STATE.Falling
		$AnimationPlayer.play("Land")





