extends "res://Scripts/Barrel.gd"

onready var countdownTimer = get_tree().get_root().get_node("World/CanvasLayer/CountdownClock")
onready var player = get_tree().get_root().get_node("World/Player")
export var countdownSeconds = 90

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
func takeDamage(dmg):
	health -= dmg
	player.trauma = 120
	audioPlayer.stream = load("res://Audio/temp_wood.wav")
	audioPlayer.volume_db = Global.masterSound
	audioPlayer.play()
	if health <= 0 && !destroyed:
		destroy()

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
	countdownTimer.seconds = countdownSeconds
	countdownTimer.start()
	emit_signal("destroyed")
	countdownTimer.waitToShake(5)

func _on_audioStreamPlayer2D_finished():
	queue_free()
