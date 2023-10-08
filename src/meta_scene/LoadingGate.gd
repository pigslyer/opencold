class_name LoadingGate;
extends Node2D

const LOADING_GATE_GROUP: StringName = &"LOADING_GATE";

signal on_linked_loaded(instant: bool);
signal on_linked_unloaded(instant: bool);

@export_file var _next_level: String;
@export var _gate_id: String;

var _linked_gate: LoadingGate = null;

func _ready() -> void:
	if Engine.is_editor_hint():
		var update: Callable = func(_discard = null):
			update_configuration_warnings();
		
		get_tree().node_added.connect(update);
		get_tree().node_removed.connect(update);

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
				correct_gate.on_linked_unloaded.emit(true);
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

