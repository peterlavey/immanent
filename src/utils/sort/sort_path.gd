class_name SortPath extends GDScript

func asc(new, old)-> bool:
	var a = int(new.split("/")[-1].split(".")[0])
	var b = int(old.split("/")[-1].split(".")[0])
	
	if typeof(a) != typeof(b):
		return typeof(a) < typeof(b)
	else:
		return a < b
