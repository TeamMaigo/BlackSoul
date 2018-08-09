extends Node

signal end_low_transition
signal end_high_transition

export (float) var energy = 1

export (bool) var strobe = false
export (float) var low_energy = 0
export (float) var high_energy = 1
export (float) var transition_time = 2.5 #Time (seconds) to change energy states
onready var transitionDelta = ((high_energy - low_energy) / (transition_time * 60.0))
onready var transitionDirection = 0

func _ready():
	if strobe:
		energy = low_energy
		transitionDirection = 1
	
	for child in get_children():
		child.energy = energy

func updateStrobe():
	if transitionDirection == 1 && energy >= high_energy:
		transitionDirection = -1
	elif transitionDirection == -1 && energy <= low_energy:
		transitionDirection = 1
	energy += transitionDirection * transitionDelta
	for child in get_children():
		child.energy = energy

func setEnergyLevel(level):
	#0 for low, 1 for high
	if level == 0:
		transitionDirection = -1
	elif level == 1:
		transitionDirection = 1

func updateTransition():
	if transitionDirection != 0:
		energy += transitionDirection * transitionDelta
		energy = clamp(energy, low_energy, high_energy)
		
		if transitionDirection == -1:
			if energy == low_energy:
				transitionDirection = 0
				emit_signal("end_low_transition")
				
		elif energy == high_energy:
			transitionDirection = 0
			emit_signal("end_low_transition")
			

func _process(delta):
	if strobe:
		updateStrobe()
	else:
		updateTransition()