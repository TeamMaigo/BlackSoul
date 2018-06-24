extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var current_scene = get_node("Room1")
onready var player = get_node("Player")
onready var camera = get_node("Player/Camera2D")
onready var pauseMenu = get_node("Player/Camera2D/pausePopup")

var transferGoal
var transferGoalPath

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	var pause = Input.is_action_pressed("ui_pause")
	if pause:
		#updatePauseMenuLocation()
		get_tree().paused = true
		$Player/Camera2D/pausePopup.show()

func goto_scene(path, transferGoalPath):
	#pass
    # This function will usually be called from a signal callback,
    # or some other function from the running scene.
    # Deleting the current scene at this point might be
    # a bad idea, because it may be inside of a callback or function of it.
    # The worst case will be a crash or unexpected behavior.

    # The way around this is deferring the load to a later time, when
    # it is ensured that no code from the current scene is running:
	call_deferred("_deferred_goto_scene",path, transferGoalPath)

func _deferred_goto_scene(path, transferGoalPath):
	#pass
    # Immediately free the current scene,
    # there is no risk here.
	current_scene.queue_free()

    # Load new scene
	var scene = load(path)

    # Instance the new scene
	current_scene = scene.instance()

    # Add it to the active scene, as child of root
	get_tree().get_root().add_child(current_scene)
	transferGoal = current_scene.get_node(transferGoalPath)
	player.position = transferGoal.position

    # optional, to make it compatible with the SceneTree.change_scene() API
	get_tree().set_current_scene( current_scene )

func _on_Unpause_pressed():
	$Player/Camera2D/pausePopup.hide()
	get_tree().paused = false

func updatePauseMenuLocation():
	# Meant to identify where should the pausePopup go.
	# TODO
	var pauseMenuPos = Vector2()
	#pauseMenuPos.x = camera.get_viewport().get_visible_rect().size.x/2 - pauseMenu.get_size().x/2
	#pauseMenuPos.y = camera.get_viewport().get_visible_rect().size.y/2# - pauseMenu.get_size().height/2
	#print(pauseMenuPos)
	#pauseMenu.set_rotation(180)#(player.get_rid())
	#pauseMenu.rect_position = camPos