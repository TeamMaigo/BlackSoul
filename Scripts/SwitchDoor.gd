extends StaticBody2D

var collisionL = self.collision_layer
export var enemiesLeftToKill = 0
export var active = true
enum PALETTETYPE { lab,acid,core }
export(PALETTETYPE) var paletteType = PALETTETYPE.lab
export var relocks = false

func _ready():

	if Global.currentScene+name in Global.unlockedThings:
		_onDeactivate()
	if paletteType == PALETTETYPE.lab:
		$Sprite.texture = load("res://Sprites/GATE_HORIZONTAL.png")
	if paletteType == PALETTETYPE.acid:
		$Sprite.texture = load("res://Sprites/GATEACID_HORIZONTAL.png")
	if paletteType == PALETTETYPE.core:
		$Sprite.texture = load("res://Sprites/GATE_HORIZONTAL.png")
	if not active:
		_onDeactivate()
	else:
		collision_layer = collisionL

func _onActivate():
	$animationPlayer.play_backwards("deactivate")
	active = true
	collision_layer = collisionL
	$AudioStreamPlayer.stream = load("res://Audio/DoorOpen.wav")
	$AudioStreamPlayer.volume_db = Global.masterSound
	$AudioStreamPlayer.play()

func _onDeactivate():
	$animationPlayer.play("deactivate")
	active = false
	$AudioStreamPlayer.stream = load("res://Audio/DoorOpen.wav")
	$AudioStreamPlayer.volume_db = Global.masterSound
	$AudioStreamPlayer.play()
	if not relocks:
		Global.unlockedThings.append(Global.currentScene+name)

func enemyDeath():
	enemiesLeftToKill -= 1
	if enemiesLeftToKill == 0:
		_onDeactivate()

func _on_animationPlayer_animation_finished(anim_name):
	if anim_name == "deactivate" and not active:
		collision_layer = 0