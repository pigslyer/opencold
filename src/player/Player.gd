class_name Player
extends CharacterBody2D

# 0 on curve represents input and current velocity at a 0 phi
# 1 represents them at a 180 phi
@export var acceleration_curve: Curve;
@export var speed_curve: Curve;
@export var sprinting_mult: float = 1.4;

@export var deceleration_speed: float = 200;

@onready var collision_shape: CollisionShape2D = $BodyShape;
@onready var human_model: HumanoidModel = $HumanoidModel;

## The Player's body heat in Celsius
var heat: float = 37.0

func _physics_process(delta: float) -> void:
	var facing_angle: float = get_local_mouse_position().angle();
	human_model.set_facing_target_angle(facing_angle);
	
	var input: Vector2 = Input.get_vector("mv_left", "mv_right", "mv_up", "mv_down");
	var is_sprinting: bool = Input.is_action_pressed("mv_sprint");
	var angle: float = human_model.get_body_angle() - input.angle();
	
	if is_zero_approx(input.length()):
		velocity = velocity.move_toward(Vector2.ZERO, deceleration_speed * delta);
	else:
		var normalized: float = abs(angle / PI);
		
		var acceleration: float = acceleration_curve.sample_baked(normalized);
		var max_speed: float = speed_curve.sample_baked(normalized);
		
		if is_sprinting:
			acceleration *= sprinting_mult;
			max_speed *= sprinting_mult;
		
		velocity = (velocity + input * acceleration * delta).limit_length(max_speed);
	
	move_and_slide();
	
	collision_shape.rotation = human_model.get_body_angle();

func _process(delta: float) -> void:
	if heat <= 24.0:
		#Fucking die instantly
		print("Man, I'm dead. (SkullEmoji)")

func alter_heat(heat_data: HeatData) -> void:
	var heat_diff = heat_data.target_internal_heat - heat
	
	if heat_diff < 0.0 and heat_data.warm_up_only:
		return
	heat += heat_diff * heat_data.heat_rate
