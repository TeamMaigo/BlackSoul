extends Node
# This script holds all options and any property can be referenced anywhere by typing Global.property
# This script also handles saving and loading from disk

var masterMusic = -20
var masterSound = -20
var masterWindowMode = 0
var destroyedObjects = []
var unlockedThings = [] # Doors and gates specifically
var currentScene = "LabA"
var worldNode


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	loadOptions()
	BGMPlayer.playing = true


func save_game(fileNumber):
	var save_game = File.new()
	save_game.open("user://savegame.save" + str(fileNumber), File.WRITE)
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

func load_game(fileNumber):
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"+str(fileNumber)):
	    return # Error! We don't have a save to load.
	get_tree().change_scene("res://Scenes/World.tscn")
	call_deferred("_deferred_load_game", fileNumber)
	
func _deferred_load_game(fileNumber):
	worldNode = get_tree().get_root().get_node("World")
	worldNode.get_node("LabRoom").free()	# delete the default room of World
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"+str(fileNumber)):
	    return # Error! We don't have a save to load.
	save_game.open("user://savegame.save"+str(fileNumber), File.READ)
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
		"destroyedObjects": destroyedObjects,
		"unlockedThings": unlockedThings,
	}
	return saveDict

func saveOptions():
	var save_options = File.new()
	save_options.open("user://gameoptions.save", File.WRITE)
	var node_data = {
		"masterWindowMode": masterWindowMode,
		"masterMusic": masterMusic,
		"masterSound": masterSound
	}
	save_options.store_line(to_json(node_data))
	save_options.close()

func loadOptions():
	var save_options = File.new()
	if not save_options.file_exists("user://gameoptions.save"):
		return # Error! We don't have a save to load.
	
	# Load the file line by line and process that dictionary to restore the object it represents
	save_options.open("user://gameoptions.save", File.READ)
	var current_line = parse_json(save_options.get_line())
	for i in current_line.keys():
		Global.set(i, current_line[i])
	save_options.close()
	_on_WindowButton_item_selected(masterWindowMode)
	
func _on_WindowButton_item_selected(ID):
	masterWindowMode = ID
	if ID == 0: # Set windowed
		OS.window_fullscreen = false
		OS.window_borderless = false
	if ID == 1: # Borderless
		OS.window_fullscreen = false
		OS.window_borderless = true
	if ID == 2: # Fullscreen
		OS.window_fullscreen = true
		OS.window_borderless = true