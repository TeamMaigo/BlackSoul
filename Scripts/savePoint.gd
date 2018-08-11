extends Node2D

func _ready():
	pass

func _on_Save_pressed(fileNumber):
	get_tree().paused = false
	Global.save_game(fileNumber)
	$CanvasLayer/Options.hide()


func _on_Quit_pressed():
	get_tree().paused = false
	$CanvasLayer/Options.hide()

func _on_SavePoint_body_entered(body):
	if body.is_in_group("Player"):
		body.setHealth(body.maxHealth)
		$CanvasLayer/Options.show()
		get_tree().paused = true