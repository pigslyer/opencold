extends Node2D

## Opens the associated door, instantly if [param instant] = true.
func open(instant: bool):
	$AnimationPlayer.play("Open");
	
	if instant:
		$AnimationPlayer.advance(INF);

## Closes the associated door, instantly if [param instant] = true.
func close(instant: bool):
	$AnimationPlayer.play("Close");
	
	if instant:
		$AnimationPlayer.advance(INF);
