extends Control
@onready var inventory_ui: InventoryHandler = $"../InventoryUI"


func _ready() -> void:
	self.visible = false
# Called when the node enters the scene tree for the first time.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		inventory_ui.Inventory_toggle = not inventory_ui.Inventory_toggle
		self.visible = inventory_ui.Inventory_toggle
