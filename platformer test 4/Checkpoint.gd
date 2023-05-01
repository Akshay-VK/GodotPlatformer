extends Area2D

onready var anim:=$AnimatedSprite

var active=true

func _on_Checkpoint_body_entered(body):
	if not body is Player:return
	if not active:return
	active=false
	anim.animation="checked"
	Events.emit_signal("hit_checkpoint",position)
