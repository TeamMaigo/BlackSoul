extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var current_scene = get_node("Room1")
onready var player = get_node("Player")
onready var camera = get_node("Player/Camera2D")
onready var pauseMenu = get_node("Control/pausePopup")

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
		get_tree().paused = true
		$CanvasLayer/Control/pausePopup.show()

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
	$CanvasLayer/Control/pausePopup.hide()
	get_tree().paused = false

func _get_camera_center():
    var vtrans = get_canvas_transform()
    var top_left = -vtrans.get_origin() / vtrans.get_scale()
    var vsize = get_viewport_rect().size
    return top_left + 0.5*vsize/vtrans.get_scale()

func _on_Quit_pressed():
	#TODO Save Data?
	get_tree().paused = false	# Unpause stuff, otherwises the menus won't work!
	get_tree().change_scene("res://Scenes/MainMenu.tscn")
