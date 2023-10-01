class_name DamageData
extends RefCounted
## A helper class for passing damage data to targets.

## Value dictating how much damage the target is supposed to take.
var damage: float

## A value referencing the source of the damage. Usually an attacker of sorts or an enviromental hazard.
var source: Node

func _init(dmg: float, src: Node) -> void:
	damage = dmg
	source = src

## A function intentded to test if the damage victim can aggro on the damage source.
## Will return false if the source is a hazard, true if it isn't.
func does_source_aggro() -> bool:
	return source is CharacterBody2D
