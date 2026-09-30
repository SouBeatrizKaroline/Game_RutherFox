extends SceneTree
var failures := 0
func _initialize() -> void:
	call_deferred("run")
func check(value: bool, label: String) -> void:
	print(("PASS: " if value else "FAIL: ") + label)
	if not value: failures += 1
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	game.save_enabled = false
	root.add_child(game)
	await process_frame
	game.start_new()
	var guard = game.guards[0]
	guard.position = Vector2(750,460)
	guard.facing = Vector2.RIGHT
	game.player.position = Vector2(300,460)
	guard.investigate(Vector2(720,460))
	await create_timer(0.7).timeout
	check(guard.mode == guard.Mode.SEARCH,"Investiga ruído e busca no destino")
	await create_timer(2.8).timeout
	check(guard.mode == guard.Mode.PATROL or guard.mode == guard.Mode.RETURN,"Retorna à patrulha após busca")
	game.distract()
	check(game.player.distraction_cooldown > 0,"Distração inicia recarga")
	var cooldown: float = game.player.distraction_cooldown
	game.distract()
	check(game.player.distraction_cooldown == cooldown,"Recarga impede spam de distração")
	game._pause()
	var frame_time: float = game.player.art.time
	await create_timer(0.15).timeout
	check(game.player.art.time == frame_time and game.player.distraction_cooldown == cooldown,"Pausa congela animação e recarga")
	game._resume()
	guard.position = Vector2(400,330)
	guard.mode = guard.Mode.INVESTIGATE
	guard.target = Vector2(800,330)
	game.player.position = Vector2(150,480)
	await create_timer(0.6).timeout
	check(guard.position.x < 421,"Investigação respeita colisão da bancada")
	game.load_room("lab2",Vector2(300,480))
	check(game.guards[0].role == "scientist","Cientista no laboratório nuclear")
	game._win()
	check(game.guards[0].transformed and not game.guards[0].sees_player,"Pulso transforma personagem e desativa detecção")
	await create_timer(2.2).timeout
	check(is_instance_valid(game.overlay) and game.state == game.State.WON,"Sequência abre desfecho")
	game.queue_free()
	await process_frame
	print("RESULT: %d falha(s)" % failures)
	quit(1 if failures else 0)
