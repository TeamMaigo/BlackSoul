extends KinematicBody2D

export (int) var health = 2
onready var audioPlayer = $audioStreamPlayer
var destroyed = false

func _ready():
	pass

func _process(delta):
	if health <= 0 && !destroyed:
		destroyed = true
		audioPlayer.stream = load("res://Audio/temp_wood.wav")
		audioPlayer.volume_db = Global.masterSound
		audioPlayer.play()
		$sprite.hide()
		$collisionShape2D.disabled = true

func takeDamage(dmg):
	health -= dmg

func _on_audioStreamPlayer_finished():
	queue_free()
