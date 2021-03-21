class_name Loader extends GDScript

const SRC = "res://src/"
const ASSETS = "res://assets"

func src(path: String, arg1 = null, arg2 = null, arg3 = null):
	if arg1 != null && arg2 != null && arg3 != null:
		return load(SRC + path).new(arg1, arg2, arg3)
	elif arg1 != null && arg2 != null:
		return load(SRC + path).new(arg1, arg2)
	elif arg1 != null:
		return load(SRC + path).new(arg1)
	else:
		return load(SRC + path).new()

func asset(path: String):
	return load(ASSETS + path)
