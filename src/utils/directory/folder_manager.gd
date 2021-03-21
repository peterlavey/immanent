class_name FolderManager extends GDScript

func get_directory_list(path, extension = "")-> Array:
	var files = []
	var directory = Directory.new()
	
	directory.open(path)
	directory.list_dir_begin()
	
	while true:
		var file = directory.get_next()
		
		if file == "":
			break
		elif not file.begins_with("."):
			if extension == "" || file.split(".")[file.split(".").size()-1] == extension:
				files.append(file)
			
	directory.list_dir_end()
	
	return files
