extends Node

var ItemsPath: Dictionary = {}
var Items: Dictionary = {}
var error_item: ItemData

# Called when the node enters the scene tree for the first time.
func _ready():
	fill_up_item_dictionary()
	
func get_item(id: String) -> ItemData:
	var capitalizedId: String = id.capitalize()
	var find_item: ItemData = error_item
	if not Items.has(capitalizedId):
		if ItemsPath.has(capitalizedId):
			find_item = ResourceLoader.load(ItemsPath[capitalizedId], "ItemData", ResourceLoader.CACHE_MODE_REUSE) as ItemData
			if find_item != null:
				Items[capitalizedId] = find_item
	else:
		find_item = Items[capitalizedId]
	return find_item
	
func fill_up_item_dictionary():
	error_item = ItemData.new()
	error_item.error = true
	for file in DirAccess.get_files_at("res://resources/items/"):
		var file_name_only:= file.split(".")[0]
		var file_full_path:= "res://resources/items/{0}".format({0:file})
		ItemsPath[file_name_only.capitalize()] = file_full_path
	pass
	
