extends Area3D
class_name InteractionHandler

signal OnItemPickedUp(Itemdata)

@export var ItemTypes: Array[Itemdata] = []
@export var pickup_text_label: Label3D  # Assign a Label3D node for displaying "F to PICKUP".
@export var camera: Camera3D  # Assign the main camera in the scene.

var NearbyBodies: Array[InteractableItem] = []

func _ready():
	# Hide the pickup text initially.
	if pickup_text_label:
		pickup_text_label.visible = false

func _process(_delta: float) -> void:
	# Continuously update the pickup text visibility.
	_update_pickup_text()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pickup"):
		PickupNearbyItem()

func PickupNearbyItem():
	var nearestItem: InteractableItem = null
	var nearestItemDistance: float = INF

	# Find the nearest interactable item.
	for item in NearbyBodies:
		if not item.is_picked:
			var distance = item.global_position.distance_to(global_position)
			if distance < nearestItemDistance:
				nearestItemDistance = distance
				nearestItem = item

	# Process the nearest item.
	if nearestItem != null and not nearestItem.is_picked:
		nearestItem.is_picked = true  # Mark as picked
		nearestItem.queue_free()
		NearbyBodies.erase(nearestItem)
		var itemPrefab = nearestItem.scene_file_path
		for item_data in ItemTypes:
			if item_data.ItemModel != null and item_data.ItemModel.resource_path == itemPrefab:
				print("Item ID: %s, Item Name: %s" % [item_data, item_data.Itemname])
				OnItemPickedUp.emit(item_data)
				return
		printerr("Item not found!")
	else:
		print("No interactable item nearby.")

func _on_body_entered(body: Node3D):
	if body is InteractableItem:
		body.GainFocus()
		if not NearbyBodies.has(body):
			NearbyBodies.append(body)

func _on_body_exited(body: Node3D):
	if body is InteractableItem:
		body.LoseFocus()
		NearbyBodies.erase(body)

# Updates the visibility and position of the "F to PICKUP" text based on camera view.
func _update_pickup_text():
	if NearbyBodies.size() > 0:
		var nearestItem: InteractableItem = null
		var nearestDistance: float = INF

		# Find the nearest item to position the label.
		for item in NearbyBodies:
			var distance = item.global_position.distance_to(global_position)
			if distance < nearestDistance:
				nearestDistance = distance
				nearestItem = item

		if nearestItem and pickup_text_label:
			# Match the nearest item's prefab with the ItemTypes data to get its name.
			var item_name = "Unknown Item"
			for item_data in ItemTypes:
				if item_data.ItemModel and item_data.ItemModel.resource_path == nearestItem.scene_file_path:
					item_name = item_data.Itemname
					break

			# Now, use the item's name in the label.
			pickup_text_label.text = "[F]"+" "+ item_name

			# Adjust the position for visibility.
			pickup_text_label.global_position = nearestItem.global_position + Vector3(0, 0.8, 0)  # Adjust as needed.
			pickup_text_label.visible = true
		else:
			# Hide the label if no items are nearby.
			pickup_text_label.visible = false
	else:
		# Hide the label if no items are nearby.
		if pickup_text_label:
			pickup_text_label.visible = false #add that function to this
