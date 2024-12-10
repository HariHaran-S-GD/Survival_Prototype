class_name  Craftables_ui
extends Panel
var item_icon : TextureRect
var recipe_text : Label
var craft_button : Button
var recipe : Craftables
var crafting


func get_nodes():
	item_icon = get_node("ItemIcon")
	recipe_text = get_node("Requirements")
	craft_button = get_node("Craft_button")
	
@warning_ignore("unused_parameter")
func update_craftables(inventory : InventoryHandler):
	pass


func _on_craft_button_pressed() -> void:
	crafting.craft(recipe)
