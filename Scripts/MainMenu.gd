extends Control


func _ready():
	randomize()


func _on_New_Game_pressed():
	Global.destroyedObjects.clear()
	Global.unlockedThings.clear()
	get_tree().change_scene("res://Scenes/World.tscn")

func _on_Exit_pressed():
	get_tree().quit()


func _on_Options_pressed():
	$optionsPopup.show()
	$MarginContainer.hide()


func _on_Back_pressed():
	$optionsPopup.hide()
	$Credits.hide()
	$"Load Games".hide()
	$MarginContainer.show()


func _on_Credits_pressed():
	$Credits.show()
	$MarginContainer.hide()


func _on_Load_Game_pressed(number):
	Global.load_game(number)


func _on_Load_Games_pressed():
	$"Load Games".show()
	$MarginContainer.hide()
