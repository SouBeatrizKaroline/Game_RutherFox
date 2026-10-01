extends SceneTree
## Execute com --headless --path . --script tests/smoke.gd.
var failures := 0
var game: Node

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: " + description)
	else:
		failures += 1
		push_error("FAIL: " + description)

func item(id: String) -> Node2D:
	for candidate in game.items:
		if candidate.id == id:
			return candidate
	return null

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://.runtime")
	game = load("res://scenes/main.tscn").instantiate()
	game.save_enabled = false
	game.save_path = "res://.runtime/smoke-%d.json" % OS.get_process_id()
	root.add_child(game)
	await process_frame
	check(game.state == game.State.MENU,"Menu inicial")
	game.start_new()
	await physics_frame
	check(game.room_id == "lab1" and game.player.enabled,"Nova missão")
	game.interact(item("coil"))
	check(game.collected.is_empty(),"Não coleta à distância")
	var start: Vector2 = game.player.position
	Input.action_press("right")
	await create_timer(0.20).timeout
	Input.action_release("right")
	check(game.player.position.x > start.x + 10,"Movimentação real por entrada")
	game.player.position = Vector2(400,330)
	Input.action_press("right")
	await create_timer(0.30).timeout
	Input.action_release("right")
	check(game.player.position.x < 421,"Colisão com a mesa")
	game.player.position = Vector2(540,225)
	game.interact(item("coil"))
	game.interact(item("coil"))
	check(game.collected.size() == 1,"Coleta única")
	game._pause()
	var guard_position: Vector2 = game.guards[0].position
	await create_timer(0.15).timeout
	check(not game.player.enabled and game.guards[0].position == guard_position,"Pausa paralisa a patrulha")
	game._resume()
	game.guards[0].speed = 0
	game.guards[0].position = Vector2(380,330)
	game.guards[0].facing = Vector2.RIGHT
	game.guards[0].route.clear()
	game.guards[0].route.append(Vector2(380,330))
	game.guards[0].route.append(Vector2(800,330))
	game.guards[0].waypoint = 1
	game.player.position = Vector2(620,390)
	await physics_frame
	await physics_frame
	check(not game.guards[0].sees_player,"Mesa bloqueia linha de visão")
	game.player.position = Vector2(410,330)
	await physics_frame
	await physics_frame
	check(game.guards[0].sees_player,"Guarda detecta jogador visível")
	await create_timer(1.85).timeout
	check(game.state == game.State.CAPTURED,"Detecção sustentada causa captura")
	game.state = game.State.PLAY
	game._clear_overlay()
	game.load_room("lab1",Vector2(1090,480))
	game.interact(item("to_storage"))
	check(game.room_id == "storage","Transição de sala")
	game.player.position = item("cell").position
	game.interact(item("cell"))
	game.player.position = item("to_lab2").position
	game.interact(item("to_lab2"))
	game.player.position = item("device").position
	game.interact(item("device"))
	check(game.state == game.State.PLAY,"Terminal exige todas as peças")
	game.player.position = item("chip").position
	game.interact(item("chip"))
	game.player.position = item("device").position
	game.interact(item("device"))
	check(game.state == game.State.WON and game.collected.size() == 3,"Missão completa nas três salas")
	game.save_enabled = true
	game.save_progress()
	game.collected.clear()
	game.continue_game()
	check(game.collected.size() == 3 and game.room_id == "lab2", "Persistência e retomada")
	var file := FileAccess.open(game.save_path,FileAccess.WRITE)
	file.store_string('{"version":1,"room":"unknown","parts":[]}')
	file.close()
	check(game._read_save().is_empty(), "Progresso inválido rejeitado")
	DirAccess.remove_absolute(game.save_path)
	game.save_enabled = false
	game.start_new()
	check(game.collected.is_empty() and game.room_id == "lab1","Reinício limpa a missão")
	game.queue_free()
	await process_frame
	print("RESULT: %d falha(s)" % failures)
	quit(1 if failures else 0)
