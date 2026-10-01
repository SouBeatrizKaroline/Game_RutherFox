extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	game.save_enabled = false
	game.save_path = "res://.runtime/preview-%d.json" % OS.get_process_id()
	root.add_child(game)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/menu.png")
	game.start_new()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/gameplay.png")
	for id in ["storage","lab2"]:
		game.load_room(id,Vector2(180,480))
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://docs/" + id + ".png")
	quit()
