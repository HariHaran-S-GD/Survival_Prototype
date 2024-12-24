extends Resource
class_name Itemdata

@export var Itemname: String                # Name of the item
@export var ItemModel: PackedScene          # 3D model of the item
@export var Icon: Texture2D                 # Icon for inventory UI
@export var MaxStack: int = 99              # Maximum number of items that can stack
@export var Stackable: bool = true          # Indicates if the item is stackable
@export var Quantity: int = 1               # Current quantity of the item
@export var Droppable: bool = false
