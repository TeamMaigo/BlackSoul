extends Control

var pauseState = 0
const INPUT_ACTIONS = ["ui_up", "ui_left", "ui_down", "ui_right", "ui_dash", "ui_swap", "ui_barrier"]
const INPUT_USER_NAMES = ["Up", "Left", "Down", "Right", "Dash", "Swap", "Barrier"]
const DEFAULT_BUTTONS = ["W", "A", "S", "D", "Shift", "Space", "F"]
var button
var action

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	for action in INPUT_ACTIONS:
#		# We assume that the key binding that we want is the first one (0), if there are several
		var input_event = InputMap.get_action_list(action)[0]
		button = get_node("optionsPopup/Container/RebindControls/" + action)
		button.connect("pressed", self, "wait_for_input", [action])
	set_process_input(false)
	var volume = $optionsPopup/Container/SoundText/SoundSlider.value
	get_tree().get_root().get_node("World/Player/PlayerAudio").volume_db = (volume*0.5)-50
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

func wait_for_input(action_bind):
	action = action_bind
	button = get_node("optionsPopup/RebindControls/" + action)
	var pos = INPUT_ACTIONS.find(action)
	$optionsPopup/RebindControls/HelpText.text = "Press a key to assign to the '" + INPUT_USER_NAMES[pos] + "' action."
	set_process_input(true)

func _input(event):
	# Handle the first pressed key
	if event is InputEventKey:
		# Register the event as handled and stop polling
		get_tree().set_input_as_handled()
		set_process_input(false)
		# Reinitialise the contextual help label
		$optionsPopup/RebindControls/HelpText.text = "Click a key binding to reassign it."
		if not event.is_action("ui_cancel"):
			# Display the string corresponding to the pressed key
			var scancode = OS.get_scancode_string(event.scancode)
			button.text = scancode
			# Start by removing previously key binding(s)
			for old_event in InputMap.get_action_list(action):
				InputMap.action_erase_event(action, old_event)
			# Add the new key binding
			InputMap.action_add_event(action, event)
			#save_to_config("input", action, scancode)

func _on_Unpause_pressed():
	$pausePopup.hide()
	get_tree().paused = false
	pauseState = 0


func _on_Options_pressed():
	$pausePopup.hide()
	$optionsPopup.show()
	pauseState = 2


func _on_Quit_pressed():
	#TODO Save Data
	get_tree().paused = false	# Unpause stuff, otherwises the menus won't work!
	get_tree().change_scene("res://Scenes/MainMenu.tscn")


func _on_Back_pressed():
	$pausePopup.show()
	$optionsPopup.hide()


func _on_WindowButton_item_selected(ID):
	if ID == 0: # Set windowed
		OS.window_fullscreen = false
		OS.window_borderless = false
	if ID == 1: # Borderless
		OS.window_fullscreen = false
		OS.window_borderless = true
	if ID == 2: # Fullscreen
		OS.window_fullscreen = true
		OS.window_borderless = true


func _on_AspectButton_item_selected(ID): #TODO?
	if ID == 0: # Ignore
		pass
	if ID == 1: # Keep
		pass
	if ID == 2: # expand
		pass


func _on_Reset_pressed():
	InputMap.load_from_globals()
	var i = 0
	for action in INPUT_ACTIONS:
#		# We assume that the key binding that we want is the first one (0), if there are several
		var input_event = InputMap.get_action_list(action)[0]
		button = get_node("optionsPopup/RebindControls/" + action)
		button.text = DEFAULT_BUTTONS[i]
		i += 1

func _on_SoundSlider_value_changed(value):
	#TODO Sound needs to probably pass through a master script that all audio goes through?
	# Alternatively a global audio stream player?
	var newValue = adjustForDecibel(value)
	Global.masterSound = newValue

func _on_MusicSlider_value_changed(value):
	var newValue = adjustForDecibel(value)
	Global.masterMusic = newValue
	BGMPlayer.volume_db = newValue

func adjustForDecibel(value):
	return value*0.5-50