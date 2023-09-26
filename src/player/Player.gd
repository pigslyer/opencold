class_name Player
extends CharacterBody2D

## Constant dictating how far the bullet travels by default.
## TODO: Make this variable weapon specific.
const RAY_DISTANCE: float = 1000.0
## Constant dictating the scale of the random angle offset that occurs when a bullet is fired.
## TODO: Make this variable weapon specific.
const RAY_ANGLE_OFFSET: float = 0.04

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

## The Player's max health
var max_health: float = 100.0
## The Player's current health
var health: float = max_health

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
	
	if Input.is_action_just_pressed("use_held"):
		fire_weapon()
	
	collision_shape.rotation = human_model.get_body_angle();

func fire_weapon() -> void: # TODO: Implement actual weapons, this is just magic bullets currently.
	var space_state = get_world_2d().direct_space_state
	var facing_angle: float = get_local_mouse_position().angle() + ((randf() - 0.5) * RAY_ANGLE_OFFSET)
	var ray_end: Vector2 = Vector2(RAY_DISTANCE * cos(facing_angle), RAY_DISTANCE * sin(facing_angle))
	
	var query = PhysicsRayQueryParameters2D.create(position, position + ray_end, Layers.Physics2D.WORLD | Layers.Physics2D.ENEMY)
	var result = space_state.intersect_ray(query)
	
	if result:
		ray_end = result.position
		
		if result.collider.has_method("damage"):
			result.collider.damage(DamageData.new(10.0, self)) # Temp magic number ( damage of the weapon used )
	else:
		ray_end += position
	
	BulletTrace.make(position, ray_end) 

func _process(delta: float) -> void:
	if heat <= 24.0:
		#Fucking die instantly
		kill()

## Function that takes in [HeatData] to calculate changes to the [Player]'s internal temperature.
func alter_heat(heat_data: HeatData) -> void:
	var heat_diff = heat_data.target_internal_heat - heat
	
	if heat_diff < 0.0 and heat_data.warm_up_only:
		return
	heat += heat_diff * heat_data.heat_rate

## Function that takes in [DamageData] to calculate how much damage the [Player] takes.
func damage(data: DamageData) -> void:
	health -= data.damage
	if health <= 0.0:
		kill()

## Function that handles what happens when death occurs.
func kill() -> void:
	print("Man, I'm dead. (SkullEmoji)")
