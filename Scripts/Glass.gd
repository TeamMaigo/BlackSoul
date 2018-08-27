extends StaticBody2D

export var health = 1
var destroyed = false

export var respawnable = true

onready var shatterPos = position #Might be used later
var shatterRot = 0
var shatterSpeed = 0

enum PALETTETYPE { lab,acid,core }
export(PALETTETYPE) var paletteType = PALETTETYPE.lab

func _ready():
	if paletteType == PALETTETYPE.lab:
		$sprite.texture = load("res://Sprites/BREAKABLE_BLUE.png")
		$particles2D.texture = load("res://Sprites/BREAKABLE_SHARD_BLUE.png")
	if paletteType == PALETTETYPE.acid:
		$sprite.texture = load("res://Sprites/BREAKABLE_GREEN.png")
		$particles2D.texture = load("res://Sprites/BREAKABLE_SHARD_GREEN.png")
	if paletteType == PALETTETYPE.core:
		$sprite.texture = load("res://Sprites/BREAKABLE_BLUE.png")
		$particles2D.texture = load("res://Sprites/BREAKABLE_SHARD_BLUE.png")

func shatterParams(pos, rot, speed):
	shatterPos = pos
	shatterRot = rot
	shatterSpeed = speed


func takeDamage(dmg):
	health -= dmg
	if health <= 0:
		$sprite.hide()
		$collisionShape2D.disabled = true
		$particles2D.process_material.initial_velocity = clamp(100 + 8.5*(shatterSpeed - 8), 100, 200)
		#print($particles2D.process_material.initial_velocity)
		$particles2D.emitting = true
		$particles2D.rotation = shatterRot
		
		$audioStreamPlayer.stream = load("res://Audio/glassBreak.ogg")
		$audioStreamPlayer.volume_db = Global.masterSound
		$audioStreamPlayer.play()
		$animationPlayer.play("particleFadeout")
		destroyed = true

#func _process(delta):

func _on_animationPlayer_animation_finished(anim_name):
	if anim_name == "particleFadeout":
		queue_free()


func _on_audioStreamPlayer_finished():
	pass # replace with function body
