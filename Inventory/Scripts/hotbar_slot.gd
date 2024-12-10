extends Control
class_name HotbarSlot

signal OnItemDroppedToHotbar(fromSlotID, toSlotID)

@export var EquippedHighlight: Panel
@export var IconSlot: TextureRect
@export var QuantityLabel: Label
@onready var inventory_ui: InventoryHandler =$"../../../../.."
var HotbarSlotID: int = -1
var SlotFilled: bool = false
var SlotData: Itemdata

func FillSlot(data: Itemdata):
	SlotData = data
	if SlotData != null:
		SlotFilled = true
		IconSlot.texture = data.Icon
		QuantityLabel.text = str(data.Quantity)
	else:
		SlotFilled = false
		IconSlot.texture = null
		QuantityLabel.text = ""

# Handle drag preview from inventory
func _get_drag_data(_at_position: Vector2) -> Variant:
	if SlotFilled:
		var preview: TextureRect = TextureRect.new()
		preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		preview.size = IconSlot.size
		preview.pivot_offset = IconSlot.size / 2.0
		preview.rotation = 2.0
		preview.texture = IconSlot.texture
		set_drag_preview(preview)
		return {"Type": "Item", "ID": HotbarSlotID, "Source": "Hotbar"}
	else:
		return false

# Handle dropping item from inventory to hotbar
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data["Source"] == "Inventory":
		# Swap or assign item to the hotbar slot
		var inventory_slot = inventory_ui.InventorySlots[data["ID"]]
		FillSlot(inventory_slot.SlotData)
		inventory_slot.FillSlot(null, false)  # Remove item from inventory slot
		OnItemDroppedToHotbar.emit(data["ID"], HotbarSlotID)
