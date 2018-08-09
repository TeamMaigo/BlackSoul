extends Node

export var canvasModulate = true


func _ready():
	get_node("/root/World/canvasModulate").visible = canvasModulate
	
func enable():
	get_node("/root/World/canvasModulate").visible = true
	
func disable():
	get_node("/root/World/canvasModulate").visible = false