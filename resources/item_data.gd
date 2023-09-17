extends Resource
class_name ItemData

@export var id: String
@export var hashId: int
@export var name: String
@export_multiline var description: String
@export var type: String = "Misc"
@export var weight: float = 0.1
@export var sprite_path: String
@export var sell_price: int = 1
@export var max_stack: int = 1
@export var extra_info: Dictionary
var error:bool = false
var loaded_texture: Texture2D

func get_texture() -> Texture2D:
	if loaded_texture != null:
		return loaded_texture
	if sprite_path != null && sprite_path != "":
		loaded_texture = ResourceLoader.load(sprite_path) as Texture2D
		if loaded_texture != null:
			return loaded_texture
	create_empty_texture()
	return loaded_texture

func create_empty_texture():
	var image := Image.create(1,1,false,Image.FORMAT_RGBA8)
	image.set_pixel(0, 0, Color(0, 0, 0, 0))
	var texture := ImageTexture.new()
	loaded_texture = ImageTexture.create_from_image(image) as Texture2D
