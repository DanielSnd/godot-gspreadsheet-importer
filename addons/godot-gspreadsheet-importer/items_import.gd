@tool
extends Node
@onready var data_importer: DataImporter= $".."

# Called when the node enters the scene tree for the first time.
func _ready():
	# We connect the imported data signal to receive the imported data here.
	data_importer.imported_data.connect(on_imported_data)

func on_imported_data(import_type: String, data: Array):
	# The signal could be meant for another sheet, so we'll check if it's the right type
	if import_type != "Items":
		return
	
	# We then delete all the current resources in our items folder.
	for file in DirAccess.get_files_at("res://resources/items/"):
		var file_full_path:= "res://resources/items/{0}".format({0:file})
		DirAccess.remove_absolute(file_full_path)
		
	# And then we import the new entries.
	for entry in data:
		import_data(entry)
	
func import_data(data: Dictionary):
	# First we'll try to get the id, if the id is empty or the dictionary doesn't contain ID we'll return
	if not data.has("ID"):
		return
	var item_id: String = data["ID"]
	if item_id == null or item_id == "":
		return
		
	# We create a new instance of the resource and parse the info from the dictionary.
	var new_item: ItemData = ItemData.new()
	new_item.id = item_id
	new_item.hashId = new_item.id.hash()
	new_item.name = data["Name"]
	new_item.description = data["Description"]
	new_item.type = data["Type"]
	new_item.sprite_path = "res://resources/icons/{0}.png".format({0:data["Sprite"]})
	new_item.weight = float(data["Weight"])
	new_item.sell_price = int(data["SellPrice"])
	new_item.max_stack = int(data["MaxStack"])
	
	# We can also have a dictionary inside of our data for extra information.
	# I'm writing that in json on my spreadsheet
	var extra_info_string = data["ExtraInfo"]
	if extra_info_string != null && extra_info_string != "":
		new_item.extra_info = JSON.parse_string(extra_info_string) # Returns null if parsing failed.
		
	# Then we create a new file path
	var filePath: String = "res://resources/items/{0}.tres".format({0:item_id})
	
	# We have to take over the path, otherwise the editor won't update the resources info until restart.
	new_item.take_over_path(filePath)
	
	# Now we save the resource
	var result = ResourceSaver.save(new_item,filePath)
	if result != 0:
		print("Something goes wrong with {0}!".format({0:data}))
