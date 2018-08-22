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
export var aggroTime = 3 # seconds
var spreadAngles = []
onready var AnimNode = $animationPlayer
var anim = "Idle"
var animNew = ""
var isFacingLeft
var transformed = false
var transforming = false
var idleAnimationPlaying = false
var canMove = true
var lastKnownTarget # Used to avoid enemies shooting blanks

var breakableTargetPos = null
var isDying = false

export var burst_fire = false
export (Array, float) var burst_pattern
var burstSize
var burstPhase = 0

signal enemyDeath

func _ready():
	if burst_fire && burst_pattern != null:
		burstSize = len(burst_pattern)
		burstPhase = burstSize + 1 #Don't use burst pattern during initial wait
	else:
		burstSize = 0
		burst_fire = false
	
	$Visibility.show()
	if Global.currentScene+name in Global.destroyedObjects:
		queue_free()
	var shape = CircleShape2D.new()
	shape.radius = detect_radius
	$Visibility/CollisionShape2D.shape = shape
	var shape1 = CircleShape2D.new() # Zone where enemy transforms
	shape1.radius = detect_radius + 100
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
	if MOTION_SPEED == 0:
		canMove = false
	idleAnimationDelay()

func _physics_process(delta):
	if transformed:
		if target:
			canSeePlayer = checkForPlayer(target)
			if canSeePlayer:
				updateFacing(target.position)
				lastKnownPlayerPos = target.position
				if can_shoot:
					if isFacingLeft:
						anim = "leftShoot"
					else:
						anim = "rightShoot"
					canMove = false
	else:
		if not transforming and not transformed:
			if idleAnimationPlaying:
				if isFacingLeft:
					anim = "idleLeft2"
				else:
					anim = "idleRight2"
			else:
				if isFacingLeft:
					anim = "idleLeft"
				else:
					anim = "idleRight"
	if canMove and transformed:
		movement_loop()
	if anim != animNew:
		animNew = anim
		AnimNode.play(anim)


func movement_loop():
	if lastKnownPlayerPos:
		moveDir = (lastKnownPlayerPos - position).normalized()
		var motion = moveDir.normalized() * MOTION_SPEED
		if (lastKnownPlayerPos - position).length() > 10:
			move_and_slide(motion)
			var collisions = get_slide_count()
			for i in range(collisions - 1, 0 -1, -1): # First collision takes priority
				var collider = get_slide_collision(i).collider
				if collider.is_in_group("Breakable"):
					breakableTargetPos = collider.position
		else:
			lastKnownPlayerPos = null	# Reached the destination
		if isFacingLeft:
			anim = "leftWalk"
		else:
			anim = "rightWalk"
	else:
		if isFacingLeft:
			anim = "leftHostileIdle"
		else:
			anim = "rightHostileIdle"

func checkForPlayer(target):
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
	var origin = $RightProjectileOrigin.global_position
	if isFacingLeft:
		origin = $LeftProjectileOrigin.global_position
		
	var b = BulletType.instance()
	var a = (pos - origin).angle()
	var dir = a + rand_range(-0.05, 0.05)
	var startPos = origin + Vector2(bulletSpeed, 0).rotated(dir).normalized()*bulletOffset
	b.start(startPos, dir, bulletSpeed)
	setBulletProperties(b)
	get_parent().add_child(b)
	can_shoot = false
	waitToShoot(fire_rate)

func shootShotgunAtTarget(pos):
	#Shoots a spray of bullets at the target position with some random variance
	var origin = $RightProjectileOrigin.global_position
	if isFacingLeft:
		origin = $LeftProjectileOrigin.global_position
	
	for i in spreadAngles:
		var b = BulletType.instance()
		var a = (pos - origin).angle()
		var dir = a + rand_range(-0.05, 0.05)
		var startPos = origin + Vector2(bulletSpeed, 0).rotated(dir).normalized()*bulletOffset
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
		lastKnownTarget = body
		if not transformed:
			_on_threatRange_body_entered(body)

func _on_Visibility_body_exited(body):
	if body == target:
		target = null

func deaggroDelay(sec):
	$AggroTimer.set_wait_time(sec) # Set Timer's delay to "sec" seconds
	$AggroTimer.start() # Start the Timer counting down
	yield($AggroTimer, "timeout") # Wait for the timer to wind down
	if not target:
		lastKnownTarget = null
		lastKnownPlayerPos = null
		transforming = true
		transformed = false
		if isFacingLeft:
			anim = "leftUntransform"
		else:
			anim = "rightUntransform"

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
	
func takeDamage(damage):
	hp -= damage
	if hp <= 0:
		if not respawns:
			Global.destroyedObjects.append(Global.currentScene+name)
		$audioStreamPlayer.stream = load("res://Audio/HitSound.wav")
		$audioStreamPlayer.volume_db = Global.masterSound
		$audioStreamPlayer.play()
		collision_layer = 0
		collision_mask = 0
		hide()
		isDying = true

func setBulletProperties(b):
	b.rotationSpeed = bulletRotationSpeed
	b.maxRotationDiff =  bulletConeDegrees
	b.bulletDecayTime =  bulletDecayTime # Seconds before bullet becomes linear
	b.angleBulletUpdateDelay = angleBulletUpdateDelay
	b.trackingDelayTime = trackingDelayTime

func _on_threatRange_body_entered(body):
	if body.is_in_group("Player") and not transformed:
		if isFacingLeft:
			anim = "leftTransform"
		else:
			anim = "rightTransform"
		transforming = true
		canMove = false

func _on_threatRange_body_exited(body):
	deaggroDelay(aggroTime)

func shoot():
	$audioStreamPlayer.stream = load("res://Audio/GunBlap.wav")
	$audioStreamPlayer.volume_db = Global.masterSound
	$audioStreamPlayer.play()
	
	var shootAtPos = lastKnownTarget.position
	if breakableTargetPos != null:
		shootAtPos = breakableTargetPos
		breakableTargetPos = null
	
	if fireType == "singleFire":
		shootBulletAtTarget(shootAtPos)
	if fireType == "shotgun":
		shootShotgunAtTarget(shootAtPos)

func _on_animationPlayer_animation_finished(anim_name):
	if anim_name == "leftTransform":
		anim = "leftHostileIdle"
	if anim_name == "rightTrasnform":
		anim = "rightHostileIdle"
	if anim_name == "leftShoot":
		anim = "leftHostileIdle"
		shoot()
		canMove = true
	if anim_name == "rightShoot":
		anim = "rightHostileIdle"
		shoot()
		canMove = true
	if anim_name == "leftTransform" or anim_name == "rightTransform":
		canMove = true
		transformed = true
		transforming = false
	if anim_name == "leftUntransform" or anim_name == "rightUntransform":
		target = null
		transformed = false
		transforming = false
	if anim_name == "idleLeft2" or anim_name == "idleRight2":
		idleAnimationPlaying = false

func updateFacing(pos):
	var a = (pos - global_position).angle()
	if rad2deg(a) > 90 or rad2deg(a) < -90:
		isFacingLeft = true
	else:
		isFacingLeft = false

func idleAnimationDelay():
	$IdleAnimationTimer.set_wait_time(randi()%5+5) # Set Timer's delay to "sec" seconds
	$IdleAnimationTimer.start() # Start the Timer counting down
	yield($IdleAnimationTimer, "timeout") # Wait for the timer to wind down
	if not transformed and not transforming:
		idleAnimationPlaying = true
	else:
		idleAnimationPlaying = false
	idleAnimationDelay()

func _on_audioStreamPlayer_finished():
	if isDying:
		emit_signal("enemyDeath")
		queue_free()
