extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var currentScene = get_node("LabRoom")
onready var player = get_node("Player")
onready var camera = get_node("Player/Camera2D")

var masterSound
var masterMusic
var scene = load("res://Scenes/Rooms/LabA.tscn")
var transferGoal
var transferGoalPath
var path
onready var respawnPoint = player.position
var pauseState = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	masterSound = $CanvasLayer/Options.getSoundValue()
	masterMusic = $CanvasLayer/Options.getMusicValue()
	$CanvasLayer/Options/BGMPlayer.playing = true

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	pass

func goto_scene(path, transferGoalPath):
	#pass
    # This function will usually be called from a signal callback,
    # or some other function from the running scene.
    # Deleting the current scene at this point might be
    # a bad idea, because it may be inside of a callback or function of it.
    # The worst case will be a crash or unexpected behavior.

    # The way around this is deferring the load to a later time, when
    # it is ensured that no code from the current scene is running:
	#$AnimationPlayer.play("Scene Transition")
	$CanvasLayer/ScenePlayer.play("Scene Transition")
	self.transferGoalPath = transferGoalPath
	self.path = path

func sceneTransition():
	call_deferred("_deferred_goto_scene", path, transferGoalPath)

func _deferred_goto_scene(path, transferGoalPath):
    # Immediately free the current scene,
    # there is no risk here.
	currentScene.queue_free()

    # Load new scene
	scene = load(path)

    # Instance the new scene
	currentScene = scene.instance()

    # Add it to the active scene, as child of root
	get_tree().get_root().get_node("World").add_child(currentScene)
	transferGoal = currentScene.get_node(transferGoalPath)
	player.position = transferGoal.position
	player.lastTransferPoint = transferGoal.position
	respawnPoint = transferGoal.position
    # optional, to make it compatible with the SceneTree.change_scene() API
	#get_tree().set_current_scene( currentScene ) # Currently gives debug message...?

func reloadLastScene():
	currentScene.queue_free()
	currentScene = scene.instance()
	get_tree().get_root().add_child(currentScene)
	player.position = respawnPoint

func _get_camera_center():
    var vtrans = get_canvas_transform()
    var top_left = -vtrans.get_origin() / vtrans.get_scale()
    var vsize = get_viewport_rect().size
    return top_left + 0.5*vsize/vtrans.get_scale()

func _on_ScenePlayer_animation_finished(anim_name):
	if anim_name == "Scene Transition":
		$Player.playerControlEnabled = true