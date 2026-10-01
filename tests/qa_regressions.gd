extends SceneTree
## Regressões de gameplay; todos os saves ficam em .runtime, fora dos dados do jogador.
var failures := 0
var checks := 0
var game: Node

func _initialize() -> void:
	call_deferred("run")

func check(value: bool, label: String) -> void:
	checks += 1
	print(("PASS: " if value else "FAIL: ") + label)
	if not value: failures += 1

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://.runtime")
	game = load("res://scenes/main.tscn").instantiate()
	game.save_path = "res://.runtime/qa-%d.json" % OS.get_process_id()
	game.save_enabled = false
	root.add_child(game)
	await process_frame
	game._notify("Mensagem antiga")
	game.start_new()
	game.player.distraction_cooldown = 4.0
	game.load_room("storage", Vector2(150, 480))
	check(game.player.distraction_cooldown == 4.0, "Troca de setor preserva recarga")
	game.player.distraction_cooldown = 3.0
	var event := InputEventAction.new()
	event.action = "restart"
	event.pressed = true
	game._unhandled_input(event)
	check(game.player.distraction_cooldown == 3.0, "Reposicionamento R preserva recarga")
	game.start_new()
	check(game.player.distraction_cooldown == 0.0, "Nova missão reinicia recarga")
	check(game.message != "Mensagem antiga", "Nova missão limpa mensagens antigas")
	game.load_room("lab1", Vector2(400, 330))
	var coil = game.items[0]
	coil.position = Vector2(460, 330)
	await physics_frame
	await physics_frame
	game.interact(coil)
	check(game.collected.is_empty(), "Não coleta através da bancada")
	game._process(0.0)
	check(game.nearest == null, "Objeto bloqueado não exibe convite de interação")
	game.player.position = Vector2(380, 230)
	coil.position = Vector2(452, 230)
	await physics_frame
	await physics_frame
	game._process(0.0)
	check(game.nearest == coil, "Alcance de exatamente 72 pixels corresponde à interação")
	game.save_enabled = true
	game.save_path = "res://.runtime/inexistente/qa.json"
	game.interact(coil)
	check(game.collected.has("coil") and game.message.to_lower().contains("não foi possível salvar"), "Falha de gravação mantém peça e informa erro")
	game.save_path = "res://.runtime/qa-%d.json" % OS.get_process_id()
	check(game.save_progress(), "Gravação de progresso retorna sucesso")
	game.collected.append("cell")
	check(game.save_progress() and game._read_save().parts.size() == 2, "Substituição de save existente mantém dados completos")
	check(not FileAccess.file_exists(game.save_path + ".tmp"), "Gravação finalizada não deixa arquivo temporário")
	var previous := FileAccess.get_file_as_string(game.save_path)
	DirAccess.make_dir_absolute(game.save_path + ".tmp")
	check(not game.save_progress() and FileAccess.get_file_as_string(game.save_path) == previous, "Falha ao criar temporário preserva save anterior")
	DirAccess.remove_absolute(game.save_path + ".tmp")
	for invalid in ['', '{broken', 'null', '{"version":2,"room":"lab1","parts":[]}', '{"version":1,"room":"lab1","parts":["invalid"]}', '{"version":1,"room":"lab1","parts":{}}']:
		var file := FileAccess.open(game.save_path, FileAccess.WRITE)
		file.store_string(invalid)
		file.close()
		check(game._read_save().is_empty(), "Save malformado rejeitado: " + invalid)
	DirAccess.remove_absolute(game.save_path)
	game.save_enabled = false
	game.start_new()
	await physics_frame
	await physics_frame
	game.distract()
	var pulse = game.room.get_child(game.room.get_child_count() - 1)
	var remaining: float = pulse.remaining
	var clock: float = game.items[0].clock
	game.player.art.flash = 1.0
	game._pause()
	await create_timer(0.2).timeout
	check(pulse.remaining == remaining and game.items[0].clock == clock and game.player.art.flash == 1.0, "Pausa congela pulso, itens e flash")
	for child in game.hud.get_children():
		if child is Button:
			check(child.focus_mode == Control.FOCUS_NONE, "Botão de pausa não captura setas de movimento")
	game._resume()
	game.interact(null)
	check(game.state == game.State.PLAY, "Interação com referência nula é ignorada")
	game.load_room("lab2", Vector2(150, 480))
	var guard = game.guards[0]
	guard.position = Vector2(920, 320)
	guard.mode = guard.Mode.INVESTIGATE
	guard.target = Vector2(1070, 320)
	await create_timer(4.0).timeout
	check(guard.position.distance_to(Vector2(1070, 320)) < 8, "Cientista contorna cadeira e alcança destino")
	check(guard.mode == guard.Mode.SEARCH, "Busca começa no destino alcançado")
	# Também verifica cobertura, limites e folga nos caminhos em todos os setores.
	for id in ["lab1", "storage", "lab2"]:
		game.load_room(id, Vector2(150, 480))
		var navigation = game.guards[0].navigation
		var path: PackedVector2Array = navigation.find_path(Vector2(300, 480), Vector2(1070, 320))
		var clear := not path.is_empty()
		var from := Vector2(300, 480)
		for point in path:
			clear = clear and navigation._clear_segment(from, point)
			from = point
		check(clear, "Caminho com folga e sem atravessar móveis em " + id)
	game.queue_free()
	await process_frame
	print("RESULT: %d verificações, %d falha(s)" % [checks, failures])
	quit(1 if failures else 0)
