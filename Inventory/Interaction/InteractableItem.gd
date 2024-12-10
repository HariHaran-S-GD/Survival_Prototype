extends Node3D
class_name InteractableItem

@export var ItemHighlightmesh: MeshInstance3D
var is_picked: bool = false  # Flag to indicate if the item has been picked

func GainFocus():
	ItemHighlightmesh.visible = true

func LoseFocus():
	ItemHighlightmesh.visible = false
	
