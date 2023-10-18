class_name MetaScene
extends Node2D
## The root of scenes with interscene transitions.

## All nodes in a group with this prefix get loaded separately. If an added scene shares a node with
## the same group name as an existing interscene unique node, that node in the added scene will be
## freed automatically.
const INTERSCENE_UNIQUE_NODES_GROUP_PREFIX: StringName = &"INTERSCENE_UNIQUE_NODE";

## Metadata on every node in added scene, pointing to the root of that scene.
## Could be removed in favour of tree traversal if iteration count becomes an issue.
const SCENE_ROOT_META_NAME: StringName = &"meta_scene_root";

## Metadata on every added scene, which maps to that scene's resource's path.
const SCENE_RESOURCE_PATH_META: StringName = &"meta_scene_resource_path";

## The scene to be added on startup.
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

## Adds scene at given path to this meta scene, calling [param on_load] with a SubsceneMeta parameter
## before adding it to the scene tree. This opportunity should be used to (at least) correct 
## its root's transform
func add_scene(scene_resource_path: String, on_load: Callable = func(_discard): pass) -> void:
	# check if the scene already exists and reuse it if it does
	for child in get_children():
		var path: String = child.get_meta(SCENE_RESOURCE_PATH_META);
		if path == scene_resource_path:
			if child.has_method("_meta_cancel_unload"):
				child._meta_cancel_unload();
			
			on_load.call(SubsceneMeta.get_from_tree(child));
			return;
	
	var time: int = Time.get_ticks_msec();
	var packed_scene: PackedScene = load(scene_resource_path);
	print("Loading packed scene %s took %s ms." % [scene_resource_path, Time.get_ticks_msec() - time]);
	
	time = Time.get_ticks_msec();
	var node: Node = packed_scene.instantiate();
	node.set_meta(SCENE_RESOURCE_PATH_META, scene_resource_path);
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
	
	if node is Node2D:
		for interscene in subscene_meta.interscene:
			if interscene is Node2D:
				# take into account repositioning
				interscene.transform = node.transform * interscene.transform;
			
			add_child(interscene);
	
	print("Adding scene %s to tree took %s ms." % [scene_resource_path, Time.get_ticks_msec() - time]);

## Removes parent meta subscene this child is a descendant of.
func remove_scene(child_of_scene: Node) -> void:
	var root = get_meta_root(child_of_scene);
	
	if root is Node:
		if root.has_method("_meta_unload"):
			root._meta_unload();
		else:
			root.queue_free();

## Returns meta subscene root this child is a descendant of.
func get_meta_root(child_of_scene: Node) -> Node:
	return child_of_scene.get_meta(SCENE_ROOT_META_NAME, null);

## Initializes given meta subscene, generating a SubsceneMeta in the process.
func _initialize_scene(root: Node) -> SubsceneMeta:
	var subscene_meta := SubsceneMeta.new(root);
	_initialize_node(root, subscene_meta);
	
	return subscene_meta

## Initializes node as part of meta subscene.
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
