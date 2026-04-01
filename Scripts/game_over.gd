extends Control
@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var label: Label = $CardBordButton/Label
@onready var rich_text_label_2: RichTextLabel = $RichTextLabel2
@onready var card_bord_button: cardbordbuttonload = $CardBordButton
@onready var texture_rect: TextureRect = $TextureRect
@onready var stats_box: TextureRect = $StatsBox

@onready var boxes_completed_value: Label = $StatsBox/BoxesCompletedValue
@onready var box_fill_value: Label = $StatsBox/BoxFillValue
@onready var score_text_value: Label = $StatsBox/ScoreTextValue
@onready var win_sound: AudioStreamPlayer = $WinSound
@onready var lose_sound: AudioStreamPlayer = $LoseSound


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween = get_tree().create_tween()
	
	var tweenbase = stats_box.position
	stats_box.position = stats_box.position - Vector2(0,700)
	
	
	if GameLoader.FaliedGame:
		lose_sound.play()
		rich_text_label.text = "[wave amp=50.0 freq=5.0]YOU ARE FIRED!![/wave]"
		rich_text_label_2.text = "You did not pack enough boxes in time."
	elif GameLoader.LostItem:
		lose_sound.play()
		rich_text_label.text = "[wave amp=50.0 freq=5.0]YOU ARE FIRED!![/wave]"
		rich_text_label_2.text = "Don't lose merchandise"
		lose_sound.play()
	elif GameLoader.FailedPercent:
		rich_text_label.text = "[wave amp=50.0 freq=5.0]YOU ARE FIRED!![/wave]"
		rich_text_label_2.text = "Your boxes were to empty."
	else:
		win_sound.play()
		if GameLoader.Lastlevel:
			rich_text_label.text = "[wave amp=50.0 freq=5.0]SHIFT COMPLETE!! STILL FIRED!!![/wave]"
			label.text = "Play Again"
			
			rich_text_label_2.text = "Your did it! but... robots are cheaper..."
		else:
			rich_text_label.text = "[wave amp=50.0 freq=5.0]SHIFT COMPLETE[/wave]"
			label.text = "NEXT SHIFT"
			rich_text_label_2.text = "Your made it!"
	
	tween.tween_property(stats_box, "position", tweenbase,0.5).set_trans(Tween.TRANS_BOUNCE)
	
	tween.tween_property(score_text_value, "text", str(GameLoader.score),0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(boxes_completed_value, "text", str(GameLoader.boxescomplete),0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(box_fill_value, "text", str(GameLoader.score / max(0.001,GameLoader.boxescomplete)) + "%",0.5).set_trans(Tween.TRANS_SINE)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
