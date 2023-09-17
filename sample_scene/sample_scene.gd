extends Node2D

@onready var sprite_2d = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# Here we fetch the item branch from the database
	var branch_item := Database.get_item("branch")
	# Here we set the icon from the item branch to our sprite 2d
	sprite_2d.texture = branch_item.get_texture()
