extends Node

export (float) var energy = 1

export (bool) var strobe = false
export (float) var strobe_low_energy = 0
export (float) var strobe_high_energy = 1
export (float) var strobe_period = 5
onready var strobe_energy = strobe_low_energy
onready var strobeDelta = (strobe_high_energy - strobe_low_energy) / (strobe_period * 60.0)
onready var strobeDirection = 1

func _ready():
	if strobe:
		for child in get_children():
			child.energy = strobe_energy
	
	else:
		for child in get_children():
			child.energy = energy

func updateStrobe():
	if strobeDirection == 1 && strobe_energy >= strobe_high_energy:
		strobeDirection = -1
	elif strobeDirection == -1 && strobe_energy <= strobe_low_energy:
		strobeDirection = 1
	strobe_energy += strobeDirection * strobeDelta
	for child in get_children():
		child.energy = strobe_energy
	
func _process(delta):
	if strobe:
		updateStrobe()
