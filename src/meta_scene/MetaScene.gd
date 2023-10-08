class_name MetaScene
extends Node2D

const INTERSCENE_UNIQUE_NODES_GROUP_PREFIX: StringName = &"INTERSCENE_UNIQUE_NODE";

const SAVE_LOAD_SCENE_ROOT_PREFIX: StringName = &"";
const SAVE_LOAD_GROUP_NAME: StringName = &"SAVES";

const SCENE_ROOT_META_NAME = "meta_scene_root";

@export var _starting_scene: PackedScene = null;

func _ready():
	var instance: Node = _starting_scene.instantiate();
	var meta: SubsceneMeta = _initialize_scene(instance);
	
	for interscene in meta.interscene:
		interscene.transform = instance.transform * interscene.transform;
		
		add_child(interscene);
		
	
	add_child(instance);
	_starting_scene = null;

# for now all of these block, performance improvements can be done as the need arises

func add_scene(scene_resource_path: String, on_load: Callable = func(_discard): pass) -> void:
	var time: int = Time.get_ticks_msec();
	var packed_scene: PackedScene = load(scene_resource_path);
	print("Loading packed scene %s took %s ms." % [scene_resource_path, Time.get_ticks_msec() - time]);
	
	time = Time.get_ticks_msec();
	var node: Node = packed_scene.instantiate();
	print("Instantiating packed scene %s took %s ms." % [scene_resource_path, Time.get_ticks_msec() - time]);
	
	time = Time.get_ticks_msec();
	var subscene_meta: SubsceneMeta = _initialize_scene(node);
	print("Initializing scene %s took %s ms." % [scene_resource_path, Time.get_ticks_msec() - time]);
	
	time = Time.get_ticks_msec();
	on_load.call(subscene_meta);
	print("On-load callback for %s took %s ms." % [scene_resource_path, Time.get_ticks_msec() - time]);
	
	await get_tree().process_frame;
	
	time = Time.get_ticks_msec();
	add_child(node);
	
	for interscene in subscene_meta.interscene:
		if interscene is Node2D:
			# take into account repositioning
			interscene.transform = node.transform * interscene.transform;
		
		add_child(interscene);
	
	print("Adding scene %s to tree took %s ms." % [scene_resource_path, Time.get_ticks_msec() - time]);
	

func switch_to_scene(scene_resource_path: String) -> void:
	for scene in get_children():
		scene.queue_free();
	
	add_scene(scene_resource_path);


func remove_scene(child_of_scene: Node) -> void:
	var root = get_meta_root(child_of_scene);
	
	if root is Node:
		if root.has_method("request_free"):
			root.request_free();
		else:
			root.queue_free();


func get_meta_root(child_of_scene: Node) -> Node:
	return child_of_scene.get_meta(SCENE_ROOT_META_NAME, null);

func _initialize_scene(root: Node) -> SubsceneMeta:
	var subscene_meta := SubsceneMeta.new(root);
	_initialize_node(root, subscene_meta);
	
	return subscene_meta

func _initialize_node(node: Node, subscene_meta: SubsceneMeta, skip_interscene_root: bool = true) -> void:
	if not skip_interscene_root:
		for group in node.get_groups():
			if group.begins_with(INTERSCENE_UNIQUE_NODES_GROUP_PREFIX):
				if get_tree().get_nodes_in_group(group).size() > 0:
					node.free();
				else:
					# heh
					var trans: Transform2D;
					
					if node is Node2D:
						trans = subscene_meta.get_subscene_global_transform(node, true);
					
					node.get_parent().remove_child(node);
					_initialize_scene(node);
					
					if node is Node2D:
						node.transform = trans;
					
					subscene_meta.interscene.push_back(node);
				
				return;
	
	subscene_meta.add_groups(node);
	node.set_meta(SCENE_ROOT_META_NAME, subscene_meta.get_root());
	
	var idx: int = 0;
	while idx < node.get_child_count():
		var child: Node = node.get_child(idx);
		_initialize_node(child, subscene_meta, false);
		
		if idx < node.get_child_count() and node.get_child(idx) == child:
			idx += 1;
