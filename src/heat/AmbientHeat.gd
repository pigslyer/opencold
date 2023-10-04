@icon("res://src/assets/noexport/heat-haze.svg")
class_name AmbientHeat
extends Area2D
## A region of 2D space that alters the heat of bodies inside it.

## The internal temperature this source can heat a target to (In degrees Celsius). [br]
## 37.0 is a very comfortable / average body temperature. [br]
## A person passes out at 31.0 and is usually dead by the time they hit 24.0.
@export_range(0.0, 37.0, 0.005, "or_greater", "suffix:°C") var target_heat: float = 24.0

## The rate at which the target should change temperature. [br]
## This value gets multiplied with the current difference in temperature. [br]
## A value of 1.0 would mean that the target's internal temperature would hit the target 
## temperature in 1 second, while a value of 0.1 would mean it would take 10 seconds. [br]
## Do the math.
@export_range(0.0, 0.1, 0.00001, "or_greater", "suffix:/s") var rate: float = 0.001

func _process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.has_method("alter_heat"):
			var heat_data = get_heat_data(delta, body.position)
			if heat_data.heat_rate > 0.0:
				body.alter_heat(heat_data)

## Gets the [HeatData] relative to the position. [br]
## An area with ambient heat will always heat up the target at the same rate.
func get_heat_data(delta: float, target_pos: Vector2) -> HeatData:
	return HeatData.new(target_heat, rate * delta)
