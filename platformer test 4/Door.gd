extends Area2D

export(String, FILE,"*.tscn") var targetLevelPath=""

var player=null

func go_to_next_room():
	Transition.play_exit_transition()
	get_tree().paused=true
	yield(Transition,"transition_completed")
	Transition.play_enter_transition()
	get_tree().paused=false
	get_tree().change_scene(targetLevelPath)

func _process(delta):
	if not player:return
	if not player.is_on_floor():return
	if Input.is_action_just_pressed("ui_up"):
		if targetLevelPath.empty():return
		go_to_next_room()

func _on_Door_body_entered(body):
	if not body is Player:return
	body.jumpable=false
	player=body

func _on_Door_body_exited(body):
	if not body is Player:return
	body.jumpable=true
	player=null
