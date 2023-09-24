@icon("res://src/assets/noexport/flame.svg")
class_name HeatSource
extends AmbientHeat
## A region of 2D space that alters the heat of bodies inside it, based on their distance to the source.

## How close the target has to be in order to receive heat from this source.
## If, for example, this heat source's collision is a circle, this value should be equal to it's radius.
@export var radius: float = 100.0

## Gets the [HeatData] relative to the position. [br]
## Unlike [AmbientHeat], this scales the heat based on the target's distance to the source.
func get_heat_data(delta: float, target_pos: Vector2) -> HeatData:
	var relative = 1.0 - (target_pos.distance_squared_to(position) / (radius * radius))
	# Return 0 if the target is too far away
	if relative <= 0.0:
		return HeatData.new(target_heat, 0.0, true)
	return HeatData.new(target_heat, relative * relative * rate * delta, true)
