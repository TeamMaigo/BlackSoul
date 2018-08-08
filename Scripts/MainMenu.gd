extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_New_Game_pressed():
	Global.destroyedObjects.clear()
	get_tree().change_scene("res://Scenes/World.tscn")


func _on_Exit_pressed():
	get_tree().quit()


func _on_Options_pressed():
	$optionsPopup.show()
	$MarginContainer.hide()


func _on_Back_pressed():
	$optionsPopup.hide()
	$Credits.hide()
	$MarginContainer.show()


func _on_Credits_pressed():
	$Credits.show()
	$MarginContainer.hide()


func _on_Load_Game_pressed():
	Global.load_game()