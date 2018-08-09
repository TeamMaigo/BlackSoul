extends Node
# This script holds all options and any property can be referenced anywhere by typing Global.property

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
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		node_data = i.call("save");
		save_game.store_line(to_json(node_data))
		print(i.name + " saved")
	save_game.close()
	print("Game saved")

# Note: This can be called from anywhere inside the tree. This function is path independent.
func load_game():
	get_tree().change_scene("res://Scenes/World.tscn")
	call_deferred("_deferred_load_game")
	
func _deferred_load_game():
	worldNode = get_tree().get_root().get_node("World")
	worldNode.get_node("LabRoom").free()
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
	    return # Error! We don't have a save to load.
	# We need to revert the game state so we're not cloning objects during loading. This will vary wildly depending on the needs of a project, so take care with this step.
	# For our example, we will accomplish this by deleting savable objects.
	var save_nodes = get_tree().get_nodes_in_group("Persist")
#	for i in save_nodes:
#	    i.queue_free()
	
	# Load the file line by line and process that dictionary to restore the object it represents
	save_game.open("user://savegame.save", File.READ)
	var current_line = parse_json(save_game.get_line()) # path
	worldNode.path = current_line["path"]
	worldNode.transferGoalPath = current_line["transferGoalPath"]
#	while not save_game.eof_reached():
#		current_line = parse_json(save_game.get_line())
#		# First we need to create the object and add it to the tree and set its position.
#		if current_line != null:
#			var new_object = load(current_line["filename"]).instance()
#			get_node(current_line["parent"]).add_child(new_object)
#			#new_object.position = Vector2(current_line["pos_x"], current_line["pos_y"])
#			# Now we set the remaining variables.
#			for i in current_line.keys():
#				if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
#					continue
#				new_object.set(i, current_line[i])
	print("Loading")

	var scene = load(worldNode.path)
	var currentScenes = scene.instance()
	worldNode.currentScene = currentScenes
	currentScene = worldNode.path
	worldNode.add_child(currentScenes)
	var player = worldNode.get_node("Player")
	current_line = parse_json(save_game.get_line()) # path
	for i in current_line.keys():
		player.set(i, current_line[i])
	var transferGoal = currentScenes.get_node(worldNode.transferGoalPath)
	player.position = transferGoal.position
	player.lastTransferPoint = transferGoal.position
	worldNode.respawnPoint = transferGoal.position
	#worldNode.goto_scene(worldNode.path, worldNode.transferGoalPath)
	save_game.close()
	print("Game loaded")