class_name LoadingGate;
extends Node2D
## A unique point in one scene which links to another unique point in a different scene.
## This node provides a low level link between the two scenes.
##
## Note: All methods on this node contain 3 discard parameters. This is to 
## make them easy to use with signals which may pass additional data.

## The group all loading gates belong to. This is to make them easily identifiable in new scenes.
const LOADING_GATE_GROUP: StringName = &"LOADING_GATE";

## Signal emitted when linked scene has finished loading and is present in the scene. 
## To be used with visuals/animations e.g. opening doors. 
## If instant is true, the animation should resolve instantly and without/with alternative
## sound effects.
signal on_linked_loaded(instant: bool);

## Signal emitted when linked scene has finished unloading and is no longer present in the scene/has had its _meta_unload method called. 
## To be used with visuals/animations e.g. closing doors. 
## If instant is true, the animation should resolve instantly and without/with alternative
## sound effects.
signal on_linked_unloaded(instant: bool);

## The absolute path to the linked level.
@export_file var _next_level: String;

## The unique id of this gate and the gate it links to.
@export var _gate_id: String;

## The loaded LoadingGate pair with the same id.
var _linked_gate: LoadingGate = null;

func _init() -> void:
	add_to_group(LOADING_GATE_GROUP);

## Begins loading linked scene.
func begin_load(_discard1 = null, _discard2 = null, _discard3 = null) -> void:
	if _linked_gate != null and is_instance_valid(_linked_gate):
		return;
	
	var meta_scene: MetaScene = Global.get_meta_scene() as MetaScene;
	
	if meta_scene == null:
		push_warning("No meta scene found! Loading gates won't work...");
		return;
	
	meta_scene.add_scene(
			_next_level, 
			func(meta: SubsceneMeta):
				var root: Node = meta.get_root();
				
				assert(root is Node2D, "Root of subscene %s isn't root 2D" % _next_level);
				
				var correct_gate: LoadingGate = null;
				
				for gate in meta.get_nodes_in_group(LOADING_GATE_GROUP):
					if gate._gate_id == _gate_id:
						correct_gate = gate;
						break;
				
				assert(correct_gate != null, "No gate with id %s could be found in %s!" % [_gate_id, _next_level]);
				
				root.position = global_position - meta.get_subscene_global_transform(correct_gate, true).get_origin();
				
				_linked_gate = correct_gate;
				correct_gate._linked_gate = self;
				
				on_linked_loaded.emit(false);
				correct_gate.on_linked_loaded.emit(true);
	);



## Blocks calling thread until linked scene is loaded and added.
func force_load(_discard1 = null, _discard2 = null, _discard3 = null) -> void:
	if _linked_gate != null and is_instance_valid(_linked_gate):
		return;
	
	var meta_scene: MetaScene = Global.get_meta_scene() as MetaScene;
	
	if meta_scene == null:
		return;
	
	# unimplemented


## Halts loading of linked scene or unloads it if it has already loaded.
func cancel_load(_discard1 = null, _discard2 = null, _discard3 = null) -> void:
	var meta_scene: MetaScene = Global.get_meta_scene() as MetaScene;
	
	if meta_scene == null:
		return;
	
	if _linked_gate != null and is_instance_valid(_linked_gate):
		meta_scene.remove_scene(_linked_gate);
		on_linked_unloaded.emit(false);
		_linked_gate = null;
	
	# unimplemented thread cancel load
