@icon("res://src/assets/noexport/artillery-shell.svg")
class_name BulletTrace
extends Line2D
## Class for handling bullet trace animations, using the [Line2D] logic. [br]
## An object of this class must always have a shader with a [code]lifetime[/code] and a [code]life[/code] variable.

## Value dictating how far the bullet travels by default.
## TODO: Make this variable weapon specific.
static var ray_distance: float = 1000.0
## Value dictating the scale of the random angle offset that occurs when a bullet is fired.
## TODO: Make this variable weapon specific.
static var ray_angle_offset: float = 0.04
## Value dictating how long a bullet trace lingers before vanishing.
## Should be scaled with the [code]ray_distance[/code] variable.
static var trace_lifetime_factor: float = ray_distance * 2.0

## Value dictating how long the bullet trace lingers.
var lifetime: float
## Value dictating how much time the bullet has left.
var life: float

func _process(delta: float) -> void:
	life -= delta
	material.set_shader_parameter("lifetime", lifetime)
	material.set_shader_parameter("life", life)
	if life <= 0.0:
		queue_free()

## Static function for spawning in bullet traces and dealing damage to the target. [br]
## Takes [param source] as the source of the bullet, which is used to create the appropriate [DamageData]. [br]
## Takes [param facing_angle] to orient the bullet in the correct direction. [br]
## Takes [param damage] that gets passed into the [DamageData], if a target is hit.
static func shoot_at(source: Node2D, facing_angle: float, damage: float) -> void:
	var space_state = source.get_world_2d().direct_space_state
	facing_angle += (randf() - 0.5) * ray_angle_offset
	var ray_end: Vector2 = Vector2(ray_distance * cos(facing_angle), ray_distance * sin(facing_angle))
	
	var query = PhysicsRayQueryParameters2D.create(source.position, source.position + ray_end)
	var result = space_state.intersect_ray(query)
	
	if result:
		ray_end = result.position - source.position
		
		if result.collider.has_method("damage"):
			result.collider.damage(DamageData.new(damage, source))
	
	var done_scene: Node = preload("res://src/bullet_trace/BulletTrace.tscn").instantiate()
	if done_scene is BulletTrace:
		done_scene.position = source.position
		done_scene.add_point(Vector2.ZERO)
		done_scene.add_point(ray_end)
		done_scene.lifetime = ray_end.length() / trace_lifetime_factor
		done_scene.life = done_scene.lifetime
		source.get_tree().root.add_child(done_scene)
