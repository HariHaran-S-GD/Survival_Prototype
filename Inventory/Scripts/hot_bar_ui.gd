extends Control
class_name Hotbar

@export var HotbarSlotsCount: int = 5  # Adjust the number of slots as needed
@export var HotbarSlots: Array[HotbarSlot] = []
  # Assign the slot ID to each HotbarSlot

func MoveItemToHotbar(item_data: Itemdata, slot_id: int):
	if slot_id >= 0 and slot_id < HotbarSlots.size():
		HotbarSlots[slot_id].FillSlot(item_data)  # Store the array index to the slot
