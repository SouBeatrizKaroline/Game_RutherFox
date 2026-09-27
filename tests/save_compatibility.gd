extends SceneTree
## Rode --script tests/save_compatibility.gd -- --write na engine anterior;
## depois rode sem --write na nova engine, com o mesmo diretório de dados.
func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	game.save_enabled = false
	root.add_child(game)
	await process_frame
	game.save_path = "user://upgrade-compatibility.json"
	if OS.get_cmdline_user_args().has("--write"):
		game.collected.append("coil")
		game.collected.append("cell")
		game.room_id = "lab2"
		game.save_enabled = true
		game.save_progress()
		print("SAVE FIXTURE: ", Engine.get_version_info().string)
	else:
		game.continue_game()
		if game.room_id != "lab2" or game.collected.size() != 2 or not game.collected.has("coil") or not game.collected.has("cell"):
			push_error("Progresso anterior não foi restaurado")
			quit(1)
			return
		print("PASS: progresso da engine anterior restaurado em ", Engine.get_version_info().string)
		DirAccess.remove_absolute(game.save_path)
	quit()
