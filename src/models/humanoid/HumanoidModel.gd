class_name HumanoidModel
extends Node2D

func set_facing_target_angle(radians: float):
	rotation = radians;

func get_body_angle() -> float:
	return rotation;
