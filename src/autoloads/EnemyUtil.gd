extends Node

var aggro_array : Array[Node2D]

func begin_aggro(aggresor: Node2D):
	aggro_array.append(aggresor)

func end_aggro(aggresor: Node2D):
	aggro_array.erase(aggresor)
