extends KinematicBody2D

var direction = Vector2.RIGHT
var velocity = Vector2.ZERO

onready var ledge_r=$ledge_check_r
onready var ledge_l=$ledge_check_l

onready var sprite = $AnimatedSprite

func _physics_process(delta):
	
	if is_on_wall() or not ledge_r.is_colliding() or not ledge_l.is_colliding():
		direction*=-1
	sprite.flip_h=direction.x>0
	velocity=direction*25
	move_and_slide(velocity,Vector2.UP)
