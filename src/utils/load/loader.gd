class_name Loader extends GDScript

const SRC = "res://src/"
const CLASS_EXTENSION = ".gd"
const ASSETS = "res://assets"
const ASSET_EXTENSION = ".png"

func ref(path: String):
	return load(SRC + path + CLASS_EXTENSION)

func src(path: String, arg1 = null, arg2 = null, arg3 = null):
	if arg1 != null && arg2 != null && arg3 != null:
		return load(SRC + path + CLASS_EXTENSION).new(arg1, arg2, arg3)
	elif arg1 != null && arg2 != null:
		return load(SRC + path + CLASS_EXTENSION).new(arg1, arg2)
	elif arg1 != null:
		return load(SRC + path + CLASS_EXTENSION).new(arg1)
	else:
		return load(SRC + path + CLASS_EXTENSION).new()

func asset(path: String):
	return load(ASSETS + path + ASSET_EXTENSION)
