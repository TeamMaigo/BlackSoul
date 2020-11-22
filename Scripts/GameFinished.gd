extends Node2D

func _ready():
	$ScenePlayer.play("Ending Animation")

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Back_pressed():
	get_tree().change_scene("res://Scenes/MainMenu.tscn")
