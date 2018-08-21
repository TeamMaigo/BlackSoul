extends "res://Scripts/Barrel.gd"

onready var countdownTimer = get_tree().get_root().get_node("World/CanvasLayer/CountdownClock")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func destroy():
	if not respawnable:
		Global.destroyedObjects.append(Global.currentScene+name)
	destroyed = true
	audioPlayer.stream = load("res://Audio/temp_wood.wav")
	audioPlayer.volume_db = Global.masterSound
	audioPlayer.play()
	$sprite.hide()
	$collisionShape2D.disabled = true
	countdownTimer.paused = false
	countdownTimer.show()
	get_node("../MeltingText").show()
	emit_signal("destroyed")

func _on_audioStreamPlayer2D_finished():
	queue_free()
