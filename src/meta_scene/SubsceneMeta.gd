class_name SubsceneMeta
extends RefCounted

var interscene: Array[Node];

var _root: Node;
var _groups: Dictionary;

func _init(root: Node) -> void:
	_root = root;

func get_root() -> Node:
	return _root;

func add_groups(node: Node) -> void:
	for group in node.get_groups():
		if not _groups.has(group):
			var arr: Array[Node] = [];
			_groups[group] = arr;
		
		_groups[group].push_back(node);


func get_nodes_in_group(group: String) -> Array[Node]:
	return _groups[group];

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
