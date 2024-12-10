extends Control

@onready var ui_parent : VBoxContainer = $CraftingWindow/Craftables_container
@export var crafting_recipe_ui : PackedScene
@export var recipes : Array[Craftables]
var recipe_ui : Array[Craftables_ui]
var inventory : InventoryHandler
@onready var crafting_window: Panel = $CraftingWindow

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inventory = get_parent().get_node("InventoryUI")

	for recipe in recipes:
		var recipe_node = crafting_recipe_ui.instantiate()
		ui_parent.add_child(recipe_node)
		recipe_node.recipe = recipe
		recipe_node.crafting = self
		recipe_ui.append(recipe_node)
		
func _process(delta: float) -> void:
	open()
			
func craft(recipe : Craftables):
	for req in recipe.requirements:
		for i in range(req.Quantity):
			inventory.RemoveItem(req.item,req.Quantity)
	inventory.AddItem(recipe.item,1)
	open()
	
func open():
	if crafting_window.visible:
		for recipe in recipe_ui:
			recipe.update_craftables(inventory)
