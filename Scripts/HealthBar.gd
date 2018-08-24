extends Control

export (PackedScene) var health_icon

var value = 0
var maxValue = 0
onready var container = $gridContainer

func _ready():
	pass

func setMaxValue(m):
	if m == maxValue:
		return
	maxValue = m
	if m < len(container.get_children()):
		while m < len(container.get_children()):
			var icon = container.get_children()[-1]
			icon.queue_free()
			container.get_children().pop_back()
	elif m > len(container.get_children()):
		while m > len(container.get_children()):
			var icon = health_icon.instance()
			container.add_child(icon)
	_updateIcons()
	
func _updateIcons():
	for i in range(0, len(container.get_children())):
		var icon = container.get_children()[i]
		if i < value:
			icon.activate()
		else:
			icon.deactivate()
	
func setValue(value):
	self.value = value
	_updateIcons()