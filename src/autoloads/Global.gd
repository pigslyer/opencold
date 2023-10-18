extends Node

## Retrieves player if one exists, null otherwise.
func get_player() -> Player:
	return get_tree().get_first_node_in_group("PLAYER");

## Retrieves meta scene if it exists, null otherwise.
func get_meta_scene() -> MetaScene:
	return get_tree().get_first_node_in_group("META_SCENE");
