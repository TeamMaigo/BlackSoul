extends StaticBody2D

export var health = 1
var destroyed = false

onready var shatterPos = position #Might be used later
var shatterRot = 0
var shatterSpeed = 0

func _ready():
	pass

func shatterParams(pos, rot, speed):
	shatterPos = pos
	shatterRot = rot
	shatterSpeed = speed


func takeDamage(dmg):
	health -= dmg
	if health <= 0:
		$sprite.hide()
		$collisionShape2D.disabled = true
		$particles2D.emitting = true
		$particles2D.rotation = shatterRot
		
		$audioStreamPlayer.stream = load("res://Audio/glassBreak.ogg")
		$audioStreamPlayer.volume_db = Global.masterSound
		$audioStreamPlayer.play()
		destroyed = true

func _process(delta):
	if destroyed:
		if $particles2D.emitting == false:
			queue_free()
