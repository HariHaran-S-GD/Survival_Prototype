extends Control
class_name InventoryHandler

@export var PlayerBody: CharacterBody3D
@export_flags_3d_physics var CollisionMask: int
@export var ItemSlotsCount: int = 20
@export var InventoryGrid: GridContainer
@export var InventorySlotPrefab: PackedScene = preload("res://Inventory/Scenes/InventorySlot.tscn")
@onready var label: Label = $Panel/Label
@onready var ui_switch: Control = $"../UI_Switch"
@onready var crafting_window: Panel = $"../Crafting_UI/CraftingWindow"
@onready var crafting_ui: Control = $"../Crafting_UI"


var InventorySlots: Array[InventorySlot] = []
var Inventory_toggle: bool = false
var EquippedSlot: int = -1

func _ready():
	self.visible = false
	ui_switch.visible = false
	crafting_window.visible = false
	crafting_ui.visible = false
	# Initialize inventory slots
	for i in range(ItemSlotsCount):
		var slot = InventorySlotPrefab.instantiate() as InventorySlot
		InventoryGrid.add_child(slot)
		slot.InventorySlotID = i
		slot.OnItemDropped.connect(ItemDroppedOnSlot.bind())
		slot.OnItemEquiped.connect(ItemEquipped.bind())
		InventorySlots.append(slot)
		

			
func PickupItem(item: Itemdata):
	var remaining_quantity = item.Quantity
	# Check for existing stackable items
	for slot in InventorySlots:
		if slot.SlotFilled and slot.SlotData.Itemname == item.Itemname and slot.SlotData.Stackable:
			var total_quantity = slot.SlotData.Quantity + remaining_quantity
			if total_quantity <= slot.SlotData.MaxStack:
				slot.SlotData.Quantity = total_quantity
				slot.UpdateSlotDisplay()
				return
			else:
				remaining_quantity = total_quantity - slot.SlotData.MaxStack
				slot.SlotData.Quantity = slot.SlotData.MaxStack
				slot.UpdateSlotDisplay()
	# Place remaining quantity in a new slot
	for slot in InventorySlots:
		if not slot.SlotFilled:
			var new_item_data = Itemdata.new()
			new_item_data.Itemname = item.Itemname
			new_item_data.ItemModel = item.ItemModel
			new_item_data.Icon = item.Icon
			new_item_data.MaxStack = item.MaxStack
			new_item_data.Stackable = item.Stackable
			new_item_data.Quantity = min(remaining_quantity, item.MaxStack)
			slot.FillSlot(new_item_data, false)
			remaining_quantity -= new_item_data.Quantity
			if remaining_quantity <= 0:
				return

	if remaining_quantity > 0:
		print("Inventory full or unable to add item")

func ItemEquipped(slotID: int):
	if EquippedSlot != -1:
		InventorySlots[EquippedSlot].EquippedHighlight.visible = false

	if slotID != EquippedSlot and InventorySlots[slotID].SlotData != null:
		InventorySlots[slotID].EquippedHighlight.visible = true
		EquippedSlot = slotID
	else:
		EquippedSlot = -1

func ItemDroppedOnSlot(fromSlotID: int, toSlotID: int):
	if EquippedSlot != -1:
		if EquippedSlot == fromSlotID:
			EquippedSlot = toSlotID
		elif EquippedSlot == toSlotID:
			EquippedSlot = fromSlotID

	var toSlotItem = InventorySlots[toSlotID].SlotData
	var fromSlotItem = InventorySlots[fromSlotID].SlotData

	InventorySlots[toSlotID].FillSlot(fromSlotItem, EquippedSlot == toSlotID)
	InventorySlots[fromSlotID].FillSlot(toSlotItem, EquippedSlot == fromSlotID)


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data["Type"] == "Item"

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if EquippedSlot == data["ID"]:
		EquippedSlot = -1

	var slotID = data["ID"]
	var item_data = InventorySlots[slotID].SlotData
	var quantity_to_drop = 1  # Drop one item at a time
	var newItem = item_data.ItemModel.instantiate() as Node3D
	PlayerBody.get_parent().add_child(newItem)
	newItem.global_position = GetWorldMousePosition()

	if item_data.Stackable:
		item_data.Quantity -= quantity_to_drop
		InventorySlots[slotID].UpdateSlotDisplay()

		if item_data.Quantity <= 0:
			InventorySlots[slotID].FillSlot(null, false)
	else:
		InventorySlots[slotID].FillSlot(null, false)

func GetWorldMousePosition() -> Vector3:
	var mousePos = get_viewport().get_mouse_position()
	var cam = get_viewport().get_camera_3d()
	var ray_start = cam.project_ray_origin(mousePos)
	var ray_end = ray_start + cam.project_ray_normal(mousePos) * cam.global_position.distance_to(PlayerBody.global_position) * 2.0
	var world3d: World3D = PlayerBody.get_world_3d()
	var space_state = world3d.direct_space_state

	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end, CollisionMask)

	var results = space_state.intersect_ray(query)
	if results:
		return results["position"] as Vector3 + Vector3(0.0, 0.5, 0.0)
	else:
		return ray_start.lerp(ray_end, 0.5) + Vector3(0.0, 0.5, 0.0)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		Inventory_toggle = not Inventory_toggle
		self.visible = Inventory_toggle
	if Inventory_toggle:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		ui_switch.visible = true
		
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		ui_switch.visible = false
		crafting_window.visible = false
		crafting_ui.visible = false
		
func RemoveItem(item: Itemdata, quantity: int) -> bool:
	"""
	Removes a specified quantity of an item from the inventory.
	Returns true if the item was successfully removed, false otherwise.
	"""
	for slot in InventorySlots:
		if slot.SlotFilled and slot.SlotData.Itemname == item.Itemname:
			if slot.SlotData.Quantity >= quantity:
				slot.SlotData.Quantity -= quantity
				slot.UpdateSlotDisplay()

				if slot.SlotData.Quantity <= 0:
					slot.FillSlot(null, false)  # Clear the slot if quantity becomes 0

				return true  # Item successfully removed
			else:
				# Not enough quantity in this slot
				quantity -= slot.SlotData.Quantity
				slot.FillSlot(null, false)  # Clear this slot
				slot.UpdateSlotDisplay()
				
				if quantity <= 0:
					return true  # Item successfully removed
	return false  # Not enough items found to fulfill the request
	
	
func AddItem(item: Itemdata, quantity: int) -> bool:
	"""
	Adds a specified quantity of an item to the inventory.
	Returns true if the item was successfully added, false otherwise.
	"""
	var remaining_quantity = quantity

	# Try to add to existing stackable slots first
	for slot in InventorySlots:
		if slot.SlotFilled and slot.SlotData.Itemname == item.Itemname and slot.SlotData.Stackable:
			var available_space = slot.SlotData.MaxStack - slot.SlotData.Quantity
			if available_space > 0:
				var to_add = min(available_space, remaining_quantity)
				slot.SlotData.Quantity += to_add
				slot.UpdateSlotDisplay()
				remaining_quantity -= to_add

				if remaining_quantity <= 0:
					return true  # Fully added

	# Try to add to empty slots for remaining quantity
	for slot in InventorySlots:
		if not slot.SlotFilled:
			var new_item_data = item.duplicate() as Itemdata
			new_item_data.Quantity = min(remaining_quantity, item.MaxStack)
			slot.FillSlot(new_item_data, false)
			remaining_quantity -= new_item_data.Quantity

			if remaining_quantity <= 0:
				return true  # Fully added

	# If there's still remaining quantity, inventory is full
	return remaining_quantity == 0
