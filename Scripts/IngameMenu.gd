extends Control

var pauseState = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
	var pressed = Input.is_action_just_pressed("ui_pause")
	if pressed: #Finite state machine
		if pauseState == 0: # in game
			get_tree().paused = true
			$pausePopup.show()
			pauseState = 1
		elif pauseState == 1: # In game pause screen
			_on_Unpause_pressed()
			pauseState = 0
		elif pauseState == 2: # Options pause screen
			_on_Back_pressed()
			pauseState = 1
		else: # Unknown case
			print("Check IngameMenu.gd, unknown case thrown!")
			_on_Unpause_pressed()
			pauseState = 0


func _on_Unpause_pressed():
	$pausePopup.hide()
	get_tree().paused = false
	pauseState = 0


func _on_Options_pressed():
	$pausePopup.hide()
	$optionsPopup.show()
	pauseState = 2


func _on_Quit_pressed():
	get_tree().paused = false	# Unpause stuff, otherwises the menus won't work!
	BGMPlayer.stream = load("res://Audio/YaboiPlaceholderBGM.ogg")
	get_tree().change_scene("res://Scenes/MainMenu.tscn")


func _on_Back_pressed():
	$pausePopup.show()
	$optionsPopup.hide()

