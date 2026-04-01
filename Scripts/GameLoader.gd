extends Node

var _target_scene_path: String = ""
var _is_loading: bool = false

var FaliedGame: bool = false
var score: = 0
var NumBoxes: = 1
var LastShiftNum: int = 0
var NextShiftNumber: int = 0
var PercentToWin: int = 20
var FailedPercent: bool = false
var LostItem: bool = false
var Lastlevel: bool = false
var boxescomplete: int = 0

func gameover(success: bool):
	if success:
			NextShiftNumber += 1 
	else:
		# ig im adding a coment
		NextShiftNumber = 0
		print("Player failed. Staying on shift: ", NextShiftNumber)
		
	if Lastlevel:
		NextShiftNumber = 0
		
	

# save for laterrr GameLoader.load_level("res://levels/big_level.tscn", "res://ui/simple_intermission.tscn")
func load_level(target_path: String, intermediate_path: String):
	_target_scene_path = target_path
	_is_loading = true
	
	# Start background thread
	ResourceLoader.load_threaded_request(target_path)
	
	# swaps scene ig
	get_tree().change_scene_to_file(intermediate_path)

func _process(_delta: float) -> void:
	if not _is_loading:
		return
		
	var status = ResourceLoader.load_threaded_get_status(_target_scene_path)
	
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		# Get the loaded resource and swap
		var new_scene = ResourceLoader.load_threaded_get(_target_scene_path)
		get_tree().change_scene_to_packed(new_scene)
		_is_loading = false
		
	elif status == ResourceLoader.THREAD_LOAD_FAILED:
		push_error("Failed to load level: " + _target_scene_path)
		_is_loading = false
