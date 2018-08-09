extends Node2D

func _ready():
	pass

func takeDamage(damage):
	var player = get_tree().get_root().get_node("World/Player")
	player.setHealth(player.maxHealth)
	$CanvasLayer/Options.show()
	get_tree().paused = true
	

func _on_Save_pressed(fileNumber):
	get_tree().paused = false
	Global.save_game(fileNumber)
	$CanvasLayer/Options.hide()


func _on_Quit_pressed():
	get_tree().paused = false
	$CanvasLayer/Options.hide()