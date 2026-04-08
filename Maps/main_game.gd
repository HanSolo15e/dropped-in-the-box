extends Node3D

#this code made me not want to kill myself... i made me see life as amzing and fuffiling 
#i got guns in my head

var xr_interface: XRInterface

@onready var conveyer_area: Area3D = $ConveyerArea
@onready var box_play_pos: Node3D = $BoxPlayPos
@onready var score_lable: Label = $Control/ScoreLable
@onready var box_lable: Label = $Control/BoxLable
@onready var box_spawn: Node3D = $BoxSpawn
@onready var item_spawn_point: Node3D = $ItemSpawnPoint
@onready var game_timer: Timer = $GameTimer
@onready var panel: Panel = $Control/Panel
@onready var warning: Panel = $Control/Warning
@onready var box_fill_value: Label = $Control/StatsBox/BoxFillValue
@onready var boxes_completed_value: Label = $Control/StatsBox/BoxesCompletedValue
@onready var shift_num_value: Label = $Control/StatsBox/ShiftNumValue

const ShipingItem1 = preload("res://Items/shiping_item1.tscn")
const SHIPPING_BOX = preload("uid://cutejoujyxjam")

var Gameint: bool = false
@export var ItemsOnConveyer: Array = []
@export var BaseItemNum: int = 5 # Used for both initial spawn AND the max limit
@export var ShiftNumber: int = 0
@export var shiftlength: int = 0
@export var RoundBoxes:int = 10
@export var PercentToWin: int = 20

var shifttime: float = 10
var CurBox: Shipping_Box = null
var BoxArea: Area3D
var BoxFailArea: Area3D
var VolumeOfItems: float = 0
var Score:int = 0
var BoxScore:float = 0
var BoxesCompleted:int = 0
var BoxFailed: bool = false

var boxdebounce: bool = false

var LostItem: bool = false


signal ReplenishItems(Num: int)

signal BoxStateChange(newstate: Shipping_Box.BoxState)

signal BoxScored(Failed: bool, points: int)


func _ready() -> void:
	#OpenXR and VR stuff
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialized successfully")

		# Turn off v-sync!
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

		# Change our main viewport to output to the HMD
		get_viewport().use_xr = true
	else:
		print("OpenXR not initialized, please check if your headset is connected")
	
	
	
	
	conveyer_area.AddBoxToArray.connect(addtoarray)
	Init_Game() 
	
# this is hear caus git hub stupid
func addtoarray(Item):
	ItemsOnConveyer.append(Item)
	
func SetShift(day: int):
	match day:
		0:
			BaseItemNum = 10
			shiftlength = 60
			RoundBoxes = 5
			PercentToWin = 50
		1:
			BaseItemNum = 10
			shiftlength = 70
			RoundBoxes = 5
			PercentToWin = 70
		2:
			BaseItemNum = 10
			shiftlength = 100
			RoundBoxes = 5
			PercentToWin = 70
		3:
			BaseItemNum = 10
			shiftlength = 60
			RoundBoxes = 10
			PercentToWin = 25
		4:
			BaseItemNum = 10
			shiftlength = 60
			RoundBoxes = 6
			PercentToWin = 60
		5:
			BaseItemNum = 10
			shiftlength = 160
			RoundBoxes = 14
			PercentToWin = 50
			
			
func Init_Game():
	
	game_timer.timeout.connect(timerout)
	ShiftNumber = GameLoader.NextShiftNumber
	SetShift(ShiftNumber)
	shift_num_value.text = str(ShiftNumber)
	box_fill_value.text = str(PercentToWin) + "%"
	boxes_completed_value.text = str(RoundBoxes)
	game_timer.wait_time = shiftlength
	
	box_lable.text = str(RoundBoxes - BoxesCompleted)
	score_lable.text = "0%"
	
	ReplenishItems.emit(BaseItemNum)
	SpawnBox()	
	await conveyer_area.TaskFinished
	game_timer.start()
	panel.hide()
	
	
	Gameint = true
	
	
func timerout():
	GameOver(true)


func _process(_delta: float) -> void:
	
	
	
	
	if Gameint and BoxesCompleted >= RoundBoxes:
			GameOver(false)

	if Gameint:
		
		 
		var itemoutside: bool = false
		
		for i in BoxFailArea.get_overlapping_bodies():
			if i is Shipping_Item:
				itemoutside = true
				break
				
		if itemoutside:
			warning.show()
		else: 
			warning.hide()
		
		if BoxesCompleted <= 0:
			score_lable.text = "0%"
		else:
			score_lable.text = str(Score / BoxesCompleted) + "%"
			
		box_lable.text = str(RoundBoxes - BoxesCompleted)
		
		
		if Input.is_action_just_pressed("Next_Box"):
			if not boxdebounce:
				boxdebounce = true
				ScoreItems()
				BoxStateChange.emit(Shipping_Box.BoxState.END)
				
				
				if CurBox:
					BoxesCompleted += 1
					await CurBox.TaskDone
					print("Box has finished moving to the end.")
					killboxitems()
					ReplenishItems.emit(BaseItemNum - ItemsOnConveyer.size())
					SpawnBox()
					
				boxdebounce = false

func GameOver(timed_out: bool):
	Gameint = false 
	KillAllItems()
	
	
	var avg_fullness = float(Score) / RoundBoxes
	
	var did_win = (avg_fullness >= PercentToWin) and (not timed_out)
	
	GameLoader.score = Score
	GameLoader.NumBoxes = RoundBoxes
	GameLoader.PercentToWin = PercentToWin
	GameLoader.FaliedGame = timed_out 
	GameLoader.FailedPercent = (avg_fullness < PercentToWin) 
	GameLoader.LostItem = LostItem
	GameLoader.boxescomplete = BoxesCompleted
	
	if ShiftNumber == 5:
		GameLoader.Lastlevel = true
	
	else:
		GameLoader.Lastlevel = false
	GameLoader.gameover(did_win)
	
	GameLoader.load_level("res://Maps/GameOver.tscn", "res://Maps/Loading.tscn")

func ScoreItems():
	BoxFailed = false
	VolumeOfItems = 0
	for i in BoxArea.get_overlapping_bodies():
		if i is Shipping_Item:
			VolumeOfItems += i.Size
			
	for i in BoxFailArea.get_overlapping_bodies():
		if i is Shipping_Item:
			BoxFailed = true
			
	
	if BoxFailed == false:
		Score += 100*(VolumeOfItems / CurBox.BoxSize)
		BoxScored.emit(false, 100*(VolumeOfItems / CurBox.BoxSize))
	else:
		BoxScored.emit(true, 0)
		
	print(VolumeOfItems)
	

func killboxitems():
	for i in BoxArea.get_overlapping_bodies():
		if i is Shipping_Item:
			KillItem(i)
	for i in BoxFailArea.get_overlapping_bodies():
		if i is Shipping_Item:
			KillItem(i)
			



func SpawnBox():
	if CurBox:
		CurBox.queue_free()
		CurBox = null
	
	var BoxToSpawn = SHIPPING_BOX.instantiate()
	BoxToSpawn.main_game = self
	BoxToSpawn.PlayPosNode = box_play_pos
	box_spawn.add_child(BoxToSpawn)
	CurBox = BoxToSpawn
	BoxArea = CurBox.area_3d
	BoxFailArea = CurBox.area_3d_2
	BoxStateChange.emit(Shipping_Box.BoxState.USING)
	
	
func KillItem(ItemTokill: Node3D = null):
	var item_index: int = -1
	
	
	if ItemTokill == null:
		if ItemsOnConveyer.size() > 0:
			item_index = randi() % ItemsOnConveyer.size()
			ItemTokill = ItemsOnConveyer[item_index]
		else:
			push_warning("Array Empty")
			return

	
	else:
		item_index = ItemsOnConveyer.find(ItemTokill)

	# FINAL CHECK: Is this actually a shipping item if not fuck off
	if ItemTokill is Shipping_Item or ItemTokill.is_in_group("ShippingItems"):
		print("Killing: ", ItemTokill.name)
		
		# Remove from array if it exists there
		if item_index != -1:
			ItemsOnConveyer.pop_at(item_index)
		
		ItemTokill.queue_free()
	else:
		print("Object entered trash but is not a ShippingItem: ", ItemTokill.name)

func KillAllItems():
	
	for item in ItemsOnConveyer:
		if is_instance_valid(item):
			item.queue_free()
	
	
	ItemsOnConveyer.clear()

func _on_trash_body_entered(body: Node3D) -> void:
	if body is Shipping_Item:
		KillItem(body)
		LostItem = true
		GameOver(false)
		print("felloutofworld")
		
