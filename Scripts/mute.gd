extends TextureButton
@onready var music: AudioStreamPlayer = $"../Music"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.button_pressed = GameLoader.MuteSound
	music.stream_paused = GameLoader.MuteSound


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	music.stream_paused = not music.stream_paused
	GameLoader.Set_Mute(not GameLoader.MuteSound)
	
