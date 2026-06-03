extends Control
var CusorPosition: Vector2  = Vector2(200,200)
var ButtonFlip: bool = false
# Called when the node enters the scene tree for the first time.
@onready var panel: Panel = $"../Control/Panel"
@export var StickResponseCurve: Curve
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if GameLoader.is_gamepad:
		self.show()
		var safe_screen_size = get_viewport_rect().size
	
		var RightStick: Vector2 = Input.get_vector("RightStickLeft","RightStickRight","RightStickUp","RightStickDown")
		
		if RightStick.length() > 0.1:
			var raw_strength = RightStick.length()
			var curve_strength = StickResponseCurve.sample(raw_strength)
			CusorPosition += ((RightStick.normalized() * curve_strength) * 0.15) / delta
		
		CusorPosition = CusorPosition.clamp(Vector2(0, 0), Vector2(safe_screen_size.x, safe_screen_size.y))
	
		self.position = CusorPosition
	else: 
		self.hide()	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("GamePadGrab"):
		click()
		
func click():
	if not panel.visible:
		var a = InputEventMouseButton.new()
		var transform: Transform2D = self.get_viewport_transform()
		a.position = get_viewport().get_final_transform() * global_position
		a.button_index = MOUSE_BUTTON_LEFT
		ButtonFlip = !ButtonFlip
		a.pressed = ButtonFlip
		Input.parse_input_event(a)
		
