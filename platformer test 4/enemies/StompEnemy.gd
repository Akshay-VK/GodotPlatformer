extends Node2D

enum {HOVER,FALL,LAND,RISE}

var state=HOVER
onready var startPos=global_position
onready var timer:=$Timer
onready var raycast:=$RayCast2D
onready var animation:=$AnimatedSprite
onready var particles:=$Particles2D
func _ready():
	particles.emitting=false

func _physics_process(delta):
	match state:
		HOVER:hover_state()
		FALL:fall_state(delta)
		LAND:land_state()
		RISE:rise_state(delta)
func hover_state():
	state=FALL
func fall_state(delta):
	animation.play("falling")
	position.y+=150*delta
	if raycast.is_colliding():
		var collision_point=raycast.get_collision_point()
		position.y=collision_point.y
		state=LAND
		timer.start(1.0)
		particles.emitting=true
func land_state():
	if timer.time_left==0:
		state=RISE
func rise_state(delta):
	animation.play("rising")
	position.y=move_toward(position.y,startPos.y,delta*10)
	if position.y==startPos.y:state=HOVER
	
