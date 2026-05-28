extends Panel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween = get_tree().create_tween()
	#tween.tween_property(Panel, "position", ,0.5)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
