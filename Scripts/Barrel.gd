extends StaticBody2D

export (int) var health = 2
onready var audioPlayer = $audioStreamPlayer
var destroyed = false
export var respawnable = true

signal destroyed

func _ready():
	if Global.currentScene+name in Global.destroyedObjects:
		queue_free()

func _process(delta):
	pass

func takeDamage(dmg):
	health -= dmg
	if health <= 0 && !destroyed:
		destroy()

func destroy():
	if not respawnable:
		Global.destroyedObjects.append(Global.currentScene+name)
	destroyed = true
	audioPlayer.stream = load("res://Audio/temp_wood.wav")
	audioPlayer.volume_db = Global.masterSound
	audioPlayer.play()
	$Sprite.hide()
	$CollisionShape2D.disabled = true
	emit_signal("destroyed")


func _on_audioStreamPlayer_finished():
	queue_free()
