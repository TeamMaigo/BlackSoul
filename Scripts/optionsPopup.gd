extends Panel

const INPUT_ACTIONS = ["ui_up", "ui_left", "ui_down", "ui_right", "ui_dash", "ui_swap", "ui_barrier"]
const INPUT_USER_NAMES = ["Up", "Left", "Down", "Right", "Dash", "Swap", "Barrier"]
const DEFAULT_BUTTONS = ["W", "A", "S", "D", "Shift", "Space", "F"]
var button
var action

func _ready():
	# Called every time the node is added to the scene.
	for action in INPUT_ACTIONS:
#		# We assume that the key binding that we want is the first one (0), if there are several
		var input_event = InputMap.get_action_list(action)[0]
		button = get_node("Container/RebindControls/" + action)
		button.connect("pressed", self, "wait_for_input", [action])
		button.text = InputMap.get_action_list(action)[0].as_text()
	set_process_input(false)
	$Container/SoundText/SoundSlider.value = Global.masterSound
	$Container/MusicText/MusicSlider.value = Global.masterMusic
	$Container/WindowText/WindowButton.selected = getScreenMode()

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

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

func _on_SoundSlider_value_changed(value):
	Global.masterSound = value
	Global.saveOptions()

func _on_MusicSlider_value_changed(value):
	Global.masterMusic = value
	BGMPlayer.volume_db = value
	Global.saveOptions()

func _on_Reset_pressed():
	InputMap.load_from_globals()
	var i = 0
	for action in INPUT_ACTIONS:
#		# We assume that the key binding that we want is the first one (0), if there are several
		var input_event = InputMap.get_action_list(action)[0]
		button = get_node("Container/RebindControls/" + action)
		button.text = DEFAULT_BUTTONS[i]
		i += 1

func _input(event):
	# Handle the first pressed key
	if event is InputEventKey:
		# Register the event as handled and stop polling
		get_tree().set_input_as_handled()
		set_process_input(false)
		# Reinitialise the contextual help label
		$Container/RebindControls/HelpText.text = "Click a key binding to reassign it."
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

func wait_for_input(action_bind):
	action = action_bind
	button = get_node("Container/RebindControls/" + action)
	var pos = INPUT_ACTIONS.find(action)
	$Container/RebindControls/HelpText.text = "Press a key to assign to the '" + INPUT_USER_NAMES[pos] + "' action."
	set_process_input(true)
	
func getScreenMode():
	var id = 0
	if OS.window_borderless == true:
		id += 1
	if OS.window_fullscreen == true:
		id += 1
	return id

func _on_ResolutionButton_item_selected(ID):
	if ID == 0: # Ignore
		get_tree().get_root().size = Vector2(1024, 600)
	if ID == 1: # Keep
		get_tree().get_root().size = Vector2(1440, 900)
	if ID == 2: # expand
		get_tree().get_root().size = Vector2(1280, 720)
