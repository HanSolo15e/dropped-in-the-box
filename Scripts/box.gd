extends RigidBody3D
class_name Shipping_Box

@export var BoxSize: float = 100
@export var BoxModelUID: String = "uid://b8q7svnlbnm2h"
@onready var area_3d: Area3D = $Area3D
@onready var area_3d_2: Area3D = $Area3D2

var main_game: Node3D 
@export var PlayPosNode: Node3D
enum BoxState {USING, END, START}
var playpos: Vector3 

signal TaskDone

func _ready() -> void:
	
	freeze = true
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	
	
	if PlayPosNode:
		playpos = self.to_local(PlayPosNode.global_position)
	

	var BoxModel = load(BoxModelUID)
	if BoxModel:
		var box_instance = BoxModel.instantiate()
		add_child(box_instance)
		
		
		var mesh_nodes = box_instance.find_children("*", "MeshInstance3D", true)
		
		
		if mesh_nodes.size() > 0:
			var mesh_node = mesh_nodes[0] # Grab the first mesh found
			_update_collision_from_mesh(mesh_node.mesh)
		else:
			push_warning("No MeshInstance3D found in the imported GLB!")

	# 5. Signal Connection
	if main_game and main_game.has_signal("BoxStateChange"):
		main_game.BoxStateChange.connect(ChangeState)

func _update_collision_from_mesh(mesh_data: Mesh):
	
	var col_shape_node = $CollisionShape3D
	
	if col_shape_node and mesh_data:
		#make mesh sucker
		var precise_shape = mesh_data.create_trimesh_shape()
		col_shape_node.shape = precise_shape
		print("Collision shape updated to TriMesh!")

func ChangeState(state: BoxState):
	var tween = create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	
	match state:
		BoxState.USING:
			print("Going In Play")
			tween.tween_property(self, "position", playpos, 1.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		BoxState.START:
			print("Waiting")
		BoxState.END:
			print("Moving to End")
			tween.tween_property(self, "position", playpos + Vector3(-4, 0, 0), 1.5).set_trans(Tween.TRANS_SINE)
	
	# CRITICAL this shit only kinda works fuck me
	await tween.finished 
	
	TaskDone.emit()
	print("Signal Emitted: TaskDone")
