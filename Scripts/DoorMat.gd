extends Node2D

enum PALETTETYPE { lab,acid,core }
export(PALETTETYPE) var paletteType = PALETTETYPE.lab

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	if paletteType == PALETTETYPE.lab:
		$sprite.texture = load("res://Sprites/DOORMAT_TILE.png")
	if paletteType == PALETTETYPE.acid:
		$sprite.texture = load("res://Sprites/ACIDDOORMAT_TILE.png")
	if paletteType == PALETTETYPE.core:
		$sprite.texture = load("res://Sprites/DOORMAT_TILE.png")