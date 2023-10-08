extends Node

var _player: Player = null;
var _meta_scene: MetaScene = null;

## Retrieves player if one exists, null otherwise.
func get_player() -> Player:
	if _player != null:
		return _player;
	
	var player: Node = get_tree().get_first_node_in_group("PLAYER");
	
	if player is Player:
		_player = player;
		_player.tree_exiting.connect(func(): _player = null);
	
	return _player;

## Retrieves meta scene if it exists, null otherwise.
func get_meta_scene() -> MetaScene:
	if _meta_scene != null:
		return _meta_scene;
	
	var meta_scene: Node = get_tree().get_first_node_in_group("META_SCENE");
	
	if meta_scene is MetaScene:
		_meta_scene = meta_scene;
		_meta_scene.tree_exited.connect(func(): _meta_scene = null);
	
	return _meta_scene;
