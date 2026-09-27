extends SceneTree
## Gera cópias leves; os PNG originais ficam intactos e fora da importação.

func _initialize() -> void:
	for folder in ["lab1","lab2","storage"]:
		var target: String = "res://assets/runtime/" + folder
		DirAccess.make_dir_recursive_absolute(target)
		for file in DirAccess.get_files_at("res://assets/" + folder):
			if file.get_extension() != "png":
				continue
			var source: String = "res://assets/" + folder + "/" + file
			var picture := Image.load_from_file(source)
			if picture == null:
				push_error("Falha ao ler " + source)
				quit(1)
				return
			var longest := maxi(picture.get_width(),picture.get_height())
			if longest > 1600:
				var factor := 1600.0 / longest
				picture.resize(roundi(picture.get_width()*factor),roundi(picture.get_height()*factor),Image.INTERPOLATE_LANCZOS)
			picture.save_png(target+"/"+file)
	print("Assets de execução preparados.")
	quit()
