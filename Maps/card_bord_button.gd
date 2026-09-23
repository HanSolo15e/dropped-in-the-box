extends TextureButton
class_name cardbordbuttonload

@export var levelstring: String
@export var focus: bool
@export var GameLoaderPrams: Dictionary

var had_focus: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not had_focus:
		if GameLoader.is_gamepad and focus:
			grab_focus()
			had_focus = true

		
	
		


func _on_pressed() -> void:
	for key in GameLoaderPrams:
		GameLoader.set(key, GameLoaderPrams[key])
	
	GameLoader.load_level(levelstring,"res://Maps/Loading.tscn")
