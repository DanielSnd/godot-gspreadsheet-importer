@tool
extends EditorPlugin

# A class member to hold the dock during the plugin life cycle.
var dock
const AUTOLOAD_DATABASE_NAME = "Database"


func _enter_tree():
	dock = preload("res://addons/godot-gspreadsheet-importer/spreadsheet_importer_dock.tscn").instantiate()
	# Add the loaded scene to the docks.
	add_control_to_dock(DOCK_SLOT_LEFT_UL, dock)
	# Autoload the database script.
	add_autoload_singleton(AUTOLOAD_DATABASE_NAME, "res://database/Database.gd")

func _exit_tree():
	# Clean-up of the plugin goes here.
	# Remove database auto load
	remove_autoload_singleton(AUTOLOAD_DATABASE_NAME)
	# Remove the dock.
	remove_control_from_docks(dock)
	# Erase the control from the memory.
	dock.free()
