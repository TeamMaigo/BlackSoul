extends KinematicBody2D

var frame = 0
var direction = randi() % 4
var moveDir = Vector2(0,0)
export var hp = 1
export var MOTION_SPEED = 100
var canSeePlayer = false
export (int) var detect_radius = 300
var usesVision = true
var target
var degreesPerFrame = 4
onready var rotationSpeed = deg2rad(degreesPerFrame)
var velocity
export (PackedScene) var BulletType
export var bulletSpeed = 10
onready var timer = get_node("ShootTimer")
var can_shoot = false
export (float) var fire_rate = 1  # delay time (s) between bullets
var lastKnownPlayerPos
export(String, "singleFire", "shotgun") var fireType
export var shotgunBulletAmount = 3
export var shotgunSpread = 20 # degree
export var respawns = true
export var trackingDelayTime = 0.25 # Sec till bullet starts tracking
export var bulletOffset = 50
export var bulletRotationSpeed = 1.0 # degrees per frame
export var bulletConeDegrees = 40.0 # Bullet cone of vision (this number is cone of vision degrees, and is 40 both ways)
export var bulletDecayTime = 10.0 # Seconds before bullet becomes linear
export var angleBulletUpdateDelay = 1.0 #seconds
var spreadAngles = []
onready var AnimNode = $animationPlayer
var anim = "Idle"
var animNew = ""
var isFacingLeft
var transformed = false
var canMove = true

signal enemyDeath

func _ready():
	$Visibility.show()
	if Global.currentScene+name in Global.destroyedObjects:
		queue_free()
	var shape = CircleShape2D.new()
	shape.radius = detect_radius
	$Visibility/CollisionShape2D.shape = shape
	var shape1 = CircleShape2D.new() # Zone where enemy transforms
	shape1.radius = detect_radius + 50
	$threatRange/CollisionShape2D.shape = shape1
	set_physics_process(true)
	waitToShoot(fire_rate)
	if shotgunBulletAmount%2 == 0:
		for i in shotgunBulletAmount/2:
			spreadAngles.append(i * shotgunSpread)
			spreadAngles.append((-i-1) * shotgunSpread)
	else: #Odd number of bullets
		for i in (shotgunBulletAmount-1)/2:
			spreadAngles.append((i+1)*shotgunSpread)
			spreadAngles.append((-i-1)*shotgunSpread)
		spreadAngles.append(0)
	if randi()%2 == 0:
		isFacingLeft = true
	else:
		isFacingLeft = false

func _physics_process(delta):
	if target:
		canSeePlayer = checkForPlayer()
		if canSeePlayer:
			lastKnownPlayerPos = target.position
			if can_shoot:
				if isFacingLeft:
					anim = "leftShoot"
				else:
					anim = "rightShoot"

	else:
		if not transformed:
			if isFacingLeft:
				anim = "idleLeft"
			else:
				anim = "idleRight"
	movement_loop()
	if anim != animNew:
		animNew = anim
		AnimNode.play(anim)

func movement_loop():
	if lastKnownPlayerPos:
		moveDir = (lastKnownPlayerPos - position).normalized()
		var motion = moveDir.normalized() * MOTION_SPEED
		if (lastKnownPlayerPos - position).length() > 5:
			move_and_slide(motion)

func checkForPlayer():
	# Raycast to check if can see for player
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(position, target.position, [self], 7) # Hits environment, player, enemies
	if result:
		if result.collider.is_in_group("Player"): # Sees player and nothing inbetween
			if not result.collider.get_node("./").swappedRecently:
				return true
	return false # Failed to detect player

func shootBulletAtTarget(pos):
	#Shoots a bullet at the target position with some random variance
	var b = BulletType.instance()
	var a = (pos - global_position).angle()
	var dir = a + rand_range(-0.05, 0.05)
	var startPos = global_position + Vector2(bulletSpeed, 0).rotated(dir).normalized()*bulletOffset
	b.start(startPos, dir, bulletSpeed)
	setBulletProperties(b)
	get_parent().add_child(b)
	can_shoot = false
	waitToShoot(fire_rate)

func shootShotgunAtTarget(pos):
	#Shoots a spray of bullets at the target position with some random variance
	for i in spreadAngles:
		var b = BulletType.instance()
		var a = (pos - global_position).angle()
		var dir = a + rand_range(-0.05, 0.05)
		var startPos = position + Vector2(bulletSpeed, 0).rotated(dir).normalized()*bulletOffset
		b.start(startPos, a + deg2rad(i), bulletSpeed)
		setBulletProperties(b)
		get_parent().add_child(b)
	can_shoot = false
	waitToShoot(fire_rate)

func _on_Visibility_body_entered(body):
	if target:
		return
	if usesVision and body.is_in_group("Player"):
		target = body


func _on_Visibility_body_exited(body):
	if body == target:
		target = null

func waitToShoot(sec):
	timer.set_wait_time(sec) # Set Timer's delay to "sec" seconds
	timer.start() # Start the Timer counting down
	yield(timer, "timeout") # Wait for the timer to wind down
	can_shoot = true
	
func takeDamage(damage):
	hp -= damage
	if hp <= 0:
		emit_signal("enemyDeath")
		if not respawns:
			Global.destroyedObjects.append(Global.currentScene+name)
		queue_free()

func setBulletProperties(b):
	b.rotationSpeed = bulletRotationSpeed
	b.maxRotationDiff =  bulletConeDegrees
	b.bulletDecayTime =  bulletDecayTime # Seconds before bullet becomes linear
	b.angleBulletUpdateDelay = angleBulletUpdateDelay
	b.trackingDelayTime = trackingDelayTime

func _on_threatRange_body_entered(body):
	if body.is_in_group("Player"):
		if isFacingLeft:
			anim = "leftTransform"
		else:
			anim = "rightTransform"
		transformed = true

func shoot():
	if fireType == "singleFire":
		shootBulletAtTarget(target.position)
	if fireType == "shotgun":
		shootShotgunAtTarget(target.position)

func _on_animationPlayer_animation_finished(anim_name):
	if anim_name == "leftTransform":
		anim = "leftHostileIdle"
	if anim_name == "rightTrasnform":
		anim = "rightHostileIdle"
	if anim_name == "leftShoot":
		anim = "leftHostileIdle"
		shoot()
	if anim_name == "rightShoot":
		anim = "rightHostileIdle"
		shoot()
