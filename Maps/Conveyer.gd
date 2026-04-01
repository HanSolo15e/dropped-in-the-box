extends Area3D
var TotalItems: Array = []
@onready var main_game: Node3D = $".."
@onready var item_spawn_point: Node3D = $"../ItemSpawnPoint"
const ShipingItem1 = preload("res://Items/shiping_item1.tscn")
var main_game_script: Script 
var BaseItemNum: int = 5
var AllProps: Array[String] 

signal AddBoxToArray(ObjRef)

signal TaskFinished

func _ready() -> void:
	AllProps = get_files_by_type("res://Models/Items/Models/", ".glb")
	main_game_script = main_game.get_script()
	main_game.ReplenishItems.connect(ReplenishItems)
	self.body_entered.connect(_addForceConveyer)
	
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func LookUpSize(FileName):
	match FileName:
		
		"american_football.glb":
			return 20
		"Drill_01.glb":
			return 15
		"multi_cleaner_5_litre.glb":
			return 10
		"rubber_duck_toy.glb":
			return 18
		"leather_cleaner_can.glb":
			return 18
		"Television_01.glb":
			return 30
		"small_lpg_tank.glb":
			return 25
		"Ukulele_01.glb":
			return 20
		_:
			print("could not find item hmmm")
			return 10
			
			
	
func get_files_by_type(folder_path: String, file_extension: String) -> Array[String]:
	var matched_files: Array[String] = []
	var dir = DirAccess.open(folder_path)
	
	if dir:
		var files = dir.get_files()
		for file in files:
			
			var clean_file = file.replace(".import", "").replace(".remap", "")
			
			
			if clean_file.ends_with(file_extension):
				var full_path = folder_path + "/" + clean_file
				
				if not matched_files.has(full_path): 
					matched_files.append(full_path)
					print("Found match: ", clean_file)
	else:
		push_error("Could not open folder: ", folder_path)
		
	return matched_files
	
func SpawnItem():
	var ItemToSpawn: Shipping_Item = ShipingItem1.instantiate()
	
	
	if not ItemToSpawn.is_in_group("ShippingItems"):
		ItemToSpawn.add_to_group("ShippingItems")
	
	var itemtopick = AllProps.pick_random()
	ItemToSpawn.rotation.y = deg_to_rad(randf_range(0, 360))
	ItemToSpawn.model = itemtopick
	ItemToSpawn.Size = LookUpSize(itemtopick.get_file())
	item_spawn_point.add_child(ItemToSpawn)
	AddBoxToArray.emit(ItemToSpawn)

func ReplenishItems(Num:int):
	for i in range(Num):
		SpawnItem() # Force a spawn

		await get_tree().create_timer(0.4).timeout
		
	TaskFinished.emit()
		
	

func _addForceConveyer(body: Node3D) -> void:
	print("Item entered:", body)
	
	var ItemsInArea = self.get_overlapping_bodies()
	
	for Item in ItemsInArea:
		if Item is RigidBody3D:
			Item.apply_central_impulse(Vector3(0.5, 0, 0))
