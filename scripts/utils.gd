extends RefCounted
class_name utils

static func flatten(arr: Array) -> Array:
	var flat_array: Array = []
	for row in arr:
		for item in row:
			flat_array.append(item)
	return flat_array
