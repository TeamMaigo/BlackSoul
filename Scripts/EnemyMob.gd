extends KinematicBody2D

export var hp = 1
export var MOTION_SPEED = 100
export (int) var detect_radius = 300
export (PackedScene) var BulletType
export var bulletSpeed = 10
export (float) var fire_rate = 1  # delay time (s) between bullets
export(String, "singleFire", "shotgun") var fireType
export var shotgunBulletAmount = 3
export var shotgunSpread = 20 # degree
export var respawns = true
export var trackingDelayTime = 0.25 # Sec till bullet starts tracking
export var bulletOffset = 1
export var bulletRotationSpeed = 1.0 # degrees per frame
export var bulletConeDegrees = 40.0 # Bullet cone of vision (this number is cone of vision degrees, and is 40 both ways)
export var bulletDecayTime = 10.0 # Seconds before bullet becomes linear
export var angleBulletUpdateDelay = 1.0 #seconds
export var aggroTime = 6 # seconds

export var burst_fire = false
export (Array, float) var burst_pattern
var burstLength
var burstPhase = 0

onready var aggroTimer = $AggroExpiryTimer
onready var shotTimer = $ShotTimer
onready var animationPlayer = $animationPlayer

var breakableTarget
var framesSinceBreakableCollision = -1

var target
var lastTargetPosition
var aggroTimerOn = false

var scanning = false

var canShoot = true
var canMove = true
var inThreatRange = false

var currentAnim = ""
var animationLock = false


var aggro = false

var moving = false

var facingRight = 1 #Used as array index for animations
var shootTarget = null

var spreadAngles = []

signal enemyDeath
var transformed = false
var startedBurst = false
var dead = false

var animTimes = []
var animSpeeds = []
var cds = []

func _ready():
	$Vision/CollisionShape2D.shape.radius = detect_radius
	$TransformRange/collisionShape2D.shape.radius = detect_radius + 100
	setAnim_idle()
	
	#Spread angles
	if shotgunBulletAmount%2 == 0:
		for i in shotgunBulletAmount/2:
			spreadAngles.append(i * shotgunSpread)
			spreadAngles.append((-i-1) * shotgunSpread)
	else: #Odd number of bullets
		for i in (shotgunBulletAmount-1)/2:
			spreadAngles.append((i+1)*shotgunSpread)
			spreadAngles.append((-i-1)*shotgunSpread)
		spreadAngles.append(0)
	
	#Burst fire
	if burst_fire && burst_pattern != null:
		burstLength = len(burst_pattern)
	else:
		burstLength = 0
		burst_fire = false
		
	generateAnimationTables()

func generateAnimationTables():
	animTimes = []
	animSpeeds = []
	cds = []
	
	if burst_fire:
		animTimes.append(0.3)
		animSpeeds.append(1)
		for val in burst_pattern:
			var animTime = clamp(val/2, 0, 0.3)
			var cd = val - animTime
			var animSpeed = 0.3 / animTime
			animTimes.append(animTime)
			animSpeeds.append(animSpeed)
			cds.append(cd)
		cds.append(fire_rate)
	else:
		var animTime = clamp(fire_rate/2.0, 0, 0.3)
		var cd = fire_rate - animTime
		var animSpeed = 0.3 / animTime
		animTimes.append(animTime)
		animSpeeds.append(animSpeed)
		cds.append(cd)

func _physics_process(delta):
	if dead:
		return
	if !transformed && inThreatRange:
		tryTransform()
	elif transformed && !aggro && !inThreatRange:
		tryUntransform()
	elif canSeeTarget() || startedBurst:
		stopAggroTimer()
		lastTargetPosition = target.position
		aggro = true
		if breakableTarget && prioritizeBreakableTarget():
			tryShoot(breakableTarget)
		else:
			tryShoot(target)
	else:
		if !aggroTimerOn:
			startAggroTimer()
	movementLoop()
	if moving:
		setAnim_walk()
	else:
		if transformed:
			setAnim_hostileIdle()
		else:
			setAnim_idle()

func tryShoot(targ):
	if canShoot:
		shootTarget = targ
		facePosition(targ.position)
		if setAnim_shoot():
			canShoot = false
			if burst_fire:
				startedBurst = true

func shootAt(targ):
	$audioStreamPlayer.stream = load("res://Audio/GunBlap.wav")
	$audioStreamPlayer.volume_db = Global.masterSound
	$audioStreamPlayer.play()
	if fireType == "singleFire":
		makeBulletTowards(targ.position)
	elif fireType == "shotgun":
		makeShotgunTowards(targ.position)
	startShotCooldown()
	cycleBurstPhase()

func movementLoop():
	breakableTarget = null
	moving = false
	if !canMove || !aggro:
		return
	if lastTargetPosition:
		facePosition(lastTargetPosition)
		var moveDir = (lastTargetPosition - position).normalized()
		var movement = moveDir * MOTION_SPEED
		if (lastTargetPosition - position).length() > 10:
			move_and_slide(movement)
			var collisions = get_slide_count()
			for i in range(collisions - 1, 0 - 1, -1): #Iterate backwards
				var col = get_slide_collision(i)
				if col.collider.is_in_group("Breakable"):
					breakableTarget = col.collider
			moving = true

func canSeeTarget():
	if target == null || scanning == false:
		return false
	#Raycast to check if can see target
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(position, target.position, [self], 7) # Hits environment, player, enemies
	if result:
		if result.collider.is_in_group("Player"): # Sees player and nothing inbetween
			if not result.collider.get_node("./").swappedRecently:
				return true
	return false # Failed to detect target

func makeBulletTowards(pos):
	var origin = getProjectileOrigin()
	var b = BulletType.instance()
	var a = (pos - origin).angle()
	var dir = a + rand_range(-0.05, 0.05)
	var startPos = origin
	b.start(startPos, dir, bulletSpeed)
	setBulletProperties(b)
	get_parent().add_child(b)

func makeShotgunTowards(pos):
	#Shoots a spray of bullets at the target position with some random variance
	var origin = getProjectileOrigin()
	
	for ang in spreadAngles:
		var b = BulletType.instance()
		var a = (pos - origin).angle()
		var dir = a + rand_range(-0.05, 0.05)
		var startPos = origin
		b.start(startPos, a + deg2rad(ang), bulletSpeed)
		setBulletProperties(b)
		get_parent().add_child(b)

func setBulletProperties(b):
	b.rotationSpeed = bulletRotationSpeed
	b.maxRotationDiff =  bulletConeDegrees
	b.bulletDecayTime =  bulletDecayTime # Seconds before bullet becomes linear
	b.angleBulletUpdateDelay = angleBulletUpdateDelay
	b.trackingDelayTime = trackingDelayTime

func getProjectileOrigin():
	if facingRight:
		return $RightProjectileOrigin.global_position
	return $LeftProjectileOrigin.global_position

#Each animation has its own set function, to avoid multiple comparisons which waste performance
func setAnim_idle():
	var newAnim = ["idleLeft", "idleRight"][facingRight]
	return updateAnimPlayer(newAnim, true, false)

func setAnim_idle2():
	var newAnim = ["idleLeft2", "idleRight2"][facingRight]
	return updateAnimPlayer(newAnim, true, false)
	
func setAnim_hostileIdle():
	var newAnim = ["leftHostileIdle", "rightHostileIdle"][facingRight]
	return updateAnimPlayer(newAnim, true, false)

func setAnim_shoot():
	var newAnim = ["leftShoot", "rightShoot"][facingRight]
	var customSpeed = getAnimationSpeed()
	
	return updateAnimPlayer(newAnim, false, true, customSpeed)

func setAnim_walk():
	var newAnim = ["leftWalk", "rightWalk"][facingRight]
	return updateAnimPlayer(newAnim, true, false)
	
func setAnim_transform():
	var newAnim = ["leftTransform", "rightTransform"][facingRight]
	return updateAnimPlayer(newAnim, false, true)

func setAnim_untransform():
	var newAnim = ["leftUntransform", "rightUntransform"][facingRight]
	return updateAnimPlayer(newAnim, false, true)
	
func setAnim_death():
	var newAnim = ["deathLeft", "deathRight"][facingRight]
	animationLock = false
	return updateAnimPlayer(newAnim, false, true)

func updateAnimPlayer(newAnim, newCanMove, newAnimationLock, customSpeed = 1):
	if animationLock:
		return false
	else:
		if newAnim != currentAnim:
			currentAnim = newAnim
			canMove = newCanMove
			animationLock = newAnimationLock
			animationPlayer.playback_speed = customSpeed
			animationPlayer.play(currentAnim)
			return true
	return false

func startAggroTimer():
	aggroTimerOn = true
	aggroTimer.wait_time = aggroTime
	aggroTimer.start()

func stopAggroTimer():
	aggroTimerOn = false
	aggroTimer.stop()

func _on_AggroExpiryTimer_timeout():
	aggro = false
	lastTargetPosition = null
	aggroTimer.stop()

func facePosition(pos):
	setFacing(rad2deg((pos - global_position).angle()))

func setFacing(deg):
	if deg >= 90 || deg <= -90:
		facingRight = 0
	else:
		facingRight = 1
	
	
func getShotTimeCost():
	#How long until enemy can shoot again after firing this shot
	return animTimes[burstPhase] + cds[burstPhase]

func prioritizeBreakableTarget():
	var time = getShotTimeCost()
	var prob
	if time <= 0.1:
		prob = 1.0
	elif time > 0.1 && time <= 1.0:
		prob = (1.0 - 0.4)/(0.1 - 1) * (time - 0.1) + 1.0 #Slope * delta + base
	elif time > 1.0 && time <= 3.0:
		prob = (0.4 - 0.2)/(1.0 - 3.0) * (time - 1.0) + 0.4
	elif time > 3.0:
		prob = 0.2
	var gen = (randi() % 1000001)/1000000.0
	return gen <= prob
	
	

func getShotCooldown():
	return cds[burstPhase]

func cycleBurstPhase():
	if burst_fire:
		if burstPhase >= burstLength:
			burstPhase = 0
			startedBurst = false
		else:
			burstPhase += 1

func getAnimationSpeed():
	return animSpeeds[burstPhase]

func startShotCooldown():
	canShoot = false
	shotTimer.wait_time = getShotCooldown()
	shotTimer.start()

func _on_ShotTimer_timeout():
	canShoot = true

func _on_Vision_body_entered(body):
	if body.is_in_group("Player"):
		target = body
		scanning = true

func _on_Vision_body_exited(body):
	if body == target:
		scanning = false

func _on_animationPlayer_animation_finished(anim_name):
	if anim_name == "leftShoot" || anim_name == "rightShoot":
		shootAt(shootTarget)
	canMove = true #Currently, all animations that stop moving should allow moving after they finish
	animationLock = false #Same for animation locking

func _on_TransformRange_body_entered(body):
	if body.is_in_group("Player"):
		inThreatRange = true

func _on_TransformRange_body_exited(body):
	if body.is_in_group("Player"):
		inThreatRange = false

func tryUntransform():
	if setAnim_untransform():
		transformed = false
		burstPhase = 0

func tryTransform():
	if setAnim_transform():
		transformed = true

func stopAllTimers():
	shotTimer.stop()
	aggroTimer.stop()
	
func takeDamage(damage):
	hp -= damage
	if hp <= 0 && !dead:
		if not respawns:
			Global.destroyedObjects.append(Global.currentScene+name)
		$audioStreamPlayer.stream = load("res://Audio/HitSound.wav")
		$audioStreamPlayer.volume_db = Global.masterSound
		$audioStreamPlayer.play()
		collision_layer = 0
		collision_mask = 0
		dead = true
		$CollisionShape2D.disabled = true
		stopAllTimers()
		setAnim_death()
		emit_signal("enemyDeath")
		