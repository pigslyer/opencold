extends Node

## A dictionary that stores every [Node2D] that is currently aggrod on the [Player]
var aggro_set : Dictionary

## Function that should be used whenever a [Node2D] aggros onto the [Player] character, so that
## we can keep track of it.
func begin_aggro(aggresor: Node2D):
	aggro_set[aggresor] = null

## Function that tells the game that the provided [Node2D] is no longer aggrod onto the [Player].
func end_aggro(aggresor: Node2D):
	aggro_set.erase(aggresor)
