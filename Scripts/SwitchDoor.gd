extends StaticBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var collisionL = self.collision_layer
export var enemiesLeftToKill = 0
export var active = true
enum PALETTETYPE { lab,acid,core }
export(PALETTETYPE) var paletteType = PALETTETYPE.lab


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	if paletteType == PALETTETYPE.lab:
		$Sprite.texture = load("res://Sprites/GATE_HORIZONTAL.png")
	if paletteType == PALETTETYPE.acid:
		$Sprite.texture = load("res://Sprites/GATEACID_HORIZONTAL.png")
	if paletteType == PALETTETYPE.core:
		$Sprite.texture = load("res://Sprites/GATE_HORIZONTAL.png")
	if active:
		_onActivate()
	else:
		_onDeactivate()

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
func _onActivate():
	$animationPlayer.play_backwards("deactivate")
	active = true
	collision_layer = collisionL

func _onDeactivate():
	$animationPlayer.play("deactivate")
	active = false

func enemyDeath():
	enemiesLeftToKill -= 1
	if enemiesLeftToKill == 0:
		queue_free()

func _on_animationPlayer_animation_finished(anim_name):
	if anim_name == "deactivate" and not active:
		collision_layer = 0