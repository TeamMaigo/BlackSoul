extends StaticBody2D

export (int) var health = 2
onready var audioPlayer = $AudioStreamPlayer
var destroyed = false

func _ready():
	if Global.currentScene+name in Global.destroyedObjects:
		queue_free()

func _process(delta):
	if health <= 0 && !destroyed:
		Global.destroyedObjects.append(Global.currentScene+name)
		destroyed = true
		audioPlayer.stream = load("res://Audio/temp_wood.wav")
		audioPlayer.volume_db = Global.masterSound
		audioPlayer.play()
		$Sprite.hide()
		$CollisionShape2D.disabled = true

func takeDamage(dmg):
	health -= dmg

func _on_audioStreamPlayer_finished():
	queue_free()
