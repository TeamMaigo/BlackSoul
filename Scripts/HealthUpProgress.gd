extends Control

export (PackedScene) var health_icon

func _ready():
	pass

func setValue(icon):
	if icon == 0:
		$sprite.texture = load("res://Sprites/LIFE POINTS SILHOUETTE.png")
	if icon == 1:
		pass
	if icon == 2:
		$sprite.texture = load("res://Sprites/LIFE POINTS ACTIVE.png")