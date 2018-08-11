extends "res://Scripts/HealthPickup.gd"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func applyEffect(player):
	player.piecesOfHeart += 1
	emit_signal("collected")
	print("Found a piece of heart!")
	if player.piecesOfHeart == 3:
		player.piecesOfHeart = 0
		player.maxHealth += 1
		player.setHealth(player.maxHealth)
		print("Player hp went up to " + str(player.maxHealth))
	player.get_node("PlayerAudio").stream = load("res://Audio/RecievedChat.ogg")
	player.get_node("PlayerAudio").playing = true
	player.get_node("PlayerAudio").volume_db = Global.masterSound
	if not respawnable:
		Global.destroyedObjects.append(Global.currentScene+name)
	queue_free()