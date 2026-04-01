extends TextureButton
class_name cardbordbuttonload

@export var levelstring: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	GameLoader.load_level(levelstring,"res://Maps/Loading.tscn")
