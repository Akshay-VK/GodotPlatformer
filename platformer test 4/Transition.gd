extends CanvasLayer

onready var animation:= $AnimationPlayer

signal transition_completed

func play_exit_transition():
	animation.play("ExitLevel")
func play_enter_transition():
	animation.play("EnterLevel")


func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("transition_completed")
