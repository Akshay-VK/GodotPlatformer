extends Node2D

const PlayerScene = preload("res://player/Player.tscn")

var player_spawn_location = Vector2.ZERO

onready var cam:=$Camera2D
onready var player:=$Player
onready var timer :=$Timer

func _ready():
	VisualServer.set_default_clear_color(Color.lightskyblue)
	player.connect_cam(cam)
	player_spawn_location=player.global_position
	Events.connect("player_died",self,"_on_player_died")
	Events.connect("hit_checkpoint",self,"_on_hit_checkpoint")
	
func _on_player_died():
	timer.start(2.0)
	yield(timer,"timeout")
	var player = PlayerScene.instance()
	player.position=player_spawn_location
	add_child(player)
	player.connect_cam(cam)
	pass
func _on_hit_checkpoint(pos):
	player_spawn_location=pos
