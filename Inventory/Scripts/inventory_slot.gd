extends Control
class_name InventorySlot

signal OnItemEquiped(SlotID)
signal OnItemDropped(fromSlotID, toSlotID)

@export var EquippedHighlight: Panel
@export var IconSlot: TextureRect
@export var QuantityLabel: Label  # Added to display quantity

var InventorySlotID: int = -1
var SlotFilled: bool = false

var SlotData: Itemdata

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
			OnItemEquiped.emit(InventorySlotID)

func FillSlot(data: Itemdata, equipped: bool):
	SlotData = data
	EquippedHighlight.visible = equipped
	if SlotData != null:
		SlotFilled = true
		IconSlot.texture = data.Icon
		QuantityLabel.text = str(data.Quantity)
	else:
		SlotFilled = false
		IconSlot.texture = null
		QuantityLabel.text = ""

func UpdateSlotDisplay():
	if SlotFilled:
		QuantityLabel.text = str(SlotData.Quantity)
	else:
		QuantityLabel.text = ""

func _get_drag_data(_at_position: Vector2) -> Variant:
	if SlotFilled:
		var preview: TextureRect = TextureRect.new()
		preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		preview.size = IconSlot.size
		preview.pivot_offset = IconSlot.size / 2.0
		preview.rotation = 2.0
		preview.texture = IconSlot.texture
		set_drag_preview(preview)
		return {"Type": "Item", "ID": InventorySlotID, "Source": "Inventory"}
	else:
		return false

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data["Type"] == "Item"

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	OnItemDropped.emit(data["ID"], InventorySlotID)
