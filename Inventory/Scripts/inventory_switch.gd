extends Button
@onready var inventory_ui: InventoryHandler = $"../../../InventoryUI"
@onready var crafting_window: Panel = $"../../../Crafting_UI/CraftingWindow"
@onready var crafting_ui: Control = $"../../../Crafting_UI"





func _on_pressed() -> void:
	inventory_ui.visible = true
	crafting_window.visible = false
	crafting_ui.visible = false
