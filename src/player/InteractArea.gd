class_name InteractArea
extends Area2D

## Emitted when a new interactable object has been selected.
signal on_interact_target_switch(old_interactable: Node2D, new_interactable: Node2D)

## Variable storing the current target interactable node.
var current_interactable: Node2D

func _physics_process(delta: float) -> void:
	var closest_interactable: Node2D
	
	var array : Array[Node2D]
	array.append_array(get_overlapping_bodies())
	array.append_array(get_overlapping_areas())
	
	for node in array:
		if node.has_method("interact") and (closest_interactable == null or closer_than(node, closest_interactable)):
			closest_interactable = node
	
	if current_interactable != closest_interactable:
		on_interact_target_switch.emit(current_interactable, closest_interactable)
		current_interactable = closest_interactable


func closer_than(a: Node2D, b: Node2D) -> bool:
	return a.global_position.distance_squared_to(global_position) < b.global_position.distance_squared_to(global_position)
