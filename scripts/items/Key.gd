extends Area2D
class_name Key

# The id of the doors this key opens. -1 means it opens every door.
export(PoolIntArray) var opens

func get_key() -> PoolIntArray:
	call_deferred("_collect")
	return opens

func _collect():
	queue_free()
