#TODO:
	#Don't use hardcoded FPS number


extends KinematicBody2D

# Required to pass editor info to collider child of object
export (int) var detect_radius  # size of the visibility circle
export (int) var fire_rate = 60  # delay time (frames) between bullets
export (float) var firstShotDelay = 0
export (PackedScene) var BulletLinear
export var bulletType = "Linear"
export var bulletSpeed = 1
export var rotatingTurret = true
export var usesTargeting = true

var defeated = false
onready var timer = get_node("ShootTimer")
var target  # who are we shooting at?
var can_shoot = false
var vis_color = Color(.867, .91, .247, 0.1)

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_physics_process(true)
	if usesTargeting:
		var shape = CircleShape2D.new()
		shape.radius = detect_radius
		$Visibility/CollisionShape2D.shape = shape
	else:
		$Visibility.visible == false
	if firstShotDelay > 0:
		waitToShoot(firstShotDelay)
	else:
		can_shoot = true

func _physics_process(delta):
	#update()
	if(defeated == false):
		#Shoot bullets at a consistent rate of fire
		if target:
			if rotatingTurret:
				rotation = (target.position - position).angle()
			if can_shoot:
				shootBulletAtTarget(target.position)
		elif not usesTargeting:
			if can_shoot:
				shootBulletStraight()
		else:
			pass


func _on_Visibility_body_entered(body):
	# connect this to the "body_entered" signal
	if target:
		return
	if usesTargeting && body.is_in_group("team_Player"):
		target = body
	$Sprite.self_modulate.r = 1.0

func _on_Visibility_body_exited(body):
	# connect this to the "body_exited" signal
	if body == target:
		target = null
		$Sprite.self_modulate.r = 0.2

func shootBulletAtTarget(pos):
	#Shoots a bullet at the target position with some random variance
	var b = BulletLinear.instance()
	var a = (pos - global_position).angle()
	b.start(global_position, a + rand_range(-0.05, 0.05), bulletSpeed)
	get_parent().add_child(b)
	can_shoot = false
	waitToShoot(fire_rate)

func shootBulletStraight():
	#Shoots a bullet in the direction it's facing
	var b = BulletLinear.instance()
	b.start(global_position, self.get_global_transform().get_rotation(), bulletSpeed)
	get_parent().add_child(b)
	can_shoot = false
	waitToShoot(fire_rate)

func _draw():
	# display the visibility area
	if usesTargeting:
		draw_circle(Vector2(), detect_radius, vis_color)

	
func waitToShoot(sec):
	timer.set_wait_time(fire_rate) # Set Timer's delay to "sec" seconds
	timer.start() # Start the Timer counting down
	yield(timer, "timeout") # Wait for the timer to wind down
	can_shoot = true