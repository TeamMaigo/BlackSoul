#TODO:
	#Don't use hardcoded FPS number

extends KinematicBody2D

# Required to pass editor info to collider child of object
export (int) var detect_radius  # size of the visibility circle
export (float) var fire_rate = 1.0  # delay time (sec) between bullets
export (float) var firstShotDelay = 0
export (PackedScene) var Bullet
export var bulletSpeed = 1
export var rotatingTurret = true
export var usesTargeting = true
export(String, "singleFire", "shotgun") var fireType
export var shotgunBulletAmount = 3
export var shotgunSpread = 20 # degree
export var bulletRotationSpeed = 1.0 # degrees per frame
export var bulletConeDegrees = 40.0 # Bullet cone of vision (this number is cone of vision degrees, and is 40 both ways)
export var bulletDecayTime = 10.0 # Seconds before bullet becomes linear
export var angleBulletUpdateDelay = 1.0 #seconds
export var trackingDelayTime = 0.25 # Sec till bullet starts tracking
export var rotationSpeed = 0.0
var spreadAngles = []

export var burst_fire = false
export (Array, float) var burst_pattern
enum PALETTETYPE { lab,acid,core }
export(PALETTETYPE) var paletteType = PALETTETYPE.lab
var burstSize
var burstPhase = 0

export var defeated = false
onready var timer = get_node("ShootTimer")
var target  # who are we shooting at?
var can_shoot = false
var vis_color = Color(.867, .91, .247, 0.1)


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	if paletteType == PALETTETYPE.lab:
		$Sprite.texture = load("res://Sprites/TURRET SPRITESHEET.png")
	if paletteType == PALETTETYPE.acid:
		$Sprite.texture = load("res://Sprites/ACIDTURRET_SPRITESHEET.png")
	if paletteType == PALETTETYPE.core:
		$Sprite.texture = load("res://Sprites/TURRET SPRITESHEET.png")

	if burst_fire && burst_pattern != null:
		burstSize = len(burst_pattern)
	else:
		burst_fire = false
		burstSize = 0
		
	set_physics_process(true)
	activate()
	$Sprite.global_rotation = 0
	$CollisionShape2D.global_rotation = 0
	if usesTargeting:
		var shape = CircleShape2D.new()
		shape.radius = detect_radius
		$Visibility/CollisionShape2D.shape = shape
	else:
		$Visibility.visible == false
	if firstShotDelay > 0:
		burstPhase = burstSize + 1 #Don't use the burst pattern yet
		can_shoot = false
		waitToShoot(firstShotDelay)
	else:
		can_shoot = true
	if shotgunBulletAmount%2 == 0:
		for i in shotgunBulletAmount/2:
			spreadAngles.append(i * shotgunSpread)
			spreadAngles.append((-i-1) * shotgunSpread)
	else: #Odd number of bullets
		for i in (shotgunBulletAmount-1)/2:
			spreadAngles.append((i+1)*shotgunSpread)
			spreadAngles.append((-i-1)*shotgunSpread)
		spreadAngles.append(0)
		


func _physics_process(delta):	
	if not defeated:
		#Shoot bullets at a consistent rate of fire
		if target:
			if rotatingTurret:
				faceTarget(target)
			if can_shoot:
				playFireAnimation()
				updateFacing()
				$audioStreamPlayer.stream = load("res://Audio/NewGunBlap.wav")
				$audioStreamPlayer.volume_db = Global.masterSound
				$audioStreamPlayer.play()
				if fireType == "singleFire" or null:
					shootBulletAtTarget(target.position)
				if fireType == "shotgun":
					shootShotgunAtTarget(target.position)
		elif not usesTargeting:
			if can_shoot:
				$audioStreamPlayer.stream = load("res://Audio/NewGunBlap.wav")
				$audioStreamPlayer.volume_db = Global.masterSound
				$audioStreamPlayer.play()
				playFireAnimation()
				if fireType == "singleFire" or null:
					shootBulletStraight()
				if fireType == "shotgun":
					shootShotgunStraight()
		else:
			pass
		rotation += rotationSpeed/60
	$Sprite.global_rotation = 0
	$CollisionShape2D.global_rotation = 0

func playFireAnimation():
	if global_rotation > 3*PI/4 or global_rotation < -3*PI/4:
		$animationPlayer.play("fireRight")
	elif global_rotation < 3*PI/4 and global_rotation > PI/4:
		$animationPlayer.play("fireDown")
	elif global_rotation < PI/4 and global_rotation > -PI/4:
		$animationPlayer.play("fireLeft")
	else:
		$animationPlayer.play("fireUp")

func updateFacing():
	if global_rotation > 3*PI/4 or global_rotation < -3*PI/4:
		$Sprite.frame = 14
	elif global_rotation < 3*PI/4 and global_rotation > PI/4:
		$Sprite.frame = 34
	elif global_rotation < PI/4 and global_rotation > -PI/4:
		$Sprite.frame = 4
	else:
		$Sprite.frame = 24

func faceTarget(target):
	rotation = (target.position - position).angle()

func _on_Visibility_body_entered(body):
	# connect this to the "body_entered" signal
	if target:
		return
	if usesTargeting && body.is_in_group("team_Player"):
		target = body

func _on_Visibility_body_exited(body):
	# connect this to the "body_exited" signal
	if body == target:
		target = null

func shootBulletAtTarget(pos):
	#Shoots a bullet at the target position with some random variance
	var b = Bullet.instance()
	var a = (pos - global_position).angle()
	b.setTarget(target)
	b.start(position, a + rand_range(-0.05, 0.05), bulletSpeed)
	setBulletProperties(b)
	get_parent().add_child(b)
	can_shoot = false
	waitToShoot(fire_rate)

func shootShotgunAtTarget(pos):
	#Shoots a spray of bullets at the target position with some random variance
	for i in spreadAngles:
		var b = Bullet.instance()
		var a = (pos - global_position).angle()
		var dir = a + rand_range(-0.05, 0.05)
		var startPos = position + Vector2(bulletSpeed, 0).rotated(dir).normalized()
		b.start(startPos, a + deg2rad(i), bulletSpeed)
		setBulletProperties(b)
		get_parent().add_child(b)
	can_shoot = false
	waitToShoot(fire_rate)

func shootBulletStraight():
	#Shoots a bullet in the direction it's facing
	var b = Bullet.instance()
	b.start(position, global_rotation, bulletSpeed)
	setBulletProperties(b)
	get_parent().add_child(b)
	can_shoot = false
	waitToShoot(fire_rate)

func shootShotgunStraight():
	for i in spreadAngles:
		var b = Bullet.instance()
		b.start(position, global_rotation + deg2rad(i), bulletSpeed)
		setBulletProperties(b)
		get_parent().add_child(b)
	can_shoot = false
	waitToShoot(fire_rate)

func _draw():
	# display the visibility area
	if usesTargeting:
		draw_circle(Vector2(), detect_radius, vis_color)


func waitToShoot(sec):
	if burst_fire:
		if burstPhase < burstSize:
			sec = burst_pattern[burstPhase]
			burstPhase += 1
		else:
			burstPhase = 0
			
	timer.set_wait_time(sec) # Set Timer's delay to "sec" seconds
	timer.start() # Start the Timer counting down
	yield(timer, "timeout") # Wait for the timer to wind down
	can_shoot = true

func setBulletProperties(b):
	b.rotationSpeed = bulletRotationSpeed
	b.maxRotationDiff =  bulletConeDegrees
	b.bulletDecayTime =  bulletDecayTime # Seconds before bullet becomes linear
	b.angleBulletUpdateDelay = angleBulletUpdateDelay
	b.trackingDelayTime = trackingDelayTime

func activate():
	defeated = false
	$Sprite.self_modulate = Color(1,1,1)
	if global_rotation > 3*PI/4 or global_rotation < -3*PI/4:
		$animationPlayer.play("leftStartup")
	elif global_rotation < 3*PI/4 and global_rotation > PI/4:
		$animationPlayer.play("downStartup")
	elif global_rotation < PI/4 and global_rotation > -PI/4:
		$animationPlayer.play("rightStartup")
	else:
		$animationPlayer.play("upStartup")
	
func deactivate():
	defeated = true
	if global_rotation > 3*PI/4 or global_rotation < -3*PI/4:
		$animationPlayer.play("leftDeactivate")
	elif global_rotation < 3*PI/4 and global_rotation > PI/4:
		$animationPlayer.play("downDeactivate")
	elif global_rotation < PI/4 and global_rotation > -PI/4:
		$animationPlayer.play("rightDeactivate")
	else:
		$animationPlayer.play("upDeactivate")

func _on_animationPlayer_animation_finished(anim_name):
	if anim_name in ["leftDeactivate", "rightDeactivate", "downDeactivate", "upDeactivate"]:
		$Sprite.self_modulate = Color(1,0,0)
