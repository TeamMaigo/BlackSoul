extends Node2D

enum PALETTETYPE { lab,acid,core }
export(PALETTETYPE) var paletteType = PALETTETYPE.lab

func _ready():
	# Initialization here
	if paletteType == PALETTETYPE.lab:
		$Sprite.texture = load("res://Sprites/SAVE_POINT.png")
	if paletteType == PALETTETYPE.acid:
		$Sprite.texture = load("res://Sprites/SAVE_POINT_ACID.png")
	if paletteType == PALETTETYPE.core:
		$Sprite.texture = load("res://Sprites/SAVE_POINT.png")

func _on_Save_pressed(fileNumber):
	get_tree().paused = false
	Global.save_game(fileNumber)
	$CanvasLayer/Options.hide()
	$animationPlayer.play("Saving")


func _on_Quit_pressed():
	get_tree().paused = false
	$CanvasLayer/Options.hide()

func _on_area2D_body_entered(body):
	if body.is_in_group("Player"):
		body.setHealth(body.maxHealth)
		$CanvasLayer/Options.show()
		get_tree().paused = true

