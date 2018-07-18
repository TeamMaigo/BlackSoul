extends StaticBody2D

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func applyEffect(player):
	player.health = player.maxHealth
	player.get_node("PlayerAudio").stream = load("res://Audio/RecievedChat.ogg")
	player.get_node("PlayerAudio").playing = true
	player.updateHealthBar()
	queue_free()
