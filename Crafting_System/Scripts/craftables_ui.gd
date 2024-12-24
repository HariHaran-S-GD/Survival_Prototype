class_name  Craftables_ui
extends Panel
var item_icon : TextureRect
var requirements_text : Label
var craftable_item_text :Label
var craft_button : Button
var recipe : Craftables
var crafting


func get_nodes():
	item_icon = get_node("ItemIcon")
	requirements_text = get_node("Requirements")
	craft_button = get_node("Craft_button")
	craftable_item_text= get_node("Label")
	

func update_craftables(inventory : InventoryHandler):
	var can_craft = true
	for req in recipe.requirements:
		if inventory.get_number_of_item(req.item) < req.Quantity:
			can_craft = false
			break
	get_nodes()
	craft_button.visible = can_craft
	craftable_item_text.text = recipe.item.Itemname
	craftable_item_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT # Center horizontally
	craftable_item_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER # Align to the bottom
	var text_output = ""
	for req in recipe.requirements:
	# Pad the item name and quantity to ensure alignment
		text_output += req.item.Itemname.rpad(8) + " x " + str(req.Quantity).rpad(4)
	# Add a newline after every two items to align them in rows
		if (recipe.requirements.find(req) + 1) % 2 == 0:
			text_output += "\n"
	requirements_text.text = text_output
	item_icon.texture = recipe.item.Icon

func _on_craft_button_pressed() -> void:
	crafting.craft(recipe)
