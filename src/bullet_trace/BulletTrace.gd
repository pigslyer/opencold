@icon("res://src/assets/noexport/artillery-shell.svg")
class_name BulletTrace
extends Line2D
## Class for handling bullet trace animations, using the [Line2D] logic. [br]
## An object of this class must always have a shader with a [code]lifetime[/code] and a [code]life[/code] variable.

## Value dictating how long a bullet trace lingers before vanishing. 
## The value represents by how much the length of the trace gets divided by. [br]
## So a trace that is 1000.0 units long, will give us the lifetime of 0.5 seconds, after being divided by 2000.0.
const TRACE_LIFETIME_FACTOR: float = 2000.0

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
## Takes [param start] as the starting position of the trace. [br]
## Takes [param end] as the end position of the trace. [br]
static func make(start: Vector2, end: Vector2) -> void:
	var bullet_trace: Node = preload("res://src/bullet_trace/BulletTrace.tscn").instantiate()
	bullet_trace.position = start
	bullet_trace.add_point(Vector2.ZERO)
	bullet_trace.add_point(end - start)
	bullet_trace.lifetime = end.length() / TRACE_LIFETIME_FACTOR
	bullet_trace.life = bullet_trace.lifetime
	Global.get_tree().root.add_child(bullet_trace) # TODO: Implement properly
