extends Area2D

# The id of the doors this key opens. -1 means it opens every door.
export(PoolIntArray) var opens

func get_key() -> PoolIntArray:
	return opens
