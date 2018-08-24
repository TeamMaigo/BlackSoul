extends Control

func _ready():
	pass
	
func activate():
	$Active.visible = true
	$Unactive.visible = false

func deactivate():
	$Active.visible = false
	$Unactive.visible = true