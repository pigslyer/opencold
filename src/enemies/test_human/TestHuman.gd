extends CharacterBody2D
## Test class for a human-like enemy.

## Value that dictates how fast this unit can move.
@export_range(0.0, 1000.0, 0.5, "or_greater", "suffix:px/s") var movement_speed: float = 200.0
## Value that dictates how much damage an attack from this unit does.
@export_range(0.0, 100.0, 0.5, "or_greater", "suffix:dmg") var attack_damage: float = 5.0
## Value that dictates the range at which this unit performs melee attacks. [br]
## This value ought to be smaller than the [NavigationAgent2D]'s [member NavigationAgent2D.path_desired_distance] value,
## so that the unit actually moves in close enough to attack.
@export_range(0.0, 1000.0, 0.5, "or_greater", "suffix:px") var attack_range: float = 150.0
## Value that dictates how much health this unit spawns in with.
@export_range(0.0, 200.0, 0.5, "or_greater", "suffix:hp") var max_health: float = 100.0
## Current health.
var health: float = max_health

## Value the dictates how long it takes for this unit to attack again after it has already done so.
@export_range(0.0, 10.0, 0.005, "or_greater", "suffix:s") var attack_delay: float = 2.0
## Current attack delay, this ticks down during physics process.
var current_attack_delay: float = 0.0

## This unit's [NavigationAgent2D]. It can't move without one.
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
## This unit's [Area2D]. Used for seeing enemies.
@onready var aggro_area: Area2D = $AggroArea

## This unit's current [CharacterBody2D] target. If it doesn't have one, it will spin until it spots one.
var target: CharacterBody2D = null

## Value dictating how aware this unit is on the existance of the current target.
## The value quickly rizes when it spots a target, but it goes slowly down when the target has managed to run away or hide.
var alert_level: float = 0.0: set = _set_alert_level

func _set_alert_level(new_alert_level: float) -> void:
	alert_level = clamp(new_alert_level, 0.0, 1.0)

func _process(delta: float) -> void:
	if target != null:
		if alert_level > 0.0:
			var point : Vector2 = target.position - position
			var rad: float = atan2(point.y, point.x)
			rotation = lerp_angle(rotation, rad, alert_level * 0.25)
		else:
			target = null
	else:
		alert_level = 0.0

func _physics_process(delta: float) -> void:
	if target == null:
		rotation_degrees += delta * 30.0
		for body in aggro_area.get_overlapping_bodies():
			if body != self and body is CharacterBody2D:
				var query = PhysicsRayQueryParameters2D.create(position, body.position, Layers.Physics2D.WORLD | Layers.Physics2D.PLAYER)
				var result = get_world_2d().direct_space_state.intersect_ray(query)
				if result and result.collider == body:
					target = body
					navigation_agent.target_position = target.position
					alert_level += 0.1
					return
	else:
		if aggro_area.get_overlapping_bodies().has(target):
			alert_level += delta
		else:
			alert_level -= delta * 0.1
		
		if current_attack_delay > 0.0:
			current_attack_delay -= delta
		var target_pos: Vector2 = target.position
		
		if target_pos.distance_squared_to(position) < attack_range * attack_range:
			if current_attack_delay <= 0.0:
				fire_weapon()
		
		if navigation_agent.is_navigation_finished():
			velocity *= 0.5
		else:
			var direction : Vector2 = global_position.direction_to(navigation_agent.get_next_path_position())
			velocity += ((direction * movement_speed) - velocity) * delta
		navigation_agent.target_position = target_pos
		move_and_slide()

## Function that takes in [DamageData] to calculate how much damage the [Player] takes.
func take_damage(data: DamageData) -> void:
	health -= data.damage
	if health <= 0.0:
		kill()
		return
	
	if data.does_source_aggro():
		target = data.source
		alert_level += 0.5

## Function that handles what happens when death occurs.
func kill() -> void:
	queue_free()

## TODO: Implement actual weapons, this is just magic bullets currently.
func fire_weapon() -> void: 
	var target_pos: Vector2 = target.position
	var space_state = get_world_2d().direct_space_state
	
	var query = PhysicsRayQueryParameters2D.create(position, target_pos, Layers.Physics2D.WORLD | Layers.Physics2D.PLAYER)
	var result = space_state.intersect_ray(query)
	
	if result.collider is CharacterBody2D and result.collider.has_method("take_damage"):
		result.collider.take_damage(DamageData.new(attack_damage, self))
		BulletTrace.make(position, target_pos)
		current_attack_delay = attack_delay
