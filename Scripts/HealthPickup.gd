extends StaticBody2D

export var respawnable = true

func _ready():
	if Global.currentScene+name in Global.destroyedObjects:
		queue_free()

func applyEffect(player):
	player.health = player.maxHealth
	player.get_node("PlayerAudio").stream = load("res://Audio/RecievedChat.ogg")
	player.get_node("PlayerAudio").playing = true
	player.get_node("PlayerAudio").volume_db = Global.masterSound
	player.updateHealthBar()
	if not respawnable:
		Global.destroyedObjects.append(Global.currentScene+name)
	queue_free()