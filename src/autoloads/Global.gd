extends Node

var _player: Player = null;

func get_player() -> Player:
	if _player != null:
		return _player;
	
	var players: Array[Node] = get_tree().get_nodes_in_group("PLAYER");
	
	if players.size() > 0 && players[0] is Player:
		_player = players[0] as Player;
		_player.connect("tree_exiting", Callable(self, "_unassign_player"));
	
	return _player;

func _unassign_player():
	_player = null;

