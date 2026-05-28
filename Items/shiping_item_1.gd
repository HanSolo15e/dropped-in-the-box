extends RigidBody3D
class_name Shipping_Item

@export var Size = 10
@export var model: String # Assuming this gets the path like "res://..."
@onready var main_game: Node3D = $"."
@onready var area_3d: Area3D = $Area3D
@onready var rigid_body_3d: RigidBody3D = self
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var collision_shape_3d: CollisionShape3D = $Area3D/CollisionShape3D

var IsPickedUp: bool = false
var PullForce: Vector3 = Vector3(0,0,0)
var HitPos: Vector3 = Vector3(0,0,0)
var IsHover: bool = false

func _ready() -> void:
	area_3d.input_event.connect(_clicked)
	
	if model:
		# Ask the library for the pre-processed data
		var data = PropLibrary.get_model_data(model)
		
		if data.has("mesh"):
			# Set the shared resources
			mesh_instance.mesh = data["mesh"]
			
			# Use the SAME shape resource for both
			# (Godot handles this efficiently)
			collision_shape.shape = data["shape"]
			collision_shape_3d.shape = data["shape"]

func _process(delta: float) -> void:
	pass



func _physics_process(delta: float) -> void:
	if IsPickedUp:
		var state = PhysicsServer3D.body_get_direct_state(rigid_body_3d.get_rid())
		var point_velocity = state.get_velocity_at_local_position(HitPos)
		var mouse_pos = get_clamped_mouse_pos(2.6)
		var to_target = mouse_pos - rigid_body_3d.global_position
		var force_required = (((to_target * rigid_body_3d.mass)/1) / delta*2)
		var counter_velocity = ((rigid_body_3d.linear_velocity) / delta)/4
		
		rigid_body_3d.gravity_scale = 0
		rigid_body_3d.apply_force((force_required - counter_velocity))
		
		if Input.is_action_just_pressed("Gamplay_Left"):
			rigid_body_3d.apply_torque_impulse(Vector3(0,-0.05,0))
		elif Input.is_action_just_pressed("Gamplay_Right"):
			rigid_body_3d.apply_torque_impulse(Vector3(0,0.05,0))
		elif Input.is_action_just_pressed("Gamplay_Down"):
			rigid_body_3d.apply_torque_impulse(Vector3(0.05,0,0))
		elif Input.is_action_just_pressed("Gamplay_Up"):
			rigid_body_3d.apply_torque_impulse(Vector3(-0.05,0,0))
	
	else:
		rigid_body_3d.gravity_scale = 1
		
#idk why but this func is never used but i like it so it stays
func get_mouse_world_position() -> Vector3:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_3d()
	
	
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * 2000
	
	
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	
	
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)
	
	
	if result:
		return result.position 
		
	return Vector3.ZERO 
		
func _clicked(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int):
	HitPos = rigid_body_3d.to_local(event_position)
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if not IsPickedUp && GameLoader.GetHoldingState() == false: 
					print("pick")
					IsPickedUp = true
					GameLoader.HoldingItem(true)

# 1. Change this to _unhandled_input
func _unhandled_input(event: InputEvent) -> void:
	if IsPickedUp:
		if event is InputEventMouseButton and event.pressed:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					print("Drop")
					IsPickedUp = false
					GameLoader.HoldingItem(false)
					
					# 2. ADD THIS MAGIC LINE
					get_viewport().set_input_as_handled()
					
func get_clamped_mouse_pos(distance: float) -> Vector3:
	var camera = get_viewport().get_camera_3d()
	var mouse_pos = get_viewport().get_mouse_position()
	mouse_pos += Vector2(-50,0)
	
	var ray_start = camera.project_ray_origin(mouse_pos)
	var ray_dir = camera.project_ray_normal(mouse_pos)
	var final_point = ray_start + (ray_dir * distance)
	return final_point
