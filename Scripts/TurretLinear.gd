extends KinematicBody2D

# Required to pass editor info to collider child of object
export (int) var detect_radius  # size of the visibility circle
export (float) var fire_rate  # delay time (s) between bullets
export (PackedScene) var BulletLinear
export var bulletType = "Linear"
#export var bulletDelay = 50
#var currentDelay = 0
#var bulletTimer = 0
#var playerPos
var defeated = false

var target  # who are we shooting at?
var can_shoot = true
var vis_color = Color(.867, .91, .247, 0.1)

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_physics_process(true)
#	currentDelay = 0
#	bulletTimer = 0
	#RayNode = get_node("RayCast2D")	#For directions
	var shape = CircleShape2D.new()
	shape.radius = detect_radius
	$Visibility/CollisionShape2D.shape = shape
	$ShootTimer.wait_time = fire_rate

func _physics_process(delta):
	update()
	if(defeated == false):
		#Look at player unless defeated
		#var playerNode = get_node("Player")
		#playerPos = playerNode.get_global_pos()
#		playerPos = get_global_mouse_position()
#		look_at(playerPos)
		
		#Shoot bullets at a consistent rate of fire
		if target:
			rotation = (target.position - position).angle()
			if can_shoot:
				shootBullet(target.position)
#		if(currentDelay == bulletDelay and target):
#			shootBullet(target.position)
#			currentDelay = 0
#		else:
#			currentDelay += 1
	#movement_loop()
	#speed_decay()
	#dash_delay(DASH_DELAY, delta)	# Check if dash can be renabled

func _on_Visibility_body_entered(body):
	# connect this to the "body_entered" signal
	if target:
		return
	target = body
	#$Sprite.self_modulate.r = 1.0

func _on_Visibility_body_exited(body):
	# connect this to the "body_exited" signal
	if body == target:
		target = null
		$Sprite.self_modulate.r = 0.2

func shootBullet(pos):
	#Shoots a bullet in the direction it's facing
	var b = BulletLinear.instance()
	var a = (pos - global_position).angle()
	b.start(global_position, a + rand_range(-0.05, 0.05))
	get_parent().add_child(b)
	can_shoot = false
	$ShootTimer.start()

func _draw():
	# display the visibility area
	draw_circle(Vector2(), detect_radius, vis_color)

func _on_ShootTimer_timeout():
	can_shoot = true
