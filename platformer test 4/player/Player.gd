extends KinematicBody2D
class_name Player

enum {MOVE, CLIMB}

var velocity = Vector2.ZERO
var state = MOVE

export(Resource) var moveData=preload("res://player/DefaultPlayerMovementData.tres") as PlayerMovementData

var double_jump=moveData.DOUBLE_JUMP_COUNT
var buffered_jump=false
var coyote_jump=false
var jumpable=true

onready var animspr: = $AnimatedSprite
onready var ladderCheck: = $LadderCheck
onready var jumpBufferTimer: = $JumpBufferTimer
onready var coyoteJumpTimer: = $CoyoteJumpTimer
onready var remoteTransform2D: = $RemoteTransform2D


func _physics_process(delta):
	
	var input = Vector2.ZERO
	input.x=Input.get_axis("ui_left","ui_right")
	input.y=Input.get_axis("ui_up","ui_down")
	match state:
		MOVE:move_state(input,delta)
		CLIMB:climb_state(input)
	
func move_state(input,delta):
	if is_on_ladder() and Input.is_action_just_pressed("ui_up"):
		state=CLIMB
	
	apply_g(delta)
	if not hor_move(input):
		apply_friction(delta)
		animspr.animation="idle"
	else:
		animspr.animation="run"
		apply_acc(input.x,delta)
		animspr.flip_h=input.x>0
		
	if is_on_floor():
		reset_double_jump()
	else:
		animspr.animation="jump"
	
	if can_jump():
		input_jump()
	else:
		input_jump_release()
		input_double_jump()
		fast_fall(delta)
		buffer_jump()

	var was_in_air = not is_on_floor()
	var was_on_floor = is_on_floor()
	velocity = move_and_slide(velocity,Vector2.UP)
	var landed = is_on_floor() and was_in_air
	if landed:
		animspr.animation="run"
		animspr.frame=1
		
	var just_left_ground = not is_on_floor() and was_on_floor
	if just_left_ground and velocity.y >= 0:
		coyote_jump=true
		coyoteJumpTimer.start()
func climb_state(input):
	if not is_on_ladder():
		state=MOVE
	if input.length() != 0:
		animspr.animation="run"
	else:
		animspr.animation="idle"
	velocity=input*moveData.CLIMB_SPEED
	velocity=move_and_slide(velocity,Vector2.UP)

func player_die():
	SoundPlayer.play_sound(SoundPlayer.HURT)
	queue_free()
	Events.emit_signal("player_died")
func connect_cam(cam):
	var cam_path = cam.get_path()
	remoteTransform2D.remote_path=cam_path
	

func hor_move(input):
	return input.x!=0
func input_jump_release():
	if Input.is_action_just_released("ui_up") and velocity.y<moveData.JUMP_RELEASE_FORCE:
			velocity.y=moveData.JUMP_RELEASE_FORCE
func input_double_jump():
	if Input.is_action_just_pressed("ui_up") and double_jump > 0:
		velocity.y=moveData.JUMP_FORCE
		double_jump-=1
		SoundPlayer.play_sound(SoundPlayer.JUMP)
func buffer_jump():
	if Input.is_action_just_pressed("ui_up"):
		buffered_jump=true
		jumpBufferTimer.start()
func fast_fall(delta):
	if velocity.y>0:
		velocity.y+=moveData.ADDITIONAL_FAST_FALL_FORCE*delta
func can_jump():
	return is_on_floor() or coyote_jump
func input_jump():
	if not jumpable:return
	if Input.is_action_just_pressed("ui_up") or buffered_jump:
		velocity.y=moveData.JUMP_FORCE
		buffered_jump=false
		SoundPlayer.play_sound(SoundPlayer.JUMP)
func reset_double_jump():
	double_jump=moveData.DOUBLE_JUMP_COUNT
func is_on_ladder():
	if not ladderCheck.is_colliding():return false
	var collider = ladderCheck.get_collider()
	if not collider is Ladder: return false
	return true
func apply_g(delta):
	velocity.y+=moveData.GRAVITY*delta;
	velocity.y=min(velocity.y,300)
func apply_friction(delta):
	velocity.x=move_toward(velocity.x,0,moveData.FRICTION*delta)
func apply_acc(amt,delta):
	velocity.x=move_toward(velocity.x,moveData.MAX_SPEED*amt,moveData.ACC*delta)	
func _on_JumpBufferTimer_timeout():
	buffered_jump=false
func _on_CoyoteJumpTimer_timeout():
	coyote_jump=false
