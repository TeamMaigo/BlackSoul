extends Node
# This script holds all options and any property can be referenced anywhere by typing Global.property
# This script also handles saving and loading from disk

var masterMusic = 0
var masterSound = 0
var destroyedObjects = []
var currentScene = "LabA"
var worldNode


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	BGMPlayer.playing = true

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func save_game():
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	var node_data = {
		"path": worldNode.path,
		"transferGoalPath": worldNode.transferGoalPath
	}
	save_game.store_line(to_json(node_data))

	# Save global properties
	var globalDict = save()
	save_game.store_line(to_json(globalDict))
	
	# Save persist objects
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		node_data = i.call("save");
		save_game.store_line(to_json(node_data))
	save_game.close()
	print("Game saved")

# Note: This can be called from anywhere inside the tree. This function is path independent.
func load_game():
	get_tree().change_scene("res://Scenes/World.tscn")
	call_deferred("_deferred_load_game")
	
func _deferred_load_game():
	worldNode = get_tree().get_root().get_node("World")
	worldNode.get_node("LabRoom").free()	# delete the default room of World

	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
	    return # Error! We don't have a save to load.

	save_game.open("user://savegame.save", File.READ)
	var current_line = parse_json(save_game.get_line()) # path and transfergoal data
	worldNode.path = current_line["path"]
	worldNode.transferGoalPath = current_line["transferGoalPath"]

	current_line = parse_json(save_game.get_line()) # globalProperties
	for i in current_line.keys():
		set(i, current_line[i])

	var scene = load(worldNode.path)
	var currentScene = scene.instance() # Create the new room
	worldNode.currentScene = currentScene
	worldNode.add_child(currentScene)
	var player = worldNode.get_node("Player")
	current_line = parse_json(save_game.get_line()) # path
	for i in current_line.keys():
		player.set(i, current_line[i])
	var transferGoal = currentScene.get_node(worldNode.transferGoalPath)
	player.position = transferGoal.position
	player.lastTransferPoint = transferGoal.position
	worldNode.respawnPoint = transferGoal.position

	save_game.close()
	print("Game loaded")
	
func save():
	var saveDict = {
		"masterMusic": masterMusic,
		"masterSound": masterSound,
		"destroyedObjects": destroyedObjects,
	}
	return saveDict