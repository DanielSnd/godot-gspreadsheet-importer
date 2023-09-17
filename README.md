# Godot Google Spreadsheets Importer
This is an addon to assist with importing a game's database from Gooogle Spreadsheets. It gives you a way to create resource files for each row of the spreadsheet, and a way to retrieve those from a database autoload given a string id.

## Example Gif
![Example](https://github.com/DanielSnd/godot-gspreadsheet-importer/blob/main/readme_images/GodotDatabaseImporter.gif?raw=true)

## Setting up your spreadsheet

[This is my example spreadsheet](https://docs.google.com/spreadsheets/d/1O2IiDy7HqCbpHf4T6UYuBG8vl7J5Ykf-wY-35PZe_lQ/edit?usp=sharing). Feel free to make a copy and edit it.

![Spreadsheet](https://github.com/DanielSnd/godot-gspreadsheet-importer/blob/main/readme_images/spreadsheet.png?raw=true)

For this example I show how to reference a **sprite icon**, use **strings**, **ints** and **floats**, and also have a **dictionary** with extra information that can be written in **json** on the spreadsheet.

## Share your spreadsheet

For the importer to be able to access the spreadsheet it needs to be set up to share in a way that anyone with a link can view.

![Share](https://github.com/DanielSnd/godot-gspreadsheet-importer/blob/main/readme_images/share.png?raw=true)

![Share](https://github.com/DanielSnd/godot-gspreadsheet-importer/blob/main/readme_images/share_anyone_with_the_link.png?raw=true)

## Import the addon

Copy the files to a godot project, on Project Settings -> Addons enable the addon.

![Enable the addon](https://github.com/DanielSnd/godot-gspreadsheet-importer/blob/main/readme_images/plugin_enable.png?raw=true)

Enabling the addon automatically also autoloads the Database.gd script

![Autoload Database](https://github.com/DanielSnd/godot-gspreadsheet-importer/blob/main/readme_images/autoload_database.png?raw=true)

## Set your spreadsheet id on the importer

The spreadsheet ID needs to be set on "res://addons/godot-gspreadsheet-importer/**data_importer.gd**"

![Share](https://github.com/DanielSnd/godot-gspreadsheet-importer/blob/main/readme_images/set_spreadsheet_id.png?raw=true)

## Importing different sheets

To make it easier to add new importers I made it so it will look at all the import button's text for the buttons under the "Buttons" container, if a button has its text like "Import Something" it will consider it a import button and connect it to the importer. the "Something" in this case will be the name of the Sheet it should try to import. In the case of the example it's a sheets called "Items" so I named the button text to be "Import Items"

![Share](https://github.com/DanielSnd/godot-gspreadsheet-importer/blob/main/readme_images/import_button.png?raw=true)

Look at the items_import.gd file, that's the importer for the Items sheet. *"res://addons/godot-gspreadsheet-importer/items_import.gd"*

You need to create a importer script for each sheet you want to import, use that one as an example. Place it on a node right under the Importer dock scene (*res://addons/godot-gspreadsheet-importer/spreadsheet_importer_dock.tscn*) so it can more easily connect to the importer signal.

```gdscript
# The tool at the start let's the script work when we're not playing the game
@tool
extends Node
# Here we can easily get the Data Importer script reference since it's right above this node in the hierarchy.
@onready var data_importer: DataImporter= $".."

# Ready is called when the node enters the scene tree for the first time.
func _ready():
	# So here we connect the imported data signal to receive the imported data here.
	data_importer.imported_data.connect(on_imported_data)

# This function will receive from the signal a string, which will correspond to the Sheet Name if you've set up the button text correctly, in this case "Import Items" this string will be "Items"
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
```
