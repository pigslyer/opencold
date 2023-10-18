class_name SubsceneMeta
extends RefCounted
## Metadata for a loaded subscene node tree.

## Array for all interscene nodes in this subscene tree. Not filled in by this function by default.
var interscene: Array[Node];

## The root node of this subscene node tree.
var _root: Node;

## A dictionary mapping group names to arrays of nodes belonging to these nodes.
var _groups: Dictionary;

func _init(root: Node) -> void:
	_root = root;

## Generates SubsceneMeta for arbitrary node.
static func get_from_tree(root: Node) -> SubsceneMeta:
	var ret := SubsceneMeta.new(root);
	
	_from_tree_recurse(ret, root);
	
	return ret;

static func _from_tree_recurse(sub_meta: SubsceneMeta, node: Node) -> void:
	sub_meta.add_groups(node);
	
	for child in node.get_children():
		_from_tree_recurse(sub_meta, child);

## Retrieves root node of tree.
func get_root() -> Node:
	return _root;

## Registers given node's groups to this SubsceneMeta.
func add_groups(node: Node) -> void:
	for group in node.get_groups():
		if not _groups.has(group):
			var arr: Array[Node] = [];
			_groups[group] = arr;
		
		_groups[group].push_back(node);

## Gets an array containing all nodes of a certain group in this scene. 
## Equivalent to SceneTree.get_nodes_in_group
func get_nodes_in_group(group: String) -> Array[Node]:
	return _groups[group];

## Gets global transform of Node2D in Subscene, optionally ignoring the root node.
func get_subscene_global_transform(node: Node2D, ignore_root: bool = false) -> Transform2D:
	if not node is Node2D:
		push_warning("Attempted to query %s, which is not Node2D derived. Given global transform may be inaccurate!" % node);
		return Transform2D.IDENTITY;
	elif node.get_parent() == null:
		return Transform2D.IDENTITY if ignore_root else node.transform;
	elif node.top_level:
		return node.transform;
	else:
		return get_subscene_global_transform(node.get_parent(), ignore_root) * node.transform;
